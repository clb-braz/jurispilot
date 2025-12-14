# ============================================
# JurisPilot - Health Check do Sistema
# ============================================
# Este script verifica a saúde de todos os componentes
# Execute: .\scripts\health-check.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Cores para output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success { param([string]$Message) Write-ColorOutput "✅ $Message" "Green" }
function Write-Error { param([string]$Message) Write-ColorOutput "❌ $Message" "Red" }
function Write-Warning { param([string]$Message) Write-ColorOutput "⚠️  $Message" "Yellow" }
function Write-Info { param([string]$Message) Write-ColorOutput "ℹ️  $Message" "Cyan" }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-ColorOutput "`n🏥 JurisPilot - Health Check" "Cyan"
Write-ColorOutput "============================`n" "Cyan"

$healthStatus = @{
    PostgreSQL = $false
    N8N = $false
    APIPython = $false
    Storage = $false
}

# ============================================
# 1. PostgreSQL
# ============================================
Write-Info "Verificando PostgreSQL..."

try {
    $pgVersion = & psql --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "PostgreSQL instalado"
        
        # Tenta conectar
        if (Test-Path "$projectRoot\.env") {
            Get-Content "$projectRoot\.env" | ForEach-Object {
                if ($_ -match '^\s*DB_(\w+)\s*=\s*(.*)$') {
                    $key = "DB_$($matches[1])"
                    $value = $matches[2].Trim()
                    [Environment]::SetEnvironmentVariable($key, $value, "Process")
                }
            }
            
            $dbHost = [Environment]::GetEnvironmentVariable("DB_HOST", "Process") ?? "localhost"
            $dbPort = [Environment]::GetEnvironmentVariable("DB_PORT", "Process") ?? "5432"
            $dbName = [Environment]::GetEnvironmentVariable("DB_NAME", "Process") ?? "jurispilot"
            $dbUser = [Environment]::GetEnvironmentVariable("DB_USER", "Process") ?? "postgres"
            
            Write-Info "  Host: $dbHost:$dbPort"
            Write-Info "  Database: $dbName"
            Write-Info "  User: $dbUser"
            $healthStatus.PostgreSQL = $true
        }
    }
} catch {
    Write-Error "PostgreSQL não encontrado"
}

# ============================================
# 2. n8n
# ============================================
Write-Info "Verificando n8n..."

try {
    $n8nUrl = "http://localhost:5678"
    $healthCheck = Invoke-RestMethod -Uri "$n8nUrl/healthz" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Success "n8n está rodando em $n8nUrl"
    $healthStatus.N8N = $true
} catch {
    Write-Warning "n8n não está rodando (execute: n8n start)"
}

# ============================================
# 3. API Python
# ============================================
Write-Info "Verificando API Python..."

try {
    $apiUrl = "http://localhost:5000"
    $healthCheck = Invoke-RestMethod -Uri "$apiUrl/health" -Method Get -TimeoutSec 3 -ErrorAction Stop
    if ($healthCheck.status -eq "healthy") {
        Write-Success "API Python está rodando em $apiUrl"
        Write-Info "  Service: $($healthCheck.service)"
        Write-Info "  Version: $($healthCheck.version)"
        $healthStatus.APIPython = $true
    }
} catch {
    Write-Warning "API Python não está rodando (execute: .\scripts\start-api.ps1)"
}

# ============================================
# 4. Storage
# ============================================
Write-Info "Verificando storage..."

$storageDirs = @(
    "storage\documents",
    "storage\uploads",
    "logs",
    "backups"
)

$allDirsExist = $true
foreach ($dir in $storageDirs) {
    $fullPath = Join-Path $projectRoot $dir
    if (Test-Path $fullPath) {
        Write-Success "  $dir existe"
    } else {
        Write-Warning "  $dir não existe"
        $allDirsExist = $false
    }
}

if ($allDirsExist) {
    $healthStatus.Storage = $true
}

# ============================================
# Resumo
# ============================================
Write-ColorOutput "`n📊 Status do Sistema`n" "Cyan"

Write-Host "PostgreSQL:  $(if ($healthStatus.PostgreSQL) { '✅ Online' } else { '❌ Offline' })"
Write-Host "n8n:         $(if ($healthStatus.N8N) { '✅ Online' } else { '❌ Offline' })"
Write-Host "API Python:  $(if ($healthStatus.APIPython) { '✅ Online' } else { '❌ Offline' })"
Write-Host "Storage:     $(if ($healthStatus.Storage) { '✅ OK' } else { '❌ Problemas' })"
Write-Host ""

$allHealthy = ($healthStatus.Values | Where-Object { $_ -eq $true }).Count -eq $healthStatus.Count

if ($allHealthy) {
    Write-ColorOutput "✨ Sistema está saudável!`n" "Green"
    exit 0
} else {
    Write-ColorOutput "⚠️  Alguns componentes precisam de atenção.`n" "Yellow"
    exit 1
}
