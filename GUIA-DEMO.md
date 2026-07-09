# Guía de demo — Seguridad del código fuente (Banco X)

Guion para la **segunda parte** de tu presentación: "esto es lo último en
seguridad". La idea es mostrar, en vivo, cómo el pipeline **detecta y bloquea**
problemas de seguridad antes de que lleguen a la rama principal.

El mensaje central: *la seguridad no es un paso, son varias capas automáticas; y
la base es portable (OSS) mientras GitHub añade lo premium nativo (CodeQL,
push protection, procedencia SLSA).*

---

## Preparación (una sola vez, antes de presentar)

1. **Crear el repo público y subir el código**
   ```bash
   cd automatizacion-seguridad
   bash scripts/crear-repo-publico.sh
   ```
2. **Activar las funciones nativas** (Settings > Code security & analysis):
   - Secret scanning → **On**
   - Push protection → **On**
   - Dependabot alerts + security updates → **On**
   - CodeQL: deja el workflow `codeql.yml` (ya incluido) o usa "Default setup".
3. (Opcional pero recomendado) **Ruleset** que exija los checks para mergear:
   Settings > Rules > New ruleset → Require status checks →
   marca `secretos-gitleaks`, `dependency-review`, `codeql-sast`.
   Esto hace que el bloqueo sea visible ("no se puede mergear").

> Deja la rama `main` ya subida y verde: es tu punto de partida "todo limpio".

---

## Ensayo rápido sin GitHub (opcional)

Para probar todo en tu máquina antes, sin subir nada (solo requiere Docker):
```bash
bash scripts/scan-local.sh
```
En `main` sale limpio; si primero corres `crear-branch-demo.sh`, verás los hallazgos.

---

## La demo en vivo (10–12 min)

### Escena 1 — "El pipeline en verde" (1 min)
Abre la pestaña **Actions** y muestra `main` con todos los workflows en verde:
build, CodeQL, security-oss (gitleaks/semgrep/trivy/checkov), supply-chain, dast.
Mensaje: *"cada push pasa por 7 capas de seguridad automáticas."*

### Escena 2 — "Introduzco un cambio inseguro" (2 min)
Crea la rama con los hallazgos intencionales y ábrela como PR:
```bash
bash scripts/crear-branch-demo.sh
git push -u origin demo/hallazgos-seguridad
```
Abre el Pull Request en GitHub. Explica que un desarrollador "acaba de introducir"
cinco problemas típicos (un secreto, una inyección SQL, una dependencia vulnerable,
un Dockerfile inseguro y un manifiesto de Kubernetes inseguro).

### Escena 3 — "El pipeline los atrapa y bloquea" (5 min)
En el PR, recorre los checks y la pestaña de conversación:

| Lo que señalas | Control | Qué se ve |
|---|---|---|
| Check **en rojo** `secretos-gitleaks` | Secretos | El job falla: encontró la credencial |
| Check **en rojo** `dependency-review` | SCA | Bloquea el PR: dependencia con CVE (commons-text) |
| Alertas de **Code scanning** (CodeQL) | SAST nativo | Inyección SQL detectada, con explicación |
| Anotaciones de **Semgrep / Trivy / Checkov** | SAST/Contenedor/IaC | Hallazgos sobre las líneas del PR |
| Pestaña **Security** | Panel unificado | Todos los hallazgos en un solo lugar |

Remata: *"el merge está bloqueado; ningún cambio inseguro llega a la rama
principal sin intervención humana."*

### Escena 4 — "Push protection en acción" (opcional, 1 min)
Si activaste push protection, intenta empujar un secreto directamente y muestra
cómo **GitHub bloquea el push** en el momento (antes de que entre al repo).

### Escena 5 — "Procedencia y SBOM" (2 min)
En `main`, abre el workflow `supply-chain` y muestra:
- la **imagen firmada** con Artifact Attestations (SLSA build level 3),
- el **SBOM** (inventario de componentes) publicado como artefacto.
Mensaje: *"no solo revisamos el código; certificamos criptográficamente cómo y
dónde se construyó la imagen — trazabilidad para auditoría y cumplimiento."*

---

## Cierre (el argumento de venta)

- **Nivel 1 — OSS (portable):** Gitleaks, Semgrep, Trivy, Checkov, ZAP. Corren en
  cualquier plan, público o privado. Es la base que controlo y audito.
- **Nivel 2 — Nativo GitHub (premium):** CodeQL, Secret Scanning + Push Protection,
  Artifact Attestations, Copilot Autofix. Lo último en seguridad, y **el Enterprise
  del banco ya lo incluye**.
- **Gobierno:** Rulesets que exigen todos los checks; nada inseguro se mergea.

> Frase de cierre sugerida: *"Diseñé un pipeline con 7 capas de seguridad que
> funcionan en cualquier entorno; sobre el GitHub Enterprise del banco, además,
> se potencian con CodeQL, push protection y firma de procedencia nativas. Lo
> mejor de ambos mundos, y ningún código inseguro llega a producción."*

---

## Después de la demo

```bash
# Cierra el PR sin mergear (queda como evidencia) y, si quieres, borra la rama:
git checkout main
git branch -D demo/hallazgos-seguridad
git push origin --delete demo/hallazgos-seguridad
```
El repo es genérico y público a propósito: **nada del banco se expone en ningún
momento**. Tu piloto real permanece privado.
