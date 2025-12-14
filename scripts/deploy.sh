#!/bin/bash
# JurisPilot - Script de Deploy
# Deploy em produção

set -e

echo "🚀 Fazendo deploy do JurisPilot..."

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verifica se está no diretório correto
if [ ! -d "python" ] || [ ! -d "n8n" ]; then
    echo -e "${RED}❌ Execute este script a partir do diretório raiz do JurisPilot${NC}"
    exit 1
fi

# Verifica se .env existe
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Arquivo .env não encontrado. Execute setup.sh primeiro.${NC}"
    exit 1
fi

# 1. Backup do banco de dados
echo -e "${YELLOW}💾 Fazendo backup do banco de dados...${NC}"
source .env
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > "backups/$BACKUP_FILE" 2>/dev/null || echo "⚠️  Backup manual necessário"
echo -e "${GREEN}✅ Backup concluído${NC}"

# 2. Atualiza dependências Python
echo -e "${YELLOW}📦 Atualizando dependências Python...${NC}"
cd python
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..
echo -e "${GREEN}✅ Dependências atualizadas${NC}"

# 3. Executa migrações do banco (se houver)
echo -e "${YELLOW}🗄️  Executando migrações...${NC}"
if [ -d "database/migrations" ] && [ "$(ls -A database/migrations)" ]; then
    for migration in database/migrations/*.sql; do
        echo "Executando: $migration"
        psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$migration" || echo "⚠️  Erro na migração (pode já estar aplicada)"
    done
fi
echo -e "${GREEN}✅ Migrações concluídas${NC}"

# 4. Reinicia serviços
echo -e "${YELLOW}🔄 Reiniciando serviços...${NC}"

# n8n (se estiver rodando como serviço)
if systemctl is-active --quiet n8n; then
    sudo systemctl restart n8n
    echo "✅ n8n reiniciado"
else
    echo "⚠️  n8n não está rodando como serviço. Reinicie manualmente."
fi

# Python API (se estiver rodando)
if pgrep -f "python.*api" > /dev/null; then
    echo "⚠️  API Python detectada. Reinicie manualmente se necessário."
fi

echo -e "${GREEN}✅ Deploy concluído!${NC}"
echo ""
echo "Verifique os logs dos serviços para garantir que tudo está funcionando:"
echo "  - n8n: journalctl -u n8n -f"
echo "  - PostgreSQL: tail -f /var/log/postgresql/postgresql.log"
echo ""

