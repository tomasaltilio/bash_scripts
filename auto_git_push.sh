#!/bin/bash

# Config
GITHUB_USERNAME=$(gh api user | jq -r '.login')
COMMIT_MESSAGE="Auto-commit: $(date +'%Y-%m-%d %H:%M:%S')"

# Estilos
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Colores semáforo para mensajes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

# Otros colores
BLUE='\033[0;34m'
NOCOLOR='\033[0m' # para resetear color

# Funciones para imprimir con colorcito ;)
log_info() {
  echo -e "${BLUE}[INFO]${NOCOLOR} $1"
}

log_error() {
  echo -e "${RED}[ERROR] $1${NOCOLOR}"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NOCOLOR} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS] $1${NOCOLOR}"
}

# Main functions
## Encuentra todos los repos de git
find_git_repos() {
    find . -type d -name .git -exec dirname {} \;
}

## Comitea y pushea cambios en un repo
process_repo() {
    local challenge="$1"
    log_info "Procesando challenge (repo Git): ${challenge}"

    cd "$challenge" || return

    # Busca cambios en el repo
    if [ -z "$(git status --porcelain)" ]; then
        log_info "No hay cambios pendientes en este challenge"
        cd - > /dev/null || return
        return
    fi

    log_info "Se encontraron cambios para pushear!"
    # Sube todos los archivos con cambios, inclusive si no son notebooks
    git add .
    # Commit
    git commit -m "$COMMIT_MESSAGE"
    push_output=$(git push origin master 2>&1)
    if git push origin master; then
      log_success "Subida exitosa del challenge ${challenge} a GitHub"
    else
      log_error "Falló la subida debido al siguiente error:"
      echo "${push_output}"
    fi
    cd - > /dev/null || return
}

# Main
log_info "Comenzando el proceso de autocommit"
cd ~/code/$GITHUB_USERNAME

repos=$(find_git_repos)
  
if [ -z "$repos" ]; then
    log_warning "No se encontraron challenges"
    exit 0
fi

log_info "Challenges a procesar:"
echo "$repos"

for repo in $repos; do
    process_repo "$repo"
done


echo -e "${BOLD}===== Proceso completado =====${NOCOLOR}"
