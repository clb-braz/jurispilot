# ============================================
# JurisPilot - Testes Completos do Sistema
# ============================================
# Este script testa todos os componentes do sistema
# Execute: .\scripts\test-workflows.ps1
# ============================================

param(
    [switch]$SkipDatabase,
    [switch]$SkipN8N,
    [switch]$SkipAPI,
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
function Write-Warning { param([string]$Message) Write-ColorOutput "⚠️  $Message" "Yellow" }
function Write-Info { param([string]$Message) Write-ColorOutput "ℹ️  $Message" "Cyan" }
function Write-Step { param([string]$Message) Write-ColorOutput "`n📋 $Message" "Magenta" }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-ColorOutput "`n🧪 JurisPilot - Testes Completos do Sistema" "Cyan"
Write-ColorOutput "==========================================`n" "Cyan"

$testResults = @{
    Database = $false
    N8N = $false
    API = $false
    Integrations = $false
}

# ============================================
# 1. Testar Banco de Dados
# ============================================
if (-not $SkipDatabase) {
    Write-Step "Testando banco de dados PostgreSQL..."
    
    try {
        & "$PSScriptRoot\test-database.ps1" -ErrorAction Stop
        if ($LASTEXITCODE -eq 0) {
            $testResults.Database = $true
            Write-Success "Banco de dados: OK"
        } else {
            Write-Error "Banco de dados: FALHOU"
        }
    } catch {
        Write-Error "Banco de dados: FALHOU - $($_.Exception.Message)"
    }
} else {
    Write-Info "Pulando teste do banco de dados"
}

# ============================================
# 2. Testar n8n
# ============================================
if (-not $SkipN8N) {
    Write-Step "Testando n8n..."
    
    $n8nUrl = "http://localhost:5678"
    
    try {
        $healthCheck = Invoke-RestMethod -Uri "$n8nUrl/healthz" -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Success "n8n está rodando"
        
        # Verifica workflows
        try {
            $workflows = Invoke-RestMethod -Uri "$n8nUrl/api/v1/workflows" -Method Get -ErrorAction Stop
            $workflowCount = $workflows.data.Count
            Write-Success "Workflows encontrados: $workflowCount"
            $testResults.N8N = $true
        } catch {
            Write-Warning "Não foi possível listar workflows (pode precisar de autenticação)"
        }
    } catch {
        Write-Error "n8n não está acessível em $n8nUrl"
        Write-Info "Inicie o n8n com: n8n start"
    }
} else {
    Write-Info "Pulando teste do n8n"
}

# ============================================
# 3. Testar API Python
# ============================================
if (-not $SkipAPI) {
    Write-Step "Testando API Python..."
    
    $apiUrl = "http://localhost:5000"
    
    try {
        $healthCheck = Invoke-RestMethod -Uri "$apiUrl/health" -Method Get -TimeoutSec 5 -ErrorAction Stop
        if ($healthCheck.status -eq "healthy") {
            Write-Success "API Python está rodando"
            Write-Info "Service: $($healthCheck.service)"
            Write-Info "Version: $($healthCheck.version)"
            $testResults.API = $true
        }
    } catch {
        Write-Error "API Python não está acessível em $apiUrl"
        Write-Info "Inicie a API com: .\scripts\start-api.ps1"
    }
} else {
    Write-Info "Pulando teste da API"
}

# ============================================
# 4. Testar Integrações
# ============================================
Write-Step "Testando integrações..."

# Carrega .env
if (Test-Path "$projectRoot\.env") {
    Get-Content "$projectRoot\.env" | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

# WhatsApp
$whatsappEnabled = [Environment]::GetEnvironmentVariable("WHATSAPP_API_KEY", "Process")
if ($whatsappEnabled) {
    Write-Info "WhatsApp: Configurado (não testado)"
} else {
    Write-Warning "WhatsApp: Não configurado"
}

# Google Calendar
$googleEnabled = [Environment]::GetEnvironmentVariable("GOOGLE_CALENDAR_ENABLED", "Process")
if ($googleEnabled -eq "true") {
    Write-Info "Google Calendar: Configurado (não testado)"
} else {
    Write-Warning "Google Calendar: Não configurado"
}

# Email
$emailEnabled = [Environment]::GetEnvironmentVariable("EMAIL_ENABLED", "Process")
if ($emailEnabled -eq "true") {
    Write-Info "Email: Configurado (não testado)"
} else {
    Write-Warning "Email: Não configurado"
}

$testResults.Integrations = $true

# ============================================
# Resumo Final
# ============================================
Write-ColorOutput "`n📊 Resumo dos Testes`n" "Cyan"

$totalTests = ($testResults.Values | Measure-Object).Count
$passedTests = ($testResults.Values | Where-Object { $_ -eq $true }).Count

Write-Host "Banco de Dados: $(if ($testResults.Database) { '✅' } else { '❌' })"
Write-Host "n8n:           $(if ($testResults.N8N) { '✅' } else { '❌' })"
Write-Host "API Python:    $(if ($testResults.API) { '✅' } else { '❌' })"
Write-Host "Integrações:   $(if ($testResults.Integrations) { '✅' } else { '❌' })"
Write-Host ""

if ($passedTests -eq $totalTests) {
    Write-ColorOutput "✨ Todos os testes passaram!`n" "Green"
    exit 0
} else {
    Write-ColorOutput "⚠️  Alguns testes falharam. Verifique as mensagens acima.`n" "Yellow"
    exit 1
}
