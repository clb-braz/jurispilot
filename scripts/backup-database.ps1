# ============================================
# JurisPilot - Backup do Banco de Dados
# ============================================
# Este script faz backup do PostgreSQL
# Execute: .\scripts\backup-database.ps1
# ============================================

param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "jurispilot",
    [string]$DbUser = "postgres",
    [string]$DbPassword = "",
    [string]$BackupPath = "./backups",
    [switch]$Compress,
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
function Write-Step { param([string]$Message) Write-ColorOutput "`n📋 $Message" "Magenta" }

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-ColorOutput "`n💾 JurisPilot - Backup do Banco de Dados" "Cyan"
Write-ColorOutput "========================================`n" "Cyan"

# Carrega .env
if (Test-Path "$projectRoot\.env") {
    Get-Content "$projectRoot\.env" | ForEach-Object {
        if ($_ -match '^\s*DB_(\w+)\s*=\s*(.*)$') {
            $key = "DB_$($matches[1])"
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
        if ($_ -match '^\s*BACKUP_PATH\s*=\s*(.*)$') {
            $BackupPath = $matches[1].Trim()
        }
    }
    
    $DbHost = [Environment]::GetEnvironmentVariable("DB_HOST", "Process") ?? $DbHost
    $DbPort = [int]([Environment]::GetEnvironmentVariable("DB_PORT", "Process") ?? $DbPort)
    $DbName = [Environment]::GetEnvironmentVariable("DB_NAME", "Process") ?? $DbName
    $DbUser = [Environment]::GetEnvironmentVariable("DB_USER", "Process") ?? $DbUser
    $DbPassword = [Environment]::GetEnvironmentVariable("DB_PASSWORD", "Process") ?? $DbPassword
}

if ([string]::IsNullOrEmpty($DbPassword)) {
    $securePassword = Read-Host "Digite a senha do PostgreSQL" -AsSecureString
    $DbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    )
}

$env:PGPASSWORD = $DbPassword

# ============================================
# Criar diretório de backup
# ============================================
Write-Step "Preparando diretório de backup..."

$backupDir = Join-Path $projectRoot $BackupPath
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Success "Diretório de backup criado: $backupDir"
}

# ============================================
# Gerar nome do arquivo
# ============================================
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "${DbName}_${timestamp}.sql"

if ($Compress) {
    $backupFile = "$backupFile.gz"
}

# ============================================
# Executar backup
# ============================================
Write-Step "Executando backup..."

try {
    if ($Compress) {
        & pg_dump -h $DbHost -p $DbPort -U $DbUser -d $DbName -F c -f $backupFile 2>&1 | Out-Null
    } else {
        & pg_dump -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $backupFile 2>&1 | Out-Null
    }
    
    if ($LASTEXITCODE -eq 0) {
        $fileSize = (Get-Item $backupFile).Length / 1MB
        Write-Success "Backup criado: $backupFile"
        Write-Info "Tamanho: $([math]::Round($fileSize, 2)) MB"
    } else {
        throw "Falha ao criar backup"
    }
} catch {
    Write-Error "Erro ao criar backup: $($_.Exception.Message)"
    exit 1
}

# ============================================
# Limpar backups antigos
# ============================================
Write-Step "Limpando backups antigos..."

$retentionDays = 30
if (Test-Path "$projectRoot\.env") {
    Get-Content "$projectRoot\.env" | ForEach-Object {
        if ($_ -match '^\s*BACKUP_RETENTION_DAYS\s*=\s*(\d+)$') {
            $retentionDays = [int]$matches[1]
        }
    }
}

$cutoffDate = (Get-Date).AddDays(-$retentionDays)
$oldBackups = Get-ChildItem -Path $backupDir -Filter "${DbName}_*.sql*" | Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($oldBackups.Count -gt 0) {
    $oldBackups | Remove-Item -Force
    Write-Info "Removidos $($oldBackups.Count) backups antigos (mais de $retentionDays dias)"
}

# ============================================
# Resumo
# ============================================
Write-ColorOutput "`n✨ Backup concluído!`n" "Green"
Write-Info "Arquivo: $backupFile"
Write-Info "Para restaurar: pg_restore -h $DbHost -p $DbPort -U $DbUser -d $DbName $backupFile"
Write-Host ""

$env:PGPASSWORD = $null
