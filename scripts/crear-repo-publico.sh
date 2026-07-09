#!/usr/bin/env bash
#
# Crea el repositorio PUBLICO en tu cuenta de GitHub y sube el codigo.
# Requisitos: git y GitHub CLI (gh) autenticado -> ejecuta antes: gh auth login
#
# Uso:
#   bash scripts/crear-repo-publico.sh [nombre-del-repo]
#   (por defecto: automatizacion-seguridad)
#
set -euo pipefail

REPO_NAME="${1:-automatizacion-seguridad}"

command -v gh >/dev/null 2>&1 || { echo "Falta GitHub CLI (gh). Instalalo y corre: gh auth login"; exit 1; }

if [ ! -d .git ]; then
  git init -b main
fi

git add .
git commit -m "feat: microservicio Banco X (CRUD Clientes) + pipeline de seguridad (nativas + OSS)" || echo "Nada nuevo para commitear."

# Crea el repo PUBLICO, lo conecta como origin y sube main.
gh repo create "$REPO_NAME" --public --source=. --remote=origin --push

echo ""
echo "Repo publico creado y subido."
echo "Ahora activa las funciones NATIVAS (Settings > Code security):"
echo "  - Secret scanning  +  Push protection"
echo "  - CodeQL: usa el workflow codeql.yml (ya incluido) o el 'default setup'"
echo "  - Dependabot alerts + security updates"
echo ""
echo "Para la demo de bloqueo:  bash scripts/crear-branch-demo.sh  y abre el PR."
