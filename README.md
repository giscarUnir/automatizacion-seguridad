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

## Resultado de la prueba del 10 de julio de 2026

La prueba no fue solamente una revisión de diapositivas. El
[PR #12](https://github.com/giscarUnir/automatizacion-seguridad/pull/12)
endureció 25 archivos y pasó por cinco ciclos de corrección antes de quedar
completamente verde:

| Hora (Lima) | Resultado del lote | Qué estaba ocurriendo |
|---|---:|---|
| 03:32 | 4 workflows fallaron | Cache de Docker, Dependency Graph, actionlint y controles de imagen/DAST |
| 03:36 | 2 fallaron | Seguían abiertos DAST y el escaneo de imagen |
| 03:39 | 2 fallaron | Se afinó la política y el runtime |
| 03:42 | 2 fallaron | Última iteración de imagen y cabeceras HTTP |
| 03:45 | 0 fallaron | Los 7 workflows y sus 11 jobs quedaron verdes |
| 03:49 | merge | El ruleset activo permitió integrar el cambio |

Después, el [PR #13](https://github.com/giscarUnir/automatizacion-seguridad/pull/13)
migró la attestation de SBOM a `actions/attest@v4` para eliminar una advertencia
de deprecación, y volvió a ejecutar el flujo completo.

### Por qué la sesión tardó más que una ejecución

Una **ejecución limpia** del PR terminó en **2 min 19 s**. La sesión demoró más
porque cada hallazgo exigió analizar, corregir, crear un commit y volver a
ejecutar todos los controles. El PR #12 estuvo abierto **17 min 23 s** y el PR
#13 necesitó **2 min 24 s**. La ventana completa de Actions, desde la primera
ronda hasta la validación final de `main`, fue de aproximadamente **26 min 35 s**.

Medición de la ronda verde del PR #12:

| Control o grupo | Duración medida |
|---|---:|
| Dependency Review | 8 s |
| Gitleaks | 9 s |
| actionlint / zizmor | 24 s / 16 s |
| Build + pruebas | 29 s |
| Semgrep / Trivy FS / Checkov | 31 s / 22 s / 39 s |
| OWASP ZAP | 1 min 25 s |
| Imagen + SBOM + procedencia | 1 min 59 s |
| CodeQL | 2 min 15 s |
| **Flujo completo, en paralelo** | **2 min 19 s** |
| **Consumo acumulado de los 11 jobs** | **8 min 37 s de runner** |

Las cinco rondas verdes más recientes observadas promediaron cerca de **2 min
22 s** de tiempo de pared. Esto es una medición de este microservicio, no una
garantía universal: repositorios grandes, colas, caches fríos y runners con poca
capacidad pueden elevarla.

### Objetivos recomendados para el banco

- Pull Request crítico: objetivo de **5 minutos o menos** para pruebas, secretos,
  SAST diferencial, SCA e IaC.
- `main` / release: objetivo de **15 minutos o menos** para CodeQL completo,
  DAST, imagen, SBOM y attestations.
- Nightly: análisis amplios de **15–60 minutos**, según tamaño y tecnología.
- Medir por repositorio `p50`, `p95`, tiempo de cola, falsos positivos y minutos
  de runner; estos son SLO del piloto, no SLA de GitHub.

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

En este repositorio existe un ruleset activo, **DevSecOps banking baseline**, que
protege la rama por defecto, exige los 11 status checks y aplica una regla de
CodeQL para alertas altas o críticas. En una organización bancaria, el ruleset
debe gestionarse a nivel de organización/enterprise y limitar los bypass.

## ¿La licencia GitHub Enterprise es suficiente?

**No debe asumirse que sí.** Para repositorios públicos, varias capacidades
avanzadas se pueden usar sin costo adicional. Para repositorios privados o
internos del banco, hay que revisar el despliegue y el contrato:

| Capacidad | Requisito habitual en repos privados/internos |
|---|---|
| Repositorios, Actions, rulesets y gobierno | GitHub Enterprise base |
| CodeQL/code scanning y Dependency Review | **GitHub Code Security** o contrato legado de GitHub Advanced Security |
| Secret scanning y Push Protection | **GitHub Secret Protection** o contrato legado de GitHub Advanced Security |
| Artifact Attestations en privados/internos | GitHub Enterprise Cloud |
| Gitleaks, Semgrep, Trivy, Checkov, ZAP y Syft | No requieren SKU de GitHub; sí gestión de licencias OSS, versiones y soporte |

GitHub calcula el uso de Code Security y Secret Protection por **committers
activos únicos** en los repositorios donde se habilitan. Fuentes oficiales:
[GitHub security features](https://docs.github.com/en/code-security/getting-started/github-security-features),
[Advanced Security license billing](https://docs.github.com/en/billing/concepts/product-billing/github-advanced-security) y
[Artifact Attestations](https://docs.github.com/en/enterprise-cloud@latest/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations).

Antes del piloto se debe confirmar si el banco usa **GitHub Enterprise Cloud o
GitHub Enterprise Server**, qué SKUs tiene contratados y cuántos committers
activos entrarían en alcance.

## Requisitos técnicos y operativos para el banco

- Runners Linux aislados, con Docker y Java 21; capacidad suficiente para los 11
  jobs concurrentes o una política explícita de colas.
- Salida de red a GitHub Actions, registry y bases de vulnerabilidades, incluyendo
  proxy, certificados y allowlists. Con IP allow list, usar self-hosted runners o
  larger runners con IP estática.
- Registry corporativo o GHCR, retención definida para logs, SARIF, SBOM,
  attestations y artefactos.
- Rulesets, CODEOWNERS, Security Manager, dueños por control y proceso de
  excepción con justificación, mitigación y caducidad.
- OIDC o gestor de secretos para despliegues; evitar credenciales de larga vida.
- En GitHub Enterprise Server, validar versión, catálogo de actions permitido y
  conectividad de los runners antes de copiar este flujo.

Referencias: [self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners) e
[IP allow lists con Actions](https://docs.github.com/en/enterprise-cloud@latest/admin/configuring-settings/hardening-security-for-your-enterprise/restricting-network-traffic-to-your-enterprise-with-an-ip-allow-list).

## Alcance correcto para banca

Esta vitrina es una base robusta de **DevSecOps y cadena de suministro**, no una
aplicación bancaria lista para producción. Un servicio real también necesita IAM,
autorización por rol, cifrado y gestión de llaves, auditoría inmutable, protección
de datos, API gateway/WAF, rate limiting, monitoreo/SOC, resiliencia y un proceso
formal de excepciones.

Artifact Attestations aporta por sí solo una base SLSA Build L2. Llegar a L3 exige,
entre otros requisitos, instrucciones de build conocidas y aisladas mediante un
workflow reutilizable gobernado por la organización.

### Evidencia validada y pendiente

Quedó validado el camino real de endurecimiento: fallos de configuración y
seguridad, correcciones, 11 checks verdes, ruleset activo, imagen escaneada,
SBOM y attestations. El escenario negativo con cinco fallas intencionales está
preparado por `scripts/crear-branch-demo.sh`, pero **todavía no quedó preservado
como Pull Request independiente**. Esa ejecución debe formar parte del piloto
privado para mostrar de manera controlada el bloqueo de cada riesgo.

## Estructura

```
src/main/java/com/bancox/clientes/   CRUD seguro (resource, service, repository, entity, dto)
deploy/k8s/                          manifiestos seguros (runAsNonRoot, límites, probes)
.github/workflows/                   ci, codeql, dependency-review, security-oss, supply-chain, dast
.github/dependabot.yml               actualizaciones de dependencias
scripts/                             scan-local, crear-branch-demo, crear-repo-publico
demo-inseguro/                       documentación del escenario de hallazgos
GUIA-DEMO.md                         guion paso a paso para la presentación
arquitectura_devsecops_banca_resultados_v8.pptx  presentación ejecutiva con evidencia, tiempos y requisitos
```

## Puesta en marcha (resumen)

1. Crear el repo público y subir: `bash scripts/crear-repo-publico.sh`
2. Activar en *Settings > Code security*: Secret scanning, Push protection, Dependabot, CodeQL.
3. Ensayar en local sin subir nada: `bash scripts/scan-local.sh` (requiere Docker).
4. Demo de bloqueo: `bash scripts/crear-branch-demo.sh` y abrir el Pull Request.

El paso a paso detallado está en **`GUIA-DEMO.md`**.
