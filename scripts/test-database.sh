#!/bin/bash
# ============================================
# JurisPilot - Testes do Banco de Dados
# ============================================
# Este script testa o banco de dados PostgreSQL
# Execute: ./scripts/test-database.sh
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

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}🧪 JurisPilot - Testes do Banco de Dados${NC}"
echo -e "${CYAN}======================================\n${NC}"

# Carrega .env
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-jurispilot}"
DB_USER="${DB_USER:-postgres}"

if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep -E '^DB_' | xargs)
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"
    DB_NAME="${DB_NAME:-jurispilot}"
    DB_USER="${DB_USER:-postgres}"
fi

if [ -z "$DB_PASSWORD" ]; then
    read -sp "Digite a senha do PostgreSQL: " DB_PASSWORD
    echo ""
fi

export PGPASSWORD="$DB_PASSWORD"

# Testa conexão
write_step "Testando conexão..."

if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
    VERSION=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT version();" 2>/dev/null | head -1)
    write_success "Conexão estabelecida"
    write_info "PostgreSQL: $VERSION"
else
    write_error "Falha ao conectar ao banco de dados"
    exit 1
fi

# Verifica tabelas
write_step "Verificando tabelas..."

TABLES=("clientes" "casos" "checklists_juridicos" "checklists_caso" "documentos" "prazos" "linha_tempo" "resumos_juridicos" "auditoria_operacional")

ALL_TABLES_EXIST=true
for table in "${TABLES[@]}"; do
    EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='$table';" 2>/dev/null || echo "")
    
    if [ "$EXISTS" = "1" ]; then
        write_success "Tabela '$table' existe"
    else
        write_error "Tabela '$table' não encontrada"
        ALL_TABLES_EXIST=false
    fi
done

# Testa inserção
write_step "Testando inserção de dados..."

TEST_CLIENTE=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "INSERT INTO clientes (nome, email, telefone) VALUES ('Cliente Teste', 'teste@example.com', '11999999999') RETURNING id;" 2>/dev/null || echo "")

if [ -n "$TEST_CLIENTE" ] && [[ "$TEST_CLIENTE" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    write_success "Cliente de teste inserido: $TEST_CLIENTE"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "DELETE FROM clientes WHERE id='$TEST_CLIENTE';" > /dev/null 2>&1
    write_info "Cliente de teste removido"
else
    write_error "Falha ao testar inserção"
fi

# Conta registros
write_step "Contando registros..."

for table in "${TABLES[@]}"; do
    COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
    if [[ "$COUNT" =~ ^[0-9]+$ ]]; then
        write_info "  $table: $COUNT registros"
    fi
done

# Resumo
echo -e "\n${GREEN}✨ Testes concluídos!\n${NC}"

if [ "$ALL_TABLES_EXIST" = true ]; then
    write_success "Banco de dados está configurado corretamente"
    exit 0
else
    write_error "Algumas tabelas estão faltando. Execute setup-database.sh"
    exit 1
fi

unset PGPASSWORD

