# Banco X — Vitrina de seguridad (CRUD Clientes + DevSecOps)

Microservicio de demostración en **Java 21 / Quarkus** con un CRUD de clientes
(datos ficticios), montado como **vitrina pública** para mostrar un pipeline de
seguridad en GitHub: controles **nativos** y **open-source**, con umbrales,
evidencia y escenarios que demuestran qué controles informan y cuáles bloquean.

> Repositorio de demostración. No contiene datos ni código reales de ningún banco.

## Para qué sirve

Acompaña una propuesta de automatización DevSecOps. La idea: enseñar en vivo cómo
el pipeline **detecta y bloquea según una política definida** antes del merge, cubriendo
las capas del modelo DevSecOps (secretos, SAST, SCA, contenedor, IaC, DAST y
cadena de suministro).

## El microservicio

CRUD de clientes bajo `/banco-x/clientes/v1` (GET, GET/{id}, POST, PUT, DELETE),
con Quarkus + Panache + H2 en memoria (datos ficticios en `import.sql`). La versión
de la rama principal es **segura**: validación de entrada, consultas parametrizadas
y sin secretos en el código.

```bash
# Ejecutar local
mvn quarkus:dev
# Probar
curl localhost:8080/banco-x/clientes/v1
```

## Las capas de seguridad (qué corre y dónde)

| Capa | Herramienta | Tipo | Workflow |
|---|---|---|---|
| Secretos | Gitleaks + Secret Scanning/Push Protection | OSS + **nativo** | `security-oss.yml` + ajustes del repo |
| SAST | CodeQL + Semgrep | **nativo** + OSS | `codeql.yml`, `security-oss.yml` |
| SCA (dependencias) | Dependabot + Dependency Review + Trivy | **nativo** + OSS | `dependabot.yml`, `dependency-review.yml`, `security-oss.yml` |
| Contenedor | Trivy (imagen) | OSS | `supply-chain.yml` |
| IaC / Kubernetes | Checkov | OSS | `security-oss.yml` |
| DAST | OWASP ZAP | OSS | `dast.yml` |
| Cadena de suministro | SBOM (Syft) + Artifact Attestations | **nativo** | `supply-chain.yml` |
| Seguridad del pipeline | actionlint + zizmor + acciones fijadas por SHA | OSS | `workflow-security.yml` |

## Qué bloquea hoy

- CI y pruebas fallidas.
- Secretos detectados por Gitleaks.
- Hallazgos de Semgrep configurados como error.
- CVE altos o críticos detectados por Trivy y Dependency Review.
- Configuraciones inseguras detectadas por Checkov.
- Alertas DAST no aceptadas en la política de ZAP.
- Publicación de imagen: primero se escanea; solo después se publica y se atesta.
- Workflows inseguros o inválidos detectados por actionlint y zizmor.

Los jobs solo se convierten en una compuerta institucional cuando el ruleset de
`main` los exige. Para CodeQL, además se usa la regla específica de protección de
code scanning: el job de análisis publica resultados, pero no falla por cada alerta.

## Alcance correcto para banca

Esta vitrina es una base robusta de **DevSecOps y cadena de suministro**, no una
aplicación bancaria lista para producción. Un servicio real también necesita IAM,
autorización por rol, cifrado y gestión de llaves, auditoría inmutable, protección
de datos, API gateway/WAF, rate limiting, monitoreo/SOC, resiliencia y un proceso
formal de excepciones.

Artifact Attestations aporta por sí solo una base SLSA Build L2. Llegar a L3 exige,
entre otros requisitos, instrucciones de build conocidas y aisladas mediante un
workflow reutilizable gobernado por la organización.

## Estructura

```
src/main/java/com/bancox/clientes/   CRUD seguro (resource, service, repository, entity, dto)
deploy/k8s/                          manifiestos seguros (runAsNonRoot, límites, probes)
.github/workflows/                   ci, codeql, dependency-review, security-oss, supply-chain, dast
.github/dependabot.yml               actualizaciones de dependencias
scripts/                             scan-local, crear-branch-demo, crear-repo-publico
demo-inseguro/                       documentación del escenario de hallazgos
GUIA-DEMO.md                         guion paso a paso para la presentación
```

## Puesta en marcha (resumen)

1. Crear el repo público y subir: `bash scripts/crear-repo-publico.sh`
2. Activar en *Settings > Code security*: Secret scanning, Push protection, Dependabot, CodeQL.
3. Ensayar en local sin subir nada: `bash scripts/scan-local.sh` (requiere Docker).
4. Demo de bloqueo: `bash scripts/crear-branch-demo.sh` y abrir el Pull Request.

El paso a paso detallado está en **`GUIA-DEMO.md`**.
