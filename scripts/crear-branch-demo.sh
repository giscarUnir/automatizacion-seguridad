#!/usr/bin/env bash
#
# Crea la rama "demo/hallazgos-seguridad" con fallas de seguridad INTENCIONALES
# (datos ficticios) para que, al abrir el Pull Request, cada control las detecte
# y bloquee el merge. Es una demo controlada, no codigo para produccion.
#
# Uso:
#   bash scripts/crear-branch-demo.sh
#   git push -u origin demo/hallazgos-seguridad   # y abre el PR en GitHub
#
set -euo pipefail

BRANCH="demo/hallazgos-seguridad"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "No es un repo git. Corre primero scripts/crear-repo-publico.sh o git init."; exit 1; }

git checkout main 2>/dev/null || true
git checkout -b "$BRANCH"

echo ">> 1/5 Secreto en el codigo (lo detectan: Gitleaks + Secret Scanning nativo)"
AWS_ACCESS_KEY_ID="AKIA""QWERTYUIOPASDFGH"
AWS_SECRET_ACCESS_KEY="qwertyuiopasdfghjklzxcvbnm""qwertyuiopasdfgh"
cat > src/main/resources/aws-credentials.properties <<P
# ARCHIVO DE DEMO — credenciales FICTICIAS para evidenciar el control de secretos.
aws.accessKeyId=${AWS_ACCESS_KEY_ID}
aws.secretAccessKey=${AWS_SECRET_ACCESS_KEY}
db.password=SuperSecret123!
P

echo ">> 2/5 Inyeccion SQL + credencial hardcodeada (lo detectan: CodeQL + Semgrep)"
cat > src/main/java/com/bancox/clientes/BusquedaInseguraResource.java <<J
package com.bancox.clientes;

import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;

import java.util.List;

/**
 * DEMO INSEGURO (a proposito). NO usar como referencia.
 * Evidencia dos controles: inyeccion SQL y credencial en el codigo.
 */
@Path("/banco-x/clientes/v1/inseguro")
@Produces(MediaType.APPLICATION_JSON)
public class BusquedaInseguraResource {

    @Inject
    EntityManager em;

    // Credencial hardcodeada (DEMO) -> CodeQL / Semgrep / Gitleaks
    private static final String API_KEY = "${AWS_ACCESS_KEY_ID}";

    @GET
    @Path("/buscar")
    @SuppressWarnings("unchecked")
    public List<Cliente> buscar(@QueryParam("doc") String doc) {
        // VULNERABLE (DEMO): concatenacion directa del parametro -> INYECCION SQL
        String sql = "SELECT * FROM cliente WHERE documento = '" + doc + "'";
        return em.createNativeQuery(sql, Cliente.class).getResultList();
    }
}
J

echo ">> 3/5 Dependencia vulnerable (lo detectan: Dependabot + Trivy + Dependency Review)"
# commons-text 1.9 -> CVE-2022-42889 (Text4Shell). Se inyecta en el ancla unica.
sed -i.bak 's#<!-- demo-anchor:.*-->#<dependency>\
      <groupId>org.apache.commons</groupId>\
      <artifactId>commons-text</artifactId>\
      <version>1.9</version>\
    </dependency>#' pom.xml
rm -f pom.xml.bak

echo ">> 4/5 Dockerfile inseguro (lo detectan: Checkov + Trivy)"
cat > Dockerfile <<'D'
# DEMO INSEGURO: corre como root, sin usuario dedicado.
FROM eclipse-temurin:21-jre
USER root
WORKDIR /work
COPY target/quarkus-app/ /work/
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/work/quarkus-run.jar"]
D

echo ">> 5/5 Manifiesto Kubernetes inseguro (lo detecta: Checkov)"
cat > deploy/k8s/deployment.yaml <<'K'
# DEMO INSEGURO: privilegiado, como root, sin limites ni securityContext.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cliente-service
  namespace: banco-x
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cliente-service
  template:
    metadata:
      labels:
        app: cliente-service
    spec:
      containers:
        - name: cliente-service
          image: ghcr.io/owner/cliente-service:latest
          securityContext:
            privileged: true
            runAsUser: 0
            allowPrivilegeEscalation: true
          ports:
            - containerPort: 8080
K

git add -A
git commit -m "demo: hallazgos de seguridad intencionales (NO mergear)"

echo ""
echo "Rama '$BRANCH' creada con 5 hallazgos intencionales."
echo "Ahora:  git push -u origin $BRANCH   y abre el Pull Request en GitHub."
echo "Veras las compuertas de seguridad marcando en ROJO cada hallazgo."
