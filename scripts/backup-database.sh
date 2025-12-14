#!/bin/bash
# ============================================
# JurisPilot - Backup do Banco de Dados
# ============================================
# Este script faz backup do PostgreSQL
# Execute: ./scripts/backup-database.sh
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
write_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
write_step() { echo -e "\n${CYAN}📋 $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}💾 JurisPilot - Backup do Banco de Dados${NC}"
echo -e "${CYAN}========================================\n${NC}"

# Parâmetros padrão
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-jurispilot}"
DB_USER="${DB_USER:-postgres}"
BACKUP_PATH="${BACKUP_PATH:-./backups}"
COMPRESS=false

# Carrega .env
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep -E '^DB_|^BACKUP_' | xargs)
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"
    DB_NAME="${DB_NAME:-jurispilot}"
    DB_USER="${DB_USER:-postgres}"
    BACKUP_PATH="${BACKUP_PATH:-./backups}"
fi

# Verifica compressão
if [ "$1" = "--compress" ] || [ "$1" = "-c" ]; then
    COMPRESS=true
fi

# Solicita senha
if [ -z "$DB_PASSWORD" ]; then
    read -sp "Digite a senha do PostgreSQL: " DB_PASSWORD
    echo ""
fi

export PGPASSWORD="$DB_PASSWORD"

# Cria diretório de backup
write_step "Preparando diretório de backup..."

BACKUP_DIR="$PROJECT_ROOT/$BACKUP_PATH"
mkdir -p "$BACKUP_DIR"
write_success "Diretório de backup: $BACKUP_DIR"

# Gera nome do arquivo
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

if [ "$COMPRESS" = true ]; then
    BACKUP_FILE="${BACKUP_FILE}.gz"
fi

# Executa backup
write_step "Executando backup..."

if [ "$COMPRESS" = true ]; then
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -F c | gzip > "$BACKUP_FILE" 2>/dev/null; then
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        write_success "Backup criado: $BACKUP_FILE"
        write_info "Tamanho: $FILE_SIZE"
    else
        write_error "Erro ao criar backup"
        exit 1
    fi
else
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_FILE" > /dev/null 2>&1; then
        FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        write_success "Backup criado: $BACKUP_FILE"
        write_info "Tamanho: $FILE_SIZE"
    else
        write_error "Erro ao criar backup"
        exit 1
    fi
fi

# Limpa backups antigos
write_step "Limpando backups antigos..."

RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
if [ -f "$PROJECT_ROOT/.env" ]; then
    RETENTION_FROM_ENV=$(grep "^BACKUP_RETENTION_DAYS=" "$PROJECT_ROOT/.env" | cut -d'=' -f2)
    if [ -n "$RETENTION_FROM_ENV" ]; then
        RETENTION_DAYS="$RETENTION_FROM_ENV"
    fi
fi

CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%s 2>/dev/null || date -v-${RETENTION_DAYS}d +%s 2>/dev/null || echo "0")

OLD_BACKUPS=0
for file in "$BACKUP_DIR"/${DB_NAME}_*.sql*; do
    if [ -f "$file" ]; then
        FILE_DATE=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null || echo "0")
        if [ "$FILE_DATE" -lt "$CUTOFF_DATE" ]; then
            rm -f "$file"
            ((OLD_BACKUPS++))
        fi
    fi
done

if [ $OLD_BACKUPS -gt 0 ]; then
    write_info "Removidos $OLD_BACKUPS backups antigos (mais de $RETENTION_DAYS dias)"
fi

# Resumo
echo -e "\n${GREEN}✨ Backup concluído!\n${NC}"
write_info "Arquivo: $BACKUP_FILE"
write_info "Para restaurar:"
if [ "$COMPRESS" = true ]; then
    echo "  gunzip < $BACKUP_FILE | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
else
    echo "  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $BACKUP_FILE"
fi
echo ""

unset PGPASSWORD

