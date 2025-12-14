# 📚 JurisPilot - Configuração Completa

Guia passo a passo completo para configurar o sistema JurisPilot do zero.

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Instalação Inicial](#instalação-inicial)
3. [Configuração do Banco de Dados](#configuração-do-banco-de-dados)
4. [Configuração do Python](#configuração-do-python)
5. [Configuração do n8n](#configuração-do-n8n)
6. [Configuração da API](#configuração-da-api)
7. [Integrações](#integrações)
8. [Validação e Testes](#validação-e-testes)
9. [Troubleshooting](#troubleshooting)

---

## Pré-requisitos

### Software Necessário

#### 1. PostgreSQL 12+

**Windows:**
- Download: https://www.postgresql.org/download/windows/
- Use o instalador oficial
- Marque "Add PostgreSQL to PATH" durante instalação

**macOS:**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Linux (Fedora/CentOS):**
```bash
sudo dnf install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
```

**Verificar instalação:**
```bash
psql --version
```

**Guias específicos:**
- 🪟 [Instalação Windows](INSTALACAO_WINDOWS.md)
- 🍎 [Instalação macOS](INSTALACAO_MAC.md)
- 🐧 [Instalação Linux](INSTALACAO_LINUX.md)

#### 2. Python 3.8+

**Windows:**
- Download: https://www.python.org/downloads/
- ✅ **IMPORTANTE**: Marque "Add Python to PATH" durante instalação

**macOS:**
```bash
brew install python@3.11
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install python3 python3-pip python3-venv

# Fedora/CentOS
sudo dnf install python3 python3-pip
```

**Verificar instalação:**
```bash
# Windows
python --version

# Mac/Linux
python3 --version
```

#### 3. Node.js 16+

**Windows:**
- Download: https://nodejs.org/
- Instale a versão LTS

**macOS:**
```bash
brew install node
```

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Fedora/CentOS
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs
```

**Verificar instalação:**
```bash
node --version
npm --version
```

#### 4. Git

**Windows:**
- Download: https://git-scm.com/download/win

**macOS:**
```bash
brew install git
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install git

# Fedora/CentOS
sudo dnf install git
```

---

## Instalação Inicial

### 1. Clonar Repositório

```bash
git clone https://github.com/clb-braz/jurispilot.git
cd jurispilot
```

### 2. Configurar Variáveis de Ambiente

Copie o arquivo de exemplo:

**Windows PowerShell:**
```powershell
Copy-Item .env.example .env
```

**Mac/Linux:**
```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações. **Mínimo necessário:**

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=jurispilot
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui
```

### 3. Executar Setup Inicial

**Windows PowerShell:**
```powershell
.\scripts\setup.ps1
```

**Mac/Linux:**
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Ou use o wrapper universal (detecta OS automaticamente):**
```bash
./scripts/setup
```

Este script:
- ✅ Verifica pré-requisitos
- ✅ Cria ambiente virtual Python
- ✅ Instala dependências Python
- ✅ Cria diretórios de storage
- ✅ Valida arquivo .env

---

## Configuração do Banco de Dados

### 1. Executar Setup do Banco

**Windows PowerShell:**
```powershell
.\scripts\setup-database.ps1
```

**Mac/Linux:**
```bash
./scripts/setup-database.sh
```

O script irá:
- Verificar conexão com PostgreSQL
- Criar banco de dados `jurispilot`
- Executar `database/schema.sql`
- Executar `database/seeds/checklists_seed.sql`
- Validar criação das tabelas

### 2. Verificar Banco de Dados

**Windows PowerShell:**
```powershell
.\scripts\test-database.ps1
```

**Mac/Linux:**
```bash
./scripts/test-database.sh
```

### 3. Estrutura do Banco

O banco de dados contém as seguintes tabelas:

- `clientes` - Dados dos clientes
- `casos` - Informações dos casos jurídicos
- `checklists_juridicos` - Templates de checklists
- `checklists_caso` - Instâncias de checklists por caso
- `documentos` - Documentos processados
- `prazos` - Controle de prazos
- `linha_tempo` - Eventos cronológicos
- `resumos_juridicos` - Resumos gerados
- `auditoria_operacional` - Métricas operacionais

---

## Configuração do Python

### 1. Ambiente Virtual

O ambiente virtual é criado automaticamente pelo script de setup. Se precisar criar manualmente:

**Windows PowerShell:**
```powershell
cd python
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**Mac/Linux:**
```bash
cd python
python3 -m venv venv
source venv/bin/activate
```

### 2. Instalar Dependências

```bash
pip install -r requirements.txt
```

### 3. Dependências Principais

- **Flask** - Servidor web da API
- **psycopg2** - Driver PostgreSQL
- **PyPDF2** - Processamento de PDFs
- **python-docx** - Processamento de Word
- **pytesseract** - OCR para imagens
- **spacy** - Processamento de linguagem natural

---

## Configuração do n8n

### 1. Instalar n8n

```bash
npm install -g n8n
```

### 2. Iniciar n8n

```bash
n8n start
```

Acesse: http://localhost:5678

**Primeira vez:** Crie um usuário administrador.

### 3. Importar Workflows

**Windows PowerShell:**
```powershell
.\scripts\import-workflows.ps1
```

**Mac/Linux:**
```bash
./scripts/import-workflows.sh
```

Este script importa todos os workflows de `n8n/workflows/`.

### 4. Configurar Credenciais

No n8n, configure as credenciais:

1. **PostgreSQL**: Use as mesmas credenciais do `.env`
2. **WhatsApp**: Se configurado (ver [Integrações](#integrações))
3. **Google Calendar**: Se configurado (ver [Integrações](#integrações))

---

## Configuração da API

### 1. Iniciar API em Desenvolvimento

**Windows PowerShell:**
```powershell
.\scripts\start-api.ps1
```

**Mac/Linux:**
```bash
./scripts/start-api.sh
```

A API estará disponível em: http://localhost:5000

### 2. Iniciar API em Produção

**Windows PowerShell:**
```powershell
.\scripts\start-api.ps1 -Production
```

**Mac/Linux:**
```bash
./scripts/start-api.sh --production
```

Usa gunicorn com 4 workers.

### 3. Endpoints Disponíveis

- `GET /health` - Health check
- `POST /api/process-document` - Processa documento
- `POST /api/classify-proof` - Classifica prova
- `POST /api/generate-summary` - Gera resumo jurídico
- `POST /api/extract-deadlines` - Extrai prazos
- `POST /api/generate-checklist` - Gera checklist
- `POST /api/generate-timeline` - Gera linha do tempo

---

## Integrações

### WhatsApp

Consulte: [docs/INTEGRACOES.md](INTEGRACOES.md#whatsapp)

### Google Calendar

Consulte: [docs/INTEGRACOES.md](INTEGRACOES.md#google-calendar)

### Email SMTP

Configure no `.env`:

```env
EMAIL_ENABLED=true
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USER=seu_email@gmail.com
EMAIL_SMTP_PASSWORD=sua_senha_de_app
EMAIL_SMTP_TLS=true
EMAIL_FROM_ADDRESS=noreply@jurispilot.com.br
```

---

## Validação e Testes

### 1. Teste Completo do Sistema

**Windows PowerShell:**
```powershell
.\scripts\test-workflows.ps1
```

**Mac/Linux:**
```bash
./scripts/test-workflows.sh
```

### 2. Teste do Banco de Dados

**Windows PowerShell:**
```powershell
.\scripts\test-database.ps1
```

**Mac/Linux:**
```bash
./scripts/test-database.sh
```

### 3. Health Check

**Windows PowerShell:**
```powershell
.\scripts\health-check.ps1
```

**Mac/Linux:**
```bash
./scripts/health-check.sh
```

### 4. Verificar API

```bash
curl http://localhost:5000/health
```

Resposta esperada:
```json
{
  "status": "healthy",
  "service": "JurisPilot API",
  "version": "1.0.0"
}
```

---

## Troubleshooting

### Problema: PostgreSQL não conecta

**Solução:**
1. Verifique se PostgreSQL está rodando: `pg_isready`
2. Verifique credenciais no `.env`
3. Verifique firewall/porta 5432

### Problema: n8n não inicia

**Solução:**
1. Verifique se Node.js está instalado: `node --version`
2. Reinstale n8n: `npm install -g n8n`
3. Verifique porta 5678 disponível

### Problema: API Python não inicia

**Solução Windows:**
1. Ative ambiente virtual: `.\python\venv\Scripts\Activate.ps1`
2. Verifique dependências: `pip list`
3. Reinstale dependências: `pip install -r requirements.txt`

**Solução Mac/Linux:**
1. Ative ambiente virtual: `source python/venv/bin/activate`
2. Verifique dependências: `pip list`
3. Reinstale dependências: `pip install -r requirements.txt`

### Problema: Workflows não importam

**Solução:**
1. Certifique-se que n8n está rodando
2. Verifique autenticação no script `import-workflows.ps1`
3. Importe manualmente via interface do n8n

### Problema: Erro de encoding

**Solução Windows:**
1. Certifique-se que arquivos estão em UTF-8
2. Use PowerShell com encoding UTF-8: `chcp 65001`

**Solução Mac/Linux:**
1. Certifique-se que arquivos estão em UTF-8
2. Configure locale: `export LC_ALL=en_US.UTF-8`

---

## Backup e Restauração

### Backup Manual

**Windows PowerShell:**
```powershell
.\scripts\backup-database.ps1
```

**Mac/Linux:**
```bash
./scripts/backup-database.sh
```

**Com compressão:**
```bash
./scripts/backup-database.sh --compress
```

### Restaurar Backup

```bash
psql -U postgres -d jurispilot < backup.sql
```

---

## Próximos Passos

1. ✅ Configure [Integrações](INTEGRACOES.md)
2. ✅ Personalize workflows no n8n
3. ✅ Configure notificações
4. ✅ Teste fluxos end-to-end
5. ✅ Configure backup automático

## Guias por Plataforma

Para instruções detalhadas específicas da sua plataforma:

- 🪟 [Instalação no Windows](INSTALACAO_WINDOWS.md)
- 🍎 [Instalação no macOS](INSTALACAO_MAC.md)
- 🐧 [Instalação no Linux](INSTALACAO_LINUX.md)

---

**JurisPilot** - Automação Jurídica Operacional
