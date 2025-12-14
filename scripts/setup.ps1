# ============================================
# JurisPilot - Script de Setup Principal
# ============================================
# Este script configura o ambiente completo do JurisPilot
# Execute após clonar o repositório: .\scripts\setup.ps1
# ============================================

param(
    [switch]$SkipDatabase,
    [switch]$SkipN8N,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Cores para output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️  $Message" "Cyan"
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n📋 $Message" "Magenta"
}

# Verifica se está no diretório correto
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$projectRoot\python") -or -not (Test-Path "$projectRoot\n8n") -or -not (Test-Path "$projectRoot\database")) {
    Write-Error "Execute este script a partir do diretório raiz do JurisPilot"
    Write-Info "Navegue até D:\JurisPilot e execute: .\scripts\setup.ps1"
    exit 1
}

Set-Location $projectRoot

Write-ColorOutput "`n🚀 JurisPilot - Configuração do Ambiente" "Cyan"
Write-ColorOutput "========================================`n" "Cyan"

# ============================================
# 1. Verificar Pré-requisitos
# ============================================
Write-Step "Verificando pré-requisitos..."

$prerequisites = @{
    "PostgreSQL" = $false
    "Python" = $false
    "Node.js" = $false
    "n8n" = $false
}

# Verifica PostgreSQL
try {
    $pgVersion = & psql --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $prerequisites["PostgreSQL"] = $true
        Write-Success "PostgreSQL encontrado: $($pgVersion -split "`n" | Select-Object -First 1)"
    }
} catch {
    Write-Warning "PostgreSQL não encontrado. Instale PostgreSQL 12+"
}

# Verifica Python
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $prerequisites["Python"] = $true
        Write-Success "Python encontrado: $pythonVersion"
    }
} catch {
    Write-Warning "Python não encontrado. Instale Python 3.8+"
}

# Verifica Node.js
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $prerequisites["Node.js"] = $true
        Write-Success "Node.js encontrado: $nodeVersion"
    }
} catch {
    Write-Warning "Node.js não encontrado. Instale Node.js 16+"
}

# Verifica n8n
try {
    $n8nVersion = n8n --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $prerequisites["n8n"] = $true
        Write-Success "n8n encontrado: $n8nVersion"
    } else {
        Write-Info "n8n não encontrado. Instalando..."
        npm install -g n8n
        if ($LASTEXITCODE -eq 0) {
            $prerequisites["n8n"] = $true
            Write-Success "n8n instalado com sucesso"
        }
    }
} catch {
    Write-Warning "n8n não encontrado. Execute: npm install -g n8n"
}

# Resumo de pré-requisitos
Write-Info "`nResumo de pré-requisitos:"
foreach ($prereq in $prerequisites.GetEnumerator()) {
    $status = if ($prereq.Value) { "✅" } else { "❌" }
    Write-Host "  $status $($prereq.Key)"
}

# ============================================
# 2. Configurar arquivo .env
# ============================================
Write-Step "Configurando arquivo .env..."

if (-not (Test-Path "$projectRoot\.env")) {
    if (Test-Path "$projectRoot\.env.example") {
        Copy-Item "$projectRoot\.env.example" "$projectRoot\.env"
        Write-Success "Arquivo .env criado a partir de .env.example"
        Write-Warning "IMPORTANTE: Configure as variáveis no arquivo .env antes de continuar"
    } else {
        Write-Error "Arquivo .env.example não encontrado"
        exit 1
    }
} else {
    Write-Info "Arquivo .env já existe"
}

# ============================================
# 3. Configurar Python
# ============================================
Write-Step "Configurando ambiente Python..."

Set-Location "$projectRoot\python"

# Cria ambiente virtual se não existir
if (-not (Test-Path "venv")) {
    Write-Info "Criando ambiente virtual Python..."
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao criar ambiente virtual Python"
        exit 1
    }
    Write-Success "Ambiente virtual criado"
}

# Ativa ambiente virtual
Write-Info "Ativando ambiente virtual..."
& ".\venv\Scripts\Activate.ps1"

# Atualiza pip
Write-Info "Atualizando pip..."
python -m pip install --upgrade pip --quiet

# Instala dependências
Write-Info "Instalando dependências Python..."
if (Test-Path "requirements.txt") {
    pip install -r requirements.txt
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependências Python instaladas"
    } else {
        Write-Error "Falha ao instalar dependências Python"
        exit 1
    }
} else {
    Write-Warning "Arquivo requirements.txt não encontrado"
}

Set-Location $projectRoot

# ============================================
# 4. Criar diretórios de storage
# ============================================
Write-Step "Criando diretórios de storage..."

$directories = @(
    "storage\documents",
    "storage\uploads",
    "logs",
    "backups"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Success "Diretório criado: $dir"
    } else {
        Write-Info "Diretório já existe: $dir"
    }
}

# ============================================
# 5. Configurar banco de dados (se não pular)
# ============================================
if (-not $SkipDatabase) {
    Write-Step "Configurando banco de dados PostgreSQL..."
    
    if ($prerequisites["PostgreSQL"]) {
        Write-Info "Execute o script de setup do banco de dados:"
        Write-ColorOutput "  .\scripts\setup-database.ps1" "Yellow"
    } else {
        Write-Warning "PostgreSQL não encontrado. Configure manualmente após instalar."
    }
} else {
    Write-Info "Pulando configuração do banco de dados (--SkipDatabase)"
}

# ============================================
# 6. Configurar n8n (se não pular)
# ============================================
if (-not $SkipN8N) {
    Write-Step "Configurando n8n..."
    
    if ($prerequisites["n8n"]) {
        Write-Info "n8n está instalado. Para importar workflows, execute:"
        Write-ColorOutput "  .\scripts\import-workflows.ps1" "Yellow"
        Write-Info "Certifique-se de que o n8n está rodando antes de importar workflows"
    } else {
        Write-Warning "n8n não encontrado. Instale com: npm install -g n8n"
    }
} else {
    Write-Info "Pulando configuração do n8n (--SkipN8N)"
}

# ============================================
# Resumo Final
# ============================================
Write-ColorOutput "`n✨ Setup concluído!`n" "Green"
Write-ColorOutput "Próximos passos:" "Cyan"
Write-Host "  1. Configure o arquivo .env com suas credenciais"
Write-Host "  2. Execute: .\scripts\setup-database.ps1 (para configurar PostgreSQL)"
Write-Host "  3. Inicie o n8n: n8n start"
Write-Host "  4. Execute: .\scripts\import-workflows.ps1 (para importar workflows)"
Write-Host "  5. Inicie a API Python: .\scripts\start-api.ps1"
Write-Host "  6. Execute: .\scripts\test-workflows.ps1 (para testar o sistema)"
Write-Host ""
Write-ColorOutput "📚 Documentação completa: docs\CONFIGURACAO_COMPLETA.md" "Cyan"
Write-Host ""
