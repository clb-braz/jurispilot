#!/bin/bash
# ============================================
# JurisPilot - Importar Workflows n8n
# ============================================
# Este script importa todos os workflows do n8n via API
# Execute: ./scripts/import-workflows.sh
# Compatível com: macOS, Linux
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

write_success() { echo -e "${GREEN}✅ $1${NC}"; }
write_error() { echo -e "${RED}❌ $1${NC}"; }
write_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
write_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
write_step() { echo -e "\n${MAGENTA}📋 $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOWS_PATH="$PROJECT_ROOT/n8n/workflows"

if [ ! -d "$WORKFLOWS_PATH" ]; then
    write_error "Diretório de workflows não encontrado: $WORKFLOWS_PATH"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}⚙️  JurisPilot - Importar Workflows n8n${NC}"
echo -e "${CYAN}========================================\n${NC}"

# Parâmetros padrão
N8N_URL="${N8N_URL:-http://localhost:5678}"
N8N_USER="${N8N_USER:-admin}"
N8N_PASSWORD="${N8N_PASSWORD:-admin}"

# Carrega .env
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep -E '^N8N_' | xargs)
    N8N_URL="${N8N_URL:-http://localhost:5678}"
    N8N_USER="${N8N_USER:-admin}"
    N8N_PASSWORD="${N8N_PASSWORD:-admin}"
fi

# Verifica n8n
write_step "Verificando se n8n está rodando..."

if curl -s -f "$N8N_URL/healthz" > /dev/null 2>&1; then
    write_success "n8n está rodando em $N8N_URL"
else
    write_error "n8n não está acessível em $N8N_URL"
    write_info "Certifique-se de que o n8n está rodando: n8n start"
    exit 1
fi

# Autentica
write_step "Autenticando no n8n..."

AUTH_URL="$N8N_URL/rest/login"
AUTH_BODY="{\"email\":\"$N8N_USER\",\"password\":\"$N8N_PASSWORD\"}"

AUTH_RESPONSE=$(curl -s -X POST "$AUTH_URL" \
    -H "Content-Type: application/json" \
    -d "$AUTH_BODY" 2>/dev/null)

if echo "$AUTH_RESPONSE" | grep -q "cookie"; then
    SESSION_ID=$(echo "$AUTH_RESPONSE" | grep -o '"cookie":"[^"]*' | cut -d'"' -f4)
    HEADERS=(-H "Cookie: $SESSION_ID" -H "Content-Type: application/json")
    write_success "Autenticação realizada com sucesso"
else
    write_warning "Tentando sem autenticação (n8n pode estar sem auth configurado)"
    HEADERS=(-H "Content-Type: application/json")
fi

# Lista workflows existentes
write_step "Listando workflows existentes..."

EXISTING_WORKFLOWS=$(curl -s "${HEADERS[@]}" "$N8N_URL/api/v1/workflows" 2>/dev/null || echo '{"data":[]}')
EXISTING_COUNT=$(echo "$EXISTING_WORKFLOWS" | grep -o '"id"' | wc -l | tr -d ' ')
write_info "Workflows existentes: $EXISTING_COUNT"

# Importa workflows
write_step "Importando workflows..."

IMPORTED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

for file in "$WORKFLOWS_PATH"/*.json; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    WORKFLOW_NAME=$(basename "$file" .json)
    
    # Lê workflow
    WORKFLOW_CONTENT=$(cat "$file")
    WORKFLOW_NAME_FROM_FILE=$(echo "$WORKFLOW_CONTENT" | grep -o '"name":"[^"]*' | head -1 | cut -d'"' -f4)
    
    # Verifica se já existe
    if echo "$EXISTING_WORKFLOWS" | grep -q "\"name\":\"$WORKFLOW_NAME_FROM_FILE\""; then
        write_warning "Workflow '$WORKFLOW_NAME_FROM_FILE' já existe. Pulando..."
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # Prepara payload
    IMPORT_PAYLOAD=$(echo "$WORKFLOW_CONTENT" | jq -c '{name, nodes, connections, active: false, settings}')
    
    # Importa
    if curl -s -X POST "${HEADERS[@]}" "$N8N_URL/api/v1/workflows" \
        -d "$IMPORT_PAYLOAD" > /dev/null 2>&1; then
        write_success "Workflow importado: $WORKFLOW_NAME_FROM_FILE"
        ((IMPORTED_COUNT++))
    else
        write_error "Erro ao importar workflow '$WORKFLOW_NAME'"
        ((ERROR_COUNT++))
    fi
done

# Resumo
echo -e "\n${GREEN}✨ Importação concluída!\n${NC}"
echo -e "${CYAN}Resumo:${NC}"
echo "  ✅ Importados: $IMPORTED_COUNT"
echo "  ⏭️  Pulados: $SKIPPED_COUNT"
echo "  ❌ Erros: $ERROR_COUNT"
echo ""
write_info "Acesse o n8n em: $N8N_URL"
echo ""

