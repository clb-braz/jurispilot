# ============================================
# JurisPilot - Iniciar API Python
# ============================================
# Este script inicia o servidor Flask da API
# Execute: .\scripts\start-api.ps1
# ============================================

param(
    [switch]$Production,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Cores para output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success { param([string]$Message) Write-ColorOutput "✅ $Message" "Green" }
function Write-Error { param([string]$Message) Write-ColorOutput "❌ $Message" "Red" }
function Write-Info { param([string]$Message) Write-ColorOutput "ℹ️  $Message" "Cyan" }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-ColorOutput "`n🚀 JurisPilot - Iniciando API Python`n" "Cyan"

# Verifica ambiente virtual
$venvPath = "$projectRoot\python\venv"
if (-not (Test-Path $venvPath)) {
    Write-Error "Ambiente virtual não encontrado. Execute: .\scripts\setup.ps1"
    exit 1
}

# Ativa ambiente virtual
& "$venvPath\Scripts\Activate.ps1"

# Verifica se api_server.py existe
$apiPath = "$projectRoot\python\src\api_server.py"
if (-not (Test-Path $apiPath)) {
    Write-Error "api_server.py não encontrado: $apiPath"
    exit 1
}

# Inicia servidor
Write-Info "Iniciando servidor Flask..."
Write-Info "API estará disponível em: http://localhost:5000"
Write-Info "Pressione Ctrl+C para parar`n"

if ($Production) {
    # Produção com gunicorn
    $gunicornPath = "$venvPath\Scripts\gunicorn.exe"
    if (Test-Path $gunicornPath) {
        & python -m gunicorn -w 4 -b 0.0.0.0:5000 "src.api_server:app"
    } else {
        Write-Error "gunicorn não encontrado. Instale com: pip install gunicorn"
        exit 1
    }
} else {
    # Desenvolvimento com Flask
    Set-Location "$projectRoot\python"
    & python src\api_server.py
}

