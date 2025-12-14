#!/bin/bash
# JurisPilot - Script de Setup
# Configura ambiente de desenvolvimento

set -e

echo "🚀 Configurando JurisPilot..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se está no diretório correto
if [ ! -d "python" ] || [ ! -d "n8n" ] || [ ! -d "database" ]; then
    echo "❌ Execute este script a partir do diretório raiz do JurisPilot"
    exit 1
fi

# 1. Configura Python
echo -e "${YELLOW}📦 Configurando ambiente Python...${NC}"
cd python

if [ ! -d "venv" ]; then
    echo "Criando ambiente virtual Python..."
    python3 -m venv venv
fi

echo "Ativando ambiente virtual..."
source venv/bin/activate

echo "Instalando dependências Python..."
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}✅ Python configurado${NC}"
cd ..

# 2. Configura PostgreSQL
echo -e "${YELLOW}🗄️  Configurando PostgreSQL...${NC}"
echo "Por favor, certifique-se de que o PostgreSQL está instalado e rodando."
echo "Execute o seguinte comando para criar o banco de dados:"
echo ""
echo "  psql -U postgres -c 'CREATE DATABASE jurispilot;'"
echo ""
echo "Depois, execute o schema:"
echo "  psql -U postgres -d jurispilot -f database/schema.sql"
echo ""
echo "E os seeds:"
echo "  psql -U postgres -d jurispilot -f database/seeds/checklists_seed.sql"
echo ""

# 3. Configura n8n
echo -e "${YELLOW}⚙️  Configurando n8n...${NC}"
if ! command -v n8n &> /dev/null; then
    echo "n8n não encontrado. Instalando..."
    npm install -g n8n
fi

echo "Criando diretório de dados do n8n..."
mkdir -p ~/.n8n

echo -e "${GREEN}✅ n8n configurado${NC}"

# 4. Cria diretórios de storage
echo -e "${YELLOW}📁 Criando diretórios de storage...${NC}"
mkdir -p storage/documents
mkdir -p storage/uploads
chmod 755 storage/documents
chmod 755 storage/uploads

echo -e "${GREEN}✅ Diretórios criados${NC}"

# 5. Cria arquivo .env de exemplo
echo -e "${YELLOW}📝 Criando arquivo .env de exemplo...${NC}"
if [ ! -f ".env" ]; then
    cat > .env << EOF
# JurisPilot - Variáveis de Ambiente

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=jurispilot
DB_USER=postgres
DB_PASSWORD=your_password_here

# n8n
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http

# Storage
STORAGE_PATH=./storage

# WhatsApp API (quando configurado)
WHATSAPP_API_URL=
WHATSAPP_API_KEY=

# Google Calendar (quando configurado)
GOOGLE_CALENDAR_CLIENT_ID=
GOOGLE_CALENDAR_CLIENT_SECRET=

# Tesseract OCR (opcional)
TESSERACT_PATH=
EOF
    echo -e "${GREEN}✅ Arquivo .env criado. Configure as variáveis necessárias.${NC}"
else
    echo "Arquivo .env já existe."
fi

echo ""
echo -e "${GREEN}✨ Setup concluído!${NC}"
echo ""
echo "Próximos passos:"
echo "1. Configure o arquivo .env com suas credenciais"
echo "2. Crie o banco de dados PostgreSQL e execute o schema"
echo "3. Execute os seeds do banco de dados"
echo "4. Inicie o n8n: n8n start"
echo "5. Importe os workflows do diretório n8n/workflows"
echo ""

