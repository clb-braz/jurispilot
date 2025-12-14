# 🚀 JurisPilot - Guia Rápido

Este guia te ajuda a configurar o JurisPilot em **5 minutos**.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- ✅ **PostgreSQL 12+** - [Download](https://www.postgresql.org/download/)
- ✅ **Python 3.8+** - [Download](https://www.python.org/downloads/)
- ✅ **Node.js 16+** - [Download](https://nodejs.org/)
- ✅ **Git** - [Download](https://git-scm.com/)

## Passo 1: Clonar o Repositório

```bash
git clone https://github.com/clb-braz/jurispilot.git
cd jurispilot
```

## Passo 2: Configurar Variáveis de Ambiente

### Windows PowerShell
```powershell
Copy-Item .env.example .env
```

### Mac/Linux
```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure pelo menos:
- `DB_PASSWORD` - Senha do PostgreSQL
- `DB_USER` - Usuário do PostgreSQL (padrão: postgres)

## Passo 3: Executar Setup

### Windows PowerShell
```powershell
.\scripts\setup.ps1
```

### Mac/Linux
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

**Ou use o wrapper universal:**
```bash
./scripts/setup
```

Este script irá:
- ✅ Verificar pré-requisitos
- ✅ Criar ambiente virtual Python
- ✅ Instalar dependências
- ✅ Criar diretórios necessários

## Passo 4: Configurar Banco de Dados

### Windows PowerShell
```powershell
.\scripts\setup-database.ps1
```

### Mac/Linux
```bash
./scripts/setup-database.sh
```

Este script irá:
- ✅ Criar banco de dados `jurispilot`
- ✅ Executar schema SQL
- ✅ Popular dados iniciais (checklists)

## Passo 5: Iniciar n8n

```bash
n8n start
```

Acesse: http://localhost:5678

## Passo 6: Importar Workflows

Em outro terminal, execute:

### Windows PowerShell
```powershell
.\scripts\import-workflows.ps1
```

### Mac/Linux
```bash
./scripts/import-workflows.sh
```

## Passo 7: Iniciar API Python

Em outro terminal, execute:

### Windows PowerShell
```powershell
.\scripts\start-api.ps1
```

### Mac/Linux
```bash
./scripts/start-api.sh
```

A API estará disponível em: http://localhost:5000

## Passo 8: Verificar Saúde do Sistema

### Windows PowerShell
```powershell
.\scripts\health-check.ps1
```

### Mac/Linux
```bash
./scripts/health-check.sh
```

## ✅ Pronto!

O sistema está configurado e rodando. Acesse:

- **n8n**: http://localhost:5678
- **API Python**: http://localhost:5000
- **Health Check**: http://localhost:5000/health

## Guias por Plataforma

- 🪟 [Instalação no Windows](docs/INSTALACAO_WINDOWS.md)
- 🍎 [Instalação no macOS](docs/INSTALACAO_MAC.md)
- 🐧 [Instalação no Linux](docs/INSTALACAO_LINUX.md)

## Próximos Passos

1. 📖 Leia a [Documentação Completa](docs/CONFIGURACAO_COMPLETA.md)
2. 🔗 Configure [Integrações](docs/INTEGRACOES.md) (WhatsApp, Google Calendar)
3. 🧪 Execute [Testes](scripts/test-workflows.ps1) do sistema

## Problemas?

Consulte a seção de **Troubleshooting** na [Documentação Completa](docs/CONFIGURACAO_COMPLETA.md) ou nos guias específicos por plataforma.

---

**JurisPilot** - Automação Jurídica Operacional
