#!/bin/bash
# ============================================
# JurisPilot - Health Check do Sistema
# ============================================
# Este script verifica a saúde de todos os componentes
# Execute: ./scripts/health-check.sh
# Compatível com: macOS, Linux
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

write_success() { echo -e "${GREEN}✅ $1${NC}"; }
write_error() { echo -e "${RED}❌ $1${NC}"; }
write_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
write_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}🏥 JurisPilot - Health Check${NC}"
echo -e "${CYAN}============================\n${NC}"

HEALTH_STATUS=(
    "PostgreSQL:false"
    "N8N:false"
    "APIPython:false"
    "Storage:false"
)

# PostgreSQL
write_info "Verificando PostgreSQL..."

if command -v psql &> /dev/null; then
    PG_VERSION=$(psql --version | head -n1)
    write_success "PostgreSQL instalado"
    
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep -E '^DB_' | xargs)
        DB_HOST="${DB_HOST:-localhost}"
        DB_PORT="${DB_PORT:-5432}"
        DB_NAME="${DB_NAME:-jurispilot}"
        DB_USER="${DB_USER:-postgres}"
        
        write_info "  Host: $DB_HOST:$DB_PORT"
        write_info "  Database: $DB_NAME"
        write_info "  User: $DB_USER"
        HEALTH_STATUS[0]="PostgreSQL:true"
    fi
else
    write_error "PostgreSQL não encontrado"
fi

# n8n
write_info "Verificando n8n..."

N8N_URL="${N8N_URL:-http://localhost:5678}"
if curl -s -f "$N8N_URL/healthz" > /dev/null 2>&1; then
    write_success "n8n está rodando em $N8N_URL"
    HEALTH_STATUS[1]="N8N:true"
else
    write_warning "n8n não está rodando (execute: n8n start)"
fi

# API Python
write_info "Verificando API Python..."

API_URL="${API_URL:-http://localhost:5000}"
HEALTH_CHECK=$(curl -s "$API_URL/health" 2>/dev/null || echo "")
if echo "$HEALTH_CHECK" | grep -q "healthy"; then
    write_success "API Python está rodando em $API_URL"
    SERVICE=$(echo "$HEALTH_CHECK" | grep -o '"service":"[^"]*' | cut -d'"' -f4)
    VERSION=$(echo "$HEALTH_CHECK" | grep -o '"version":"[^"]*' | cut -d'"' -f4)
    write_info "  Service: $SERVICE"
    write_info "  Version: $VERSION"
    HEALTH_STATUS[2]="APIPython:true"
else
    write_warning "API Python não está rodando (execute: ./scripts/start-api.sh)"
fi

# Storage
write_info "Verificando storage..."

STORAGE_DIRS=("storage/documents" "storage/uploads" "logs" "backups")
ALL_DIRS_EXIST=true

for dir in "${STORAGE_DIRS[@]}"; do
    FULL_PATH="$PROJECT_ROOT/$dir"
    if [ -d "$FULL_PATH" ]; then
        write_success "  $dir existe"
    else
        write_warning "  $dir não existe"
        ALL_DIRS_EXIST=false
    fi
done

if [ "$ALL_DIRS_EXIST" = true ]; then
    HEALTH_STATUS[3]="Storage:true"
fi

# Resumo
echo -e "\n${CYAN}📊 Status do Sistema\n${NC}"

ALL_HEALTHY=true
for status in "${HEALTH_STATUS[@]}"; do
    NAME="${status%%:*}"
    VALUE="${status##*:}"
    
    if [ "$VALUE" = "true" ]; then
        echo "$NAME: ✅ Online"
    else
        echo "$NAME: ❌ Offline"
        ALL_HEALTHY=false
    fi
done

echo ""

if [ "$ALL_HEALTHY" = true ]; then
    echo -e "${GREEN}✨ Sistema está saudável!\n${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Alguns componentes precisam de atenção.\n${NC}"
    exit 1
fi

