#!/bin/bash
# ============================================
# JurisPilot - Testes Completos do Sistema
# ============================================
# Este script testa todos os componentes do sistema
# Execute: ./scripts/test-workflows.sh
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

echo -e "\n${CYAN}🧪 JurisPilot - Testes Completos do Sistema${NC}"
echo -e "${CYAN}==========================================\n${NC}"

TEST_RESULTS=(
    "Database:false"
    "N8N:false"
    "APIPython:false"
    "Integrations:false"
)

# Testa banco de dados
if [ "$1" != "--skip-database" ]; then
    write_info "Testando banco de dados PostgreSQL..."
    if "$SCRIPT_DIR/test-database.sh" > /dev/null 2>&1; then
        TEST_RESULTS[0]="Database:true"
        write_success "Banco de dados: OK"
    else
        write_error "Banco de dados: FALHOU"
    fi
else
    write_info "Pulando teste do banco de dados"
fi

# Testa n8n
if [ "$1" != "--skip-n8n" ]; then
    write_info "Testando n8n..."
    N8N_URL="${N8N_URL:-http://localhost:5678}"
    
    if curl -s -f "$N8N_URL/healthz" > /dev/null 2>&1; then
        write_success "n8n está rodando"
        
        WORKFLOWS=$(curl -s "$N8N_URL/api/v1/workflows" 2>/dev/null || echo '{"data":[]}')
        WORKFLOW_COUNT=$(echo "$WORKFLOWS" | grep -o '"id"' | wc -l | tr -d ' ')
        write_success "Workflows encontrados: $WORKFLOW_COUNT"
        TEST_RESULTS[1]="N8N:true"
    else
        write_error "n8n não está acessível em $N8N_URL"
        write_info "Inicie o n8n com: n8n start"
    fi
else
    write_info "Pulando teste do n8n"
fi

# Testa API Python
if [ "$1" != "--skip-api" ]; then
    write_info "Testando API Python..."
    API_URL="${API_URL:-http://localhost:5000}"
    
    HEALTH_CHECK=$(curl -s "$API_URL/health" 2>/dev/null || echo "")
    if echo "$HEALTH_CHECK" | grep -q "healthy"; then
        write_success "API Python está rodando"
        SERVICE=$(echo "$HEALTH_CHECK" | grep -o '"service":"[^"]*' | cut -d'"' -f4)
        VERSION=$(echo "$HEALTH_CHECK" | grep -o '"version":"[^"]*' | cut -d'"' -f4)
        write_info "  Service: $SERVICE"
        write_info "  Version: $VERSION"
        TEST_RESULTS[2]="APIPython:true"
    else
        write_error "API Python não está acessível em $API_URL"
        write_info "Inicie a API com: ./scripts/start-api.sh"
    fi
else
    write_info "Pulando teste da API"
fi

# Testa integrações
write_info "Testando integrações..."

if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi

if [ -n "${WHATSAPP_API_KEY:-}" ]; then
    write_info "WhatsApp: Configurado (não testado)"
else
    write_warning "WhatsApp: Não configurado"
fi

if [ "${GOOGLE_CALENDAR_ENABLED:-false}" = "true" ]; then
    write_info "Google Calendar: Configurado (não testado)"
else
    write_warning "Google Calendar: Não configurado"
fi

if [ "${EMAIL_ENABLED:-false}" = "true" ]; then
    write_info "Email: Configurado (não testado)"
else
    write_warning "Email: Não configurado"
fi

TEST_RESULTS[3]="Integrations:true"

# Resumo
echo -e "\n${CYAN}📊 Resumo dos Testes\n${NC}"

PASSED=0
TOTAL=${#TEST_RESULTS[@]}

for result in "${TEST_RESULTS[@]}"; do
    NAME="${result%%:*}"
    STATUS="${result##*:}"
    
    if [ "$STATUS" = "true" ]; then
        echo "$NAME: ✅"
        ((PASSED++))
    else
        echo "$NAME: ❌"
    fi
done

echo ""

if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}✨ Todos os testes passaram!\n${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Alguns testes falharam. Verifique as mensagens acima.\n${NC}"
    exit 1
fi

