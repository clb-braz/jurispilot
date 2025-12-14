#!/bin/bash
# ============================================
# JurisPilot - Script de Setup do Banco de Dados
# ============================================
# Este script configura o PostgreSQL completo
# Execute: ./scripts/setup-database.sh
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

if [ ! -f "$PROJECT_ROOT/database/schema.sql" ]; then
    write_error "Execute este script a partir do diretório raiz do JurisPilot"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}🗄️  JurisPilot - Configuração do Banco de Dados${NC}"
echo -e "${CYAN}============================================\n${NC}"

# Parâmetros padrão
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-jurispilot}"
DB_USER="${DB_USER:-postgres}"

# Carrega .env se existir
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep -E '^DB_' | xargs)
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"
    DB_NAME="${DB_NAME:-jurispilot}"
    DB_USER="${DB_USER:-postgres}"
fi

# Solicita senha se não estiver no .env
if [ -z "$DB_PASSWORD" ]; then
    read -sp "Digite a senha do usuário '$DB_USER': " DB_PASSWORD
    echo ""
    export PGPASSWORD="$DB_PASSWORD"
else
    export PGPASSWORD="$DB_PASSWORD"
fi

# Verifica PostgreSQL
write_step "Verificando PostgreSQL..."

if ! command -v psql &> /dev/null; then
    write_error "PostgreSQL não está instalado ou não está no PATH"
    write_info "Instale PostgreSQL 12+ e adicione ao PATH"
    exit 1
fi

PG_VERSION=$(psql --version | head -n1)
write_success "PostgreSQL encontrado: $PG_VERSION"

# Testa conexão
write_step "Testando conexão com PostgreSQL..."

if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT version();" > /dev/null 2>&1; then
    write_success "Conexão estabelecida com sucesso"
else
    write_error "Falha ao conectar ao PostgreSQL"
    write_info "Verifique:"
    echo "  - PostgreSQL está rodando?"
    echo "  - Host: $DB_HOST"
    echo "  - Port: $DB_PORT"
    echo "  - User: $DB_USER"
    echo "  - Senha está correta?"
    exit 1
fi

# Cria banco de dados
write_step "Criando banco de dados '$DB_NAME'..."

DB_EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null || echo "")

if [ "$DB_EXISTS" = "1" ]; then
    write_warning "Banco de dados '$DB_NAME' já existe"
    read -p "Deseja recriar? (isso apagará todos os dados) [s/N] " OVERWRITE
    if [ "$OVERWRITE" = "s" ] || [ "$OVERWRITE" = "S" ]; then
        write_info "Removendo banco de dados existente..."
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" > /dev/null 2>&1
    else
        write_info "Mantendo banco de dados existente"
        SKIP_CREATE=true
    fi
fi

if [ "$SKIP_CREATE" != "true" ]; then
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;" > /dev/null 2>&1; then
        write_success "Banco de dados '$DB_NAME' criado"
    else
        write_error "Falha ao criar banco de dados"
        exit 1
    fi
fi

# Executa schema
write_step "Executando schema.sql..."

SCHEMA_FILE="$PROJECT_ROOT/database/schema.sql"
if [ ! -f "$SCHEMA_FILE" ]; then
    write_error "Arquivo schema.sql não encontrado: $SCHEMA_FILE"
    exit 1
fi

write_info "Executando schema..."
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA_FILE" > /dev/null 2>&1; then
    write_success "Schema executado com sucesso"
else
    write_error "Falha ao executar schema.sql"
    exit 1
fi

# Executa seeds
write_step "Executando seeds (checklists_juridicos)..."

SEEDS_FILE="$PROJECT_ROOT/database/seeds/checklists_seed.sql"
if [ -f "$SEEDS_FILE" ]; then
    write_info "Executando seeds..."
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SEEDS_FILE" > /dev/null 2>&1; then
        write_success "Seeds executados com sucesso"
    else
        write_warning "Falha ao executar seeds (pode ser normal se já existirem)"
    fi
else
    write_warning "Arquivo de seeds não encontrado: $SEEDS_FILE"
fi

# Valida tabelas
write_step "Validando criação das tabelas..."

TABLES=("clientes" "casos" "checklists_juridicos" "checklists_caso" "documentos" "prazos" "linha_tempo" "resumos_juridicos" "auditoria_operacional")

ALL_TABLES_EXIST=true
for table in "${TABLES[@]}"; do
    TABLE_EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='$table';" 2>/dev/null || echo "")
    
    if [ "$TABLE_EXISTS" = "1" ]; then
        write_success "Tabela '$table' existe"
    else
        write_error "Tabela '$table' não encontrada"
        ALL_TABLES_EXIST=false
    fi
done

if [ "$ALL_TABLES_EXIST" = true ]; then
    write_success "Todas as tabelas foram criadas corretamente"
else
    write_error "Algumas tabelas não foram criadas. Verifique o schema.sql"
    exit 1
fi

# Conta checklists
write_step "Verificando dados iniciais..."

CHECKLIST_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM checklists_juridicos;" 2>/dev/null || echo "0")
if [[ "$CHECKLIST_COUNT" =~ ^[0-9]+$ ]]; then
    write_success "Checklists jurídicos: $CHECKLIST_COUNT registros"
fi

# Resumo
echo -e "\n${GREEN}✨ Banco de dados configurado com sucesso!\n${NC}"
echo -e "${CYAN}Informações de conexão:${NC}"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""
write_info "Configure essas informações no arquivo .env"
echo ""

unset PGPASSWORD

