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

```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/Mac
cp .env.example .env
```

Edite o arquivo `.env` e configure pelo menos:
- `DB_PASSWORD` - Senha do PostgreSQL
- `DB_USER` - Usuário do PostgreSQL (padrão: postgres)

## Passo 3: Executar Setup

```powershell
# Windows PowerShell
.\scripts\setup.ps1
```

Este script irá:
- ✅ Verificar pré-requisitos
- ✅ Criar ambiente virtual Python
- ✅ Instalar dependências
- ✅ Criar diretórios necessários

## Passo 4: Configurar Banco de Dados

```powershell
.\scripts\setup-database.ps1
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

```powershell
.\scripts\import-workflows.ps1
```

## Passo 7: Iniciar API Python

Em outro terminal, execute:

```powershell
.\scripts\start-api.ps1
```

A API estará disponível em: http://localhost:5000

## Passo 8: Verificar Saúde do Sistema

```powershell
.\scripts\health-check.ps1
```

## ✅ Pronto!

O sistema está configurado e rodando. Acesse:

- **n8n**: http://localhost:5678
- **API Python**: http://localhost:5000
- **Health Check**: http://localhost:5000/health

## Próximos Passos

1. 📖 Leia a [Documentação Completa](docs/CONFIGURACAO_COMPLETA.md)
2. 🔗 Configure [Integrações](docs/INTEGRACOES.md) (WhatsApp, Google Calendar)
3. 🧪 Execute [Testes](scripts/test-workflows.ps1) do sistema

## Problemas?

Consulte a seção de **Troubleshooting** na [Documentação Completa](docs/CONFIGURACAO_COMPLETA.md).

---

**JurisPilot** - Automação Jurídica Operacional

