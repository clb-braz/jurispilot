# 🍎 JurisPilot - Instalação no macOS

Guia completo para instalar e configurar o JurisPilot no macOS.

## Pré-requisitos

### 1. Homebrew (Recomendado)

Se você ainda não tem o Homebrew instalado:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. PostgreSQL 12+

```bash
brew install postgresql@14
brew services start postgresql@14
```

**Verificar instalação:**
```bash
psql --version
```

**Configurar PostgreSQL:**
```bash
# Criar banco de dados padrão (se necessário)
createdb $(whoami)
```

### 3. Python 3.8+

O macOS geralmente já vem com Python, mas recomendamos usar Homebrew:

```bash
brew install python@3.11
```

**Verificar instalação:**
```bash
python3 --version
```

### 4. Node.js 16+

```bash
brew install node
```

**Verificar instalação:**
```bash
node --version
npm --version
```

### 5. Git

Geralmente já está instalado. Se não:

```bash
brew install git
```

## Instalação

### Passo 1: Clonar Repositório

```bash
git clone https://github.com/clb-braz/jurispilot.git
cd jurispilot
```

### Passo 2: Configurar Variáveis de Ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais:
- `DB_PASSWORD` - Deixe vazio se não configurou senha (padrão do Homebrew)
- `DB_USER` - Geralmente seu nome de usuário do Mac

### Passo 3: Executar Setup

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

Este script irá:
- ✅ Verificar pré-requisitos
- ✅ Criar ambiente virtual Python
- ✅ Instalar dependências Python
- ✅ Criar diretórios necessários

### Passo 4: Configurar Banco de Dados

```bash
./scripts/setup-database.sh
```

O script irá:
- ✅ Criar banco de dados `jurispilot`
- ✅ Executar schema SQL
- ✅ Popular dados iniciais

**Nota**: Se não configurou senha no PostgreSQL, deixe em branco quando solicitado.

### Passo 5: Instalar n8n

```bash
npm install -g n8n
```

### Passo 6: Iniciar n8n

Abra um novo terminal:

```bash
n8n start
```

Acesse: http://localhost:5678

**Primeira vez**: Crie um usuário administrador.

### Passo 7: Importar Workflows

Em outro terminal:

```bash
./scripts/import-workflows.sh
```

### Passo 8: Iniciar API Python

Em outro terminal:

```bash
./scripts/start-api.sh
```

A API estará disponível em: http://localhost:5000

## Verificação

Execute o health check:

```bash
./scripts/health-check.sh
```

## Troubleshooting macOS

### Problema: "Permission denied" nos scripts

**Solução:**
```bash
chmod +x scripts/*.sh
```

### Problema: PostgreSQL não inicia

**Solução:**
```bash
brew services restart postgresql@14
```

### Problema: Python não encontrado

**Solução:**
```bash
# Verifique qual Python está sendo usado
which python3

# Se necessário, crie alias
echo 'alias python=python3' >> ~/.zshrc
source ~/.zshrc
```

### Problema: Porta 5432 já em uso

**Solução:**
```bash
# Verifique o que está usando a porta
lsof -i :5432

# Pare o serviço se necessário
brew services stop postgresql@14
```

### Problema: Erro com Homebrew no Apple Silicon (M1/M2)

**Solução:**
```bash
# Certifique-se de usar o Homebrew correto
arch -arm64 brew install postgresql@14
```

## Configurações Adicionais (Opcional)

### Tesseract OCR

```bash
brew install tesseract
```

O script detectará automaticamente.

### Configurar PostgreSQL para iniciar automaticamente

```bash
brew services start postgresql@14
```

## Próximos Passos

1. 📖 Leia a [Documentação Completa](CONFIGURACAO_COMPLETA.md)
2. 🔗 Configure [Integrações](INTEGRACOES.md)
3. 🧪 Execute testes: `./scripts/test-workflows.sh`

---

**JurisPilot** - Automação Jurídica Operacional

