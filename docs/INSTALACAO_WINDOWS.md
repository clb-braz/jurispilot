# 🪟 JurisPilot - Instalação no Windows

Guia completo para instalar e configurar o JurisPilot no Windows.

## Pré-requisitos

### 1. PostgreSQL 12+

**Download**: https://www.postgresql.org/download/windows/

1. Baixe o instalador oficial
2. Execute o instalador
3. Durante a instalação:
   - Anote a senha do usuário `postgres` (você precisará dela)
   - Deixe a porta padrão: `5432`
   - Marque "Add PostgreSQL to PATH" (importante!)
4. Após instalação, reinicie o terminal

**Verificar instalação:**
```powershell
psql --version
```

### 2. Python 3.8+

**Download**: https://www.python.org/downloads/

1. Baixe a versão mais recente do Python 3.8+
2. Durante a instalação:
   - ✅ **IMPORTANTE**: Marque "Add Python to PATH"
   - Escolha "Install for all users" (opcional)
3. Após instalação, reinicie o terminal

**Verificar instalação:**
```powershell
python --version
```

### 3. Node.js 16+

**Download**: https://nodejs.org/

1. Baixe a versão LTS
2. Execute o instalador (padrão)
3. Após instalação, reinicie o terminal

**Verificar instalação:**
```powershell
node --version
npm --version
```

### 4. Git (Opcional)

**Download**: https://git-scm.com/download/win

## Instalação

### Passo 1: Clonar Repositório

```powershell
git clone https://github.com/clb-braz/jurispilot.git
cd jurispilot
```

Ou baixe o ZIP e extraia.

### Passo 2: Configurar Variáveis de Ambiente

```powershell
Copy-Item .env.example .env
```

Edite o arquivo `.env` com suas credenciais:
- `DB_PASSWORD` - Senha do PostgreSQL que você definiu na instalação
- `DB_USER` - Geralmente `postgres`

### Passo 3: Executar Setup

```powershell
.\scripts\setup.ps1
```

Este script irá:
- ✅ Verificar pré-requisitos
- ✅ Criar ambiente virtual Python
- ✅ Instalar dependências Python
- ✅ Criar diretórios necessários

### Passo 4: Configurar Banco de Dados

```powershell
.\scripts\setup-database.ps1
```

O script irá solicitar a senha do PostgreSQL e:
- ✅ Criar banco de dados `jurispilot`
- ✅ Executar schema SQL
- ✅ Popular dados iniciais

### Passo 5: Instalar n8n

```powershell
npm install -g n8n
```

### Passo 6: Iniciar n8n

Abra um novo terminal PowerShell:

```powershell
n8n start
```

Acesse: http://localhost:5678

**Primeira vez**: Crie um usuário administrador.

### Passo 7: Importar Workflows

Em outro terminal:

```powershell
.\scripts\import-workflows.ps1
```

### Passo 8: Iniciar API Python

Em outro terminal:

```powershell
.\scripts\start-api.ps1
```

A API estará disponível em: http://localhost:5000

## Verificação

Execute o health check:

```powershell
.\scripts\health-check.ps1
```

## Troubleshooting Windows

### Problema: "psql não é reconhecido"

**Solução:**
1. Adicione PostgreSQL ao PATH manualmente:
   - Vá em: Configurações > Sistema > Variáveis de Ambiente
   - Adicione: `C:\Program Files\PostgreSQL\14\bin` (ajuste a versão)
2. Reinicie o terminal

### Problema: "python não é reconhecido"

**Solução:**
1. Reinstale Python marcando "Add Python to PATH"
2. Ou adicione manualmente ao PATH: `C:\Python39` (ajuste a versão)

### Problema: Scripts PowerShell bloqueados

**Solução:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problema: Erro de encoding

**Solução:**
```powershell
chcp 65001
```

## Próximos Passos

1. 📖 Leia a [Documentação Completa](CONFIGURACAO_COMPLETA.md)
2. 🔗 Configure [Integrações](INTEGRACOES.md)
3. 🧪 Execute testes: `.\scripts\test-workflows.ps1`

---

**JurisPilot** - Automação Jurídica Operacional

