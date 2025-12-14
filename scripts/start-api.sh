#!/bin/bash
# ============================================
# JurisPilot - Iniciar API Python
# ============================================
# Este script inicia o servidor Flask da API
# Execute: ./scripts/start-api.sh
# Compatível com: macOS, Linux
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

write_success() { echo -e "${GREEN}✅ $1${NC}"; }
write_error() { echo -e "${RED}❌ $1${NC}"; }
write_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "\n${CYAN}🚀 JurisPilot - Iniciando API Python\n${NC}"

# Verifica ambiente virtual
VENV_PATH="$PROJECT_ROOT/python/venv"
if [ ! -d "$VENV_PATH" ]; then
    write_error "Ambiente virtual não encontrado. Execute: ./scripts/setup.sh"
    exit 1
fi

# Verifica api_server.py
API_PATH="$PROJECT_ROOT/python/src/api_server.py"
if [ ! -f "$API_PATH" ]; then
    write_error "api_server.py não encontrado: $API_PATH"
    exit 1
fi

# Ativa ambiente virtual
source "$VENV_PATH/bin/activate"

# Verifica se está em produção
if [ "$1" = "--production" ]; then
    write_info "Iniciando servidor em modo produção (gunicorn)..."
    if command -v gunicorn &> /dev/null; then
        cd "$PROJECT_ROOT/python"
        gunicorn -w 4 -b 0.0.0.0:5000 "src.api_server:app"
    else
        write_error "gunicorn não encontrado. Instale com: pip install gunicorn"
        exit 1
    fi
else
    write_info "Iniciando servidor em modo desenvolvimento (Flask)..."
    write_info "API estará disponível em: http://localhost:5000"
    write_info "Pressione Ctrl+C para parar\n"
    cd "$PROJECT_ROOT/python"
    python src/api_server.py
fi

