#!/usr/bin/env bash
#
# Escaneo de seguridad LOCAL (sin subir nada a GitHub). Ideal para ensayar la
# demo o revisar antes de hacer push. Unico requisito: Docker instalado.
#
# Uso:  bash scripts/scan-local.sh
#
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "==================================================================="
echo " 1) Gitleaks — secretos en el codigo"
echo "==================================================================="
docker run --rm -v "$REPO:/repo" zricethezav/gitleaks:latest \
  detect --source=/repo --no-git -v || true

echo "==================================================================="
echo " 2) Semgrep — SAST (analisis estatico)"
echo "==================================================================="
docker run --rm -v "$REPO:/src" semgrep/semgrep \
  semgrep scan --config=auto /src || true

echo "==================================================================="
echo " 3) Trivy — dependencias, secretos y malas configuraciones"
echo "==================================================================="
docker run --rm -v "$REPO:/repo" aquasec/trivy:latest \
  fs --scanners vuln,misconfig,secret --severity HIGH,CRITICAL /repo || true

echo "==================================================================="
echo " 4) Checkov — IaC (Kubernetes + Dockerfile)"
echo "==================================================================="
docker run --rm -v "$REPO:/repo" bridgecrew/checkov:latest \
  -d /repo --quiet --compact || true

echo ""
echo "Escaneo local terminado. En la rama principal deberia salir limpio;"
echo "en 'demo/hallazgos-seguridad' veras los hallazgos intencionales."
