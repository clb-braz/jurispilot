# ============================================
# JurisPilot - Importar Workflows n8n
# ============================================
# Este script importa todos os workflows do n8n via API
# Execute: .\scripts\import-workflows.ps1
# ============================================

param(
    [string]$N8NUrl = "http://localhost:5678",
    [string]$N8NUser = "admin",
    [string]$N8NPassword = "admin",
    [switch]$Activate,
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

# Verifica diretório
$projectRoot = Split-Path -Parent $PSScriptRoot
$workflowsPath = "$projectRoot\n8n\workflows"

if (-not (Test-Path $workflowsPath)) {
    Write-Error "Diretório de workflows não encontrado: $workflowsPath"
    exit 1
}

Set-Location $projectRoot

Write-ColorOutput "`n⚙️  JurisPilot - Importar Workflows n8n" "Cyan"
Write-ColorOutput "========================================`n" "Cyan"

# ============================================
# 1. Verificar se n8n está rodando
# ============================================
Write-Step "Verificando se n8n está rodando..."

try {
    $healthCheck = Invoke-RestMethod -Uri "$N8NUrl/healthz" -Method Get -TimeoutSec 5 -ErrorAction Stop
    Write-Success "n8n está rodando em $N8NUrl"
} catch {
    Write-Error "n8n não está acessível em $N8NUrl"
    Write-Info "Certifique-se de que o n8n está rodando: n8n start"
    exit 1
}

# ============================================
# 2. Autenticar no n8n
# ============================================
Write-Step "Autenticando no n8n..."

$authUrl = "$N8NUrl/rest/login"
$authBody = @{
    email = $N8NUser
    password = $N8NPassword
} | ConvertTo-Json

try {
    $authResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Body $authBody -ContentType "application/json" -ErrorAction Stop
    $sessionId = $authResponse.data.cookie
    
    # Cria headers com autenticação
    $headers = @{
        "Cookie" = $sessionId
        "Content-Type" = "application/json"
    }
    
    Write-Success "Autenticação realizada com sucesso"
} catch {
    Write-Warning "Tentando sem autenticação (n8n pode estar sem auth configurado)"
    $headers = @{
        "Content-Type" = "application/json"
    }
}

# ============================================
# 3. Listar workflows existentes
# ============================================
Write-Step "Listando workflows existentes..."

try {
    $existingWorkflows = Invoke-RestMethod -Uri "$N8NUrl/api/v1/workflows" -Method Get -Headers $headers -ErrorAction Stop
    $existingCount = $existingWorkflows.data.Count
    Write-Info "Workflows existentes: $existingCount"
} catch {
    Write-Warning "Não foi possível listar workflows existentes"
    $existingWorkflows = @{ data = @() }
}

# ============================================
# 4. Importar workflows
# ============================================
Write-Step "Importando workflows..."

$workflowFiles = Get-ChildItem -Path $workflowsPath -Filter "*.json" | Sort-Object Name
$importedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($file in $workflowFiles) {
    $workflowName = $file.BaseName
    
    try {
        # Lê conteúdo do workflow
        $workflowContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        
        # Verifica se workflow já existe
        $existingWorkflow = $existingWorkflows.data | Where-Object { $_.name -eq $workflowContent.name }
        
        if ($existingWorkflow) {
            Write-Warning "Workflow '$($workflowContent.name)' já existe. Pulando..."
            $skippedCount++
            continue
        }
        
        # Prepara payload para importação
        $importPayload = @{
            name = $workflowContent.name
            nodes = $workflowContent.nodes
            connections = $workflowContent.connections
            active = if ($Activate) { $true } else { $false }
            settings = $workflowContent.settings
        } | ConvertTo-Json -Depth 10
        
        # Importa workflow
        $importResponse = Invoke-RestMethod -Uri "$N8NUrl/api/v1/workflows" -Method Post -Body $importPayload -Headers $headers -ErrorAction Stop
        
        Write-Success "Workflow importado: $($workflowContent.name)"
        $importedCount++
        
    } catch {
        Write-Error "Erro ao importar workflow '$workflowName': $($_.Exception.Message)"
        $errorCount++
    }
}

# ============================================
# Resumo Final
# ============================================
Write-ColorOutput "`n✨ Importação concluída!`n" "Green"
Write-ColorOutput "Resumo:" "Cyan"
Write-Host "  ✅ Importados: $importedCount"
Write-Host "  ⏭️  Pulados: $skippedCount"
Write-Host "  ❌ Erros: $errorCount"
Write-Host "  📁 Total de arquivos: $($workflowFiles.Count)"
Write-Host ""
Write-Info "Acesse o n8n em: $N8NUrl"
Write-Host ""
