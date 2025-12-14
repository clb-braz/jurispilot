#!/bin/bash
# ============================================
# JurisPilot - Script de Setup Principal
# ============================================
# Este script configura o ambiente completo do JurisPilot
# Execute após clonar o repositório: ./scripts/setup.sh
# Compatível com: macOS, Linux
# ============================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Funções de output
write_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

write_error() {
    echo -e "${RED}❌ $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

write_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

write_step() {
    echo -e "\n${MAGENTA}📋 $1${NC}"
}

# Verifica se está no diretório correto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$PROJECT_ROOT/python" ] || [ ! -d "$PROJECT_ROOT/n8n" ] || [ ! -d "$PROJECT_ROOT/database" ]; then
    write_error "Execute este script a partir do diretório raiz do JurisPilot"
    write_info "Navegue até o diretório do projeto e execute: ./scripts/setup.sh"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "\n${CYAN}🚀 JurisPilot - Configuração do Ambiente${NC}"
echo -e "${CYAN}========================================\n${NC}"

# ============================================
# 1. Verificar Pré-requisitos
# ============================================
write_step "Verificando pré-requisitos..."

PREREQUISITES_OK=true

# Verifica PostgreSQL
if command -v psql &> /dev/null; then
    PG_VERSION=$(psql --version | head -n1)
    write_success "PostgreSQL encontrado: $PG_VERSION"
else
    write_warning "PostgreSQL não encontrado. Instale PostgreSQL 12+"
    PREREQUISITES_OK=false
fi

# Verifica Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    write_success "Python encontrado: $PYTHON_VERSION"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    write_success "Python encontrado: $PYTHON_VERSION"
    PYTHON_CMD="python"
else
    write_warning "Python não encontrado. Instale Python 3.8+"
    PREREQUISITES_OK=false
fi

# Define comando Python
if [ -z "$PYTHON_CMD" ]; then
    PYTHON_CMD="python3"
fi

# Verifica Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    write_success "Node.js encontrado: $NODE_VERSION"
else
    write_warning "Node.js não encontrado. Instale Node.js 16+"
    PREREQUISITES_OK=false
fi

# Verifica npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    write_success "npm encontrado: v$NPM_VERSION"
else
    write_warning "npm não encontrado"
    PREREQUISITES_OK=false
fi

# Verifica n8n
if command -v n8n &> /dev/null; then
    N8N_VERSION=$(n8n --version 2>/dev/null || echo "installed")
    write_success "n8n encontrado: $N8N_VERSION"
else
    write_info "n8n não encontrado. Instalando..."
    if npm install -g n8n; then
        write_success "n8n instalado com sucesso"
    else
        write_warning "Falha ao instalar n8n. Execute manualmente: npm install -g n8n"
    fi
fi

# Resumo de pré-requisitos
echo ""
write_info "Resumo de pré-requisitos:"
if [ "$PREREQUISITES_OK" = true ]; then
    write_success "Todos os pré-requisitos estão instalados"
else
    write_warning "Alguns pré-requisitos estão faltando"
fi

# ============================================
# 2. Configurar arquivo .env
# ============================================
write_step "Configurando arquivo .env..."

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
        write_success "Arquivo .env criado a partir de .env.example"
        write_warning "IMPORTANTE: Configure as variáveis no arquivo .env antes de continuar"
    else
        write_error "Arquivo .env.example não encontrado"
        exit 1
    fi
else
    write_info "Arquivo .env já existe"
fi

# ============================================
# 3. Configurar Python
# ============================================
write_step "Configurando ambiente Python..."

cd "$PROJECT_ROOT/python"

# Cria ambiente virtual se não existir
if [ ! -d "venv" ]; then
    write_info "Criando ambiente virtual Python..."
    $PYTHON_CMD -m venv venv
    if [ $? -ne 0 ]; then
        write_error "Falha ao criar ambiente virtual Python"
        exit 1
    fi
    write_success "Ambiente virtual criado"
fi

# Ativa ambiente virtual
write_info "Ativando ambiente virtual..."
source venv/bin/activate

# Atualiza pip
write_info "Atualizando pip..."
pip install --upgrade pip --quiet

# Instala dependências
write_info "Instalando dependências Python..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    if [ $? -eq 0 ]; then
        write_success "Dependências Python instaladas"
    else
        write_error "Falha ao instalar dependências Python"
        exit 1
    fi
else
    write_warning "Arquivo requirements.txt não encontrado"
fi

deactivate
cd "$PROJECT_ROOT"

# ============================================
# 4. Criar diretórios de storage
# ============================================
write_step "Criando diretórios de storage..."

DIRECTORIES=(
    "storage/documents"
    "storage/uploads"
    "logs"
    "backups"
)

for dir in "${DIRECTORIES[@]}"; do
    FULL_PATH="$PROJECT_ROOT/$dir"
    if [ ! -d "$FULL_PATH" ]; then
        mkdir -p "$FULL_PATH"
        write_success "Diretório criado: $dir"
    else
        write_info "Diretório já existe: $dir"
    fi
done

# ============================================
# 5. Configurar banco de dados (se não pular)
# ============================================
if [ "$1" != "--skip-database" ]; then
    write_step "Configurando banco de dados PostgreSQL..."
    
    if command -v psql &> /dev/null; then
        write_info "Execute o script de setup do banco de dados:"
        echo -e "${YELLOW}  ./scripts/setup-database.sh${NC}"
    else
        write_warning "PostgreSQL não encontrado. Configure manualmente após instalar."
    fi
else
    write_info "Pulando configuração do banco de dados (--skip-database)"
fi

# ============================================
# 6. Configurar n8n (se não pular)
# ============================================
if [ "$1" != "--skip-n8n" ]; then
    write_step "Configurando n8n..."
    
    if command -v n8n &> /dev/null; then
        write_info "n8n está instalado. Para importar workflows, execute:"
        echo -e "${YELLOW}  ./scripts/import-workflows.sh${NC}"
        write_info "Certifique-se de que o n8n está rodando antes de importar workflows"
    else
        write_warning "n8n não encontrado. Instale com: npm install -g n8n"
    fi
else
    write_info "Pulando configuração do n8n (--skip-n8n)"
fi

# ============================================
# Resumo Final
# ============================================
echo -e "\n${GREEN}✨ Setup concluído!\n${NC}"
echo -e "${CYAN}Próximos passos:${NC}"
echo "  1. Configure o arquivo .env com suas credenciais"
echo "  2. Execute: ./scripts/setup-database.sh (para configurar PostgreSQL)"
echo "  3. Inicie o n8n: n8n start"
echo "  4. Execute: ./scripts/import-workflows.sh (para importar workflows)"
echo "  5. Inicie a API Python: ./scripts/start-api.sh"
echo "  6. Execute: ./scripts/test-workflows.sh (para testar o sistema)"
echo ""
echo -e "${CYAN}📚 Documentação completa: docs/CONFIGURACAO_COMPLETA.md${NC}"
echo ""
