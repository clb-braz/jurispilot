# ============================================
# JurisPilot - Script de Setup do Banco de Dados
# ============================================
# Este script configura o PostgreSQL completo
# Execute: .\scripts\setup-database.ps1
# ============================================

param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "jurispilot",
    [string]$DbUser = "postgres",
    [string]$DbPassword = "",
    [switch]$CreateUser,
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
if (-not (Test-Path "$projectRoot\database\schema.sql")) {
    Write-Error "Execute este script a partir do diretório raiz do JurisPilot"
    exit 1
}

Set-Location $projectRoot

Write-ColorOutput "`n🗄️  JurisPilot - Configuração do Banco de Dados" "Cyan"
Write-ColorOutput "============================================`n" "Cyan"

# ============================================
# 1. Verificar PostgreSQL
# ============================================
Write-Step "Verificando PostgreSQL..."

try {
    $pgVersion = & psql --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "PostgreSQL não encontrado"
    }
    Write-Success "PostgreSQL encontrado: $($pgVersion -split "`n" | Select-Object -First 1)"
} catch {
    Write-Error "PostgreSQL não está instalado ou não está no PATH"
    Write-Info "Instale PostgreSQL 12+ e adicione ao PATH"
    exit 1
}

# ============================================
# 2. Solicitar credenciais se necessário
# ============================================
if ([string]::IsNullOrEmpty($DbPassword)) {
    Write-Info "Solicitando senha do PostgreSQL..."
    $securePassword = Read-Host "Digite a senha do usuário '$DbUser'" -AsSecureString
    $DbPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    )
}

# Configura variável de ambiente para psql
$env:PGPASSWORD = $DbPassword

# ============================================
# 3. Testar conexão
# ============================================
Write-Step "Testando conexão com PostgreSQL..."

$testConnection = & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c "SELECT version();" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao conectar ao PostgreSQL"
    Write-Info "Verifique:"
    Write-Host "  - PostgreSQL está rodando?"
    Write-Host "  - Host: $DbHost"
    Write-Host "  - Port: $DbPort"
    Write-Host "  - User: $DbUser"
    Write-Host "  - Senha está correta?"
    exit 1
}

Write-Success "Conexão estabelecida com sucesso"

# ============================================
# 4. Criar banco de dados
# ============================================
Write-Step "Criando banco de dados '$DbName'..."

# Verifica se o banco já existe
$dbExists = & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DbName'" 2>&1

if ($dbExists -eq "1") {
    Write-Warning "Banco de dados '$DbName' já existe"
    $overwrite = Read-Host "Deseja recriar? (isso apagará todos os dados) [s/N]"
    if ($overwrite -eq "s" -or $overwrite -eq "S") {
        Write-Info "Removendo banco de dados existente..."
        & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c "DROP DATABASE IF EXISTS $DbName;" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Falha ao remover banco de dados existente"
            exit 1
        }
    } else {
        Write-Info "Mantendo banco de dados existente"
        $skipCreate = $true
    }
}

if (-not $skipCreate) {
    & psql -h $DbHost -p $DbPort -U $DbUser -d postgres -c "CREATE DATABASE $DbName;" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Banco de dados '$DbName' criado"
    } else {
        Write-Error "Falha ao criar banco de dados"
        exit 1
    }
}

# ============================================
# 5. Executar schema.sql
# ============================================
Write-Step "Executando schema.sql..."

$schemaFile = "$projectRoot\database\schema.sql"
if (-not (Test-Path $schemaFile)) {
    Write-Error "Arquivo schema.sql não encontrado: $schemaFile"
    exit 1
}

Write-Info "Executando schema..."
& psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $schemaFile 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Success "Schema executado com sucesso"
} else {
    Write-Error "Falha ao executar schema.sql"
    Write-Info "Verifique o arquivo e tente novamente"
    exit 1
}

# ============================================
# 6. Executar seeds
# ============================================
Write-Step "Executando seeds (checklists_juridicos)..."

$seedsFile = "$projectRoot\database\seeds\checklists_seed.sql"
if (Test-Path $seedsFile) {
    Write-Info "Executando seeds..."
    & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -f $seedsFile 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Seeds executados com sucesso"
    } else {
        Write-Warning "Falha ao executar seeds (pode ser normal se já existirem)"
    }
} else {
    Write-Warning "Arquivo de seeds não encontrado: $seedsFile"
}

# ============================================
# 7. Validar criação das tabelas
# ============================================
Write-Step "Validando criação das tabelas..."

$tables = @(
    "clientes",
    "casos",
    "checklists_juridicos",
    "checklists_caso",
    "documentos",
    "prazos",
    "linha_tempo",
    "resumos_juridicos",
    "auditoria_operacional"
)

$allTablesExist = $true
foreach ($table in $tables) {
    $tableExists = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='$table';" 2>&1
    
    if ($tableExists -eq "1") {
        Write-Success "Tabela '$table' existe"
    } else {
        Write-Error "Tabela '$table' não encontrada"
        $allTablesExist = $false
    }
}

if ($allTablesExist) {
    Write-Success "Todas as tabelas foram criadas corretamente"
} else {
    Write-Error "Algumas tabelas não foram criadas. Verifique o schema.sql"
    exit 1
}

# ============================================
# 8. Contar registros em checklists_juridicos
# ============================================
Write-Step "Verificando dados iniciais..."

$checklistCount = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc "SELECT COUNT(*) FROM checklists_juridicos;" 2>&1
if ($checklistCount -match '^\d+$') {
    Write-Success "Checklists jurídicos: $checklistCount registros"
} else {
    Write-Warning "Não foi possível contar checklists jurídicos"
}

# ============================================
# Resumo Final
# ============================================
Write-ColorOutput "`n✨ Banco de dados configurado com sucesso!`n" "Green"
Write-ColorOutput "Informações de conexão:" "Cyan"
Write-Host "  Host: $DbHost"
Write-Host "  Port: $DbPort"
Write-Host "  Database: $DbName"
Write-Host "  User: $DbUser"
Write-Host ""
Write-Info "Configure essas informações no arquivo .env"
Write-Host ""

# Limpa senha da memória
$env:PGPASSWORD = $null
$DbPassword = $null
