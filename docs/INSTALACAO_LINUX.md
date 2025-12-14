# 🐧 JurisPilot - Instalação no Linux

Guia completo para instalar e configurar o JurisPilot no Linux (Ubuntu, Debian, Fedora).

## Pré-requisitos

### 1. PostgreSQL 12+

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**Verificar instalação:**
```bash
psql --version
```

**Configurar PostgreSQL:**
```bash
# Criar usuário (se necessário)
sudo -u postgres createuser --interactive

# Criar banco de dados para seu usuário
sudo -u postgres createdb $(whoami)
```

### 2. Python 3.8+

#### Ubuntu/Debian

```bash
sudo apt install python3 python3-pip python3-venv
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install python3 python3-pip
```

**Verificar instalação:**
```bash
python3 --version
pip3 --version
```

### 3. Node.js 16+

#### Ubuntu/Debian

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

#### Fedora/CentOS/RHEL

```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs
```

**Verificar instalação:**
```bash
node --version
npm --version
```

### 4. Git

#### Ubuntu/Debian

```bash
sudo apt install git
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install git
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
- `DB_PASSWORD` - Senha do PostgreSQL (ou deixe vazio se não configurou)
- `DB_USER` - Geralmente `postgres` ou seu usuário

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

**Nota**: Pode ser necessário usar `sudo -u postgres` para criar o banco.

### Passo 5: Instalar n8n

```bash
sudo npm install -g n8n
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

## Troubleshooting Linux

### Problema: "Permission denied" nos scripts

**Solução:**
```bash
chmod +x scripts/*.sh
```

### Problema: PostgreSQL não inicia

**Solução:**
```bash
# Ubuntu/Debian
sudo systemctl status postgresql
sudo systemctl start postgresql

# Fedora/CentOS
sudo systemctl status postgresql
sudo systemctl start postgresql
```

### Problema: Erro "peer authentication failed"

**Solução:**
Edite `/etc/postgresql/14/main/pg_hba.conf` (ajuste a versão):
```
local   all             all                                     peer
```
Mude para:
```
local   all             all                                     md5
```

Depois reinicie:
```bash
sudo systemctl restart postgresql
```

### Problema: Porta 5432 já em uso

**Solução:**
```bash
# Verifique o que está usando a porta
sudo lsof -i :5432

# Pare o serviço se necessário
sudo systemctl stop postgresql
```

### Problema: npm precisa de sudo

**Solução:**
Configure npm para instalar globalmente sem sudo:

```bash
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Configurações Adicionais (Opcional)

### Tesseract OCR

#### Ubuntu/Debian

```bash
sudo apt install tesseract-ocr
```

#### Fedora/CentOS/RHEL

```bash
sudo dnf install tesseract
```

O script detectará automaticamente.

### Firewall (se necessário)

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 5432/tcp
sudo ufw allow 5678/tcp
sudo ufw allow 5000/tcp

# Fedora/CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=5678/tcp
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

## Próximos Passos

1. 📖 Leia a [Documentação Completa](CONFIGURACAO_COMPLETA.md)
2. 🔗 Configure [Integrações](INTEGRACOES.md)
3. 🧪 Execute testes: `./scripts/test-workflows.sh`

---

**JurisPilot** - Automação Jurídica Operacional

