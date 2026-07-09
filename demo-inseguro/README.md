# Escenario de hallazgos (demo controlada)

Esta carpeta documenta las fallas de seguridad **intencionales** que introduce
`scripts/crear-branch-demo.sh` al crear la rama `demo/hallazgos-seguridad`.
Son datos ficticios; sirven para **evidenciar que cada control funciona**.

| # | Falla intencional | Archivo que la contiene | Control que la detecta |
|---|---|---|---|
| 1 | Credenciales en el codigo (llave AWS de ejemplo, password) | `src/main/resources/aws-credentials.properties` | **Gitleaks** (bloquea) + **Secret Scanning / Push Protection** nativo |
| 2 | Inyeccion SQL (concatenacion del parametro) | `src/main/java/.../BusquedaInseguraResource.java` | **CodeQL** (nativo) + **Semgrep** |
| 3 | Credencial hardcodeada en clase Java | mismo archivo del punto 2 | **CodeQL** + **Semgrep** + **Gitleaks** |
| 4 | Dependencia vulnerable (commons-text 1.9, CVE-2022-42889) | `pom.xml` | **Dependabot** + **Dependency Review** (bloquea) + **Trivy** |
| 5 | Dockerfile inseguro (corre como root) | `Dockerfile` | **Checkov** + **Trivy** |
| 6 | Manifiesto K8s inseguro (privileged, runAsUser 0) | `deploy/k8s/deployment.yaml` | **Checkov** |

## Compuertas que BLOQUEAN el merge (check en rojo)

- **Gitleaks** → falla el job al detectar el secreto.
- **Dependency Review** → falla el PR al introducir la dependencia vulnerable.

## Controles que muestran los hallazgos (pestana Security + anotaciones en el PR)

- **CodeQL, Semgrep, Trivy, Checkov** publican sus resultados en SARIF; se ven en
  la pestana *Security* del repo y como anotaciones sobre las lineas del PR.

> Para reforzar el bloqueo puedes marcarlos como *required status checks* en un
> Ruleset (Settings > Rules), asi ninguno se puede saltar antes de mergear.
