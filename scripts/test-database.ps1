# ============================================
# JurisPilot - Testes do Banco de Dados
# ============================================
# Este script testa o banco de dados PostgreSQL
# Execute: .\scripts\test-database.ps1
# ============================================

param(
    [string]$DbHost = "localhost",
    [int]$DbPort = 5432,
    [string]$DbName = "jurispilot",
    [string]$DbUser = "postgres",
    [string]$DbPassword = "",
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
Set-Location $projectRoot

Write-ColorOutput "`n🧪 JurisPilot - Testes do Banco de Dados" "Cyan"
Write-ColorOutput "======================================`n" "Cyan"

# Carrega .env se existir
if (Test-Path "$projectRoot\.env") {
    Get-Content "$projectRoot\.env" | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
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
# 1. Testar conexão
# ============================================
Write-Step "Testando conexão..."

try {
    $version = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc "SELECT version();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Conexão estabelecida"
        Write-Info "PostgreSQL: $($version.Trim())"
    } else {
        throw "Falha na conexão"
    }
} catch {
    Write-Error "Falha ao conectar ao banco de dados"
    exit 1
}

# ============================================
# 2. Verificar tabelas
# ============================================
Write-Step "Verificando tabelas..."

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
    $exists = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='$table';" 2>&1
    
    if ($exists -eq "1") {
        Write-Success "Tabela '$table' existe"
    } else {
        Write-Error "Tabela '$table' não encontrada"
        $allTablesExist = $false
    }
}

# ============================================
# 3. Testar inserção de dados
# ============================================
Write-Step "Testando inserção de dados..."

try {
    # Insere cliente de teste
    $testCliente = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc @"
INSERT INTO clientes (nome, email, telefone) 
VALUES ('Cliente Teste', 'teste@example.com', '11999999999')
RETURNING id;
"@ 2>&1
    
    if ($LASTEXITCODE -eq 0 -and $testCliente -match '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}') {
        $clienteId = $testCliente.Trim()
        Write-Success "Cliente de teste inserido: $clienteId"
        
        # Remove cliente de teste
        & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -c "DELETE FROM clientes WHERE id='$clienteId';" 2>&1 | Out-Null
        Write-Info "Cliente de teste removido"
    } else {
        throw "Falha ao inserir cliente de teste"
    }
} catch {
    Write-Error "Falha ao testar inserção: $($_.Exception.Message)"
}

# ============================================
# 4. Verificar constraints
# ============================================
Write-Step "Verificando constraints..."

try {
    $constraints = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc @"
SELECT COUNT(*) 
FROM information_schema.table_constraints 
WHERE table_schema='public' AND constraint_type='FOREIGN KEY';
"@ 2>&1
    
    if ($constraints -match '^\d+$') {
        Write-Success "Foreign keys encontradas: $constraints"
    }
} catch {
    Write-Warning "Não foi possível verificar constraints"
}

# ============================================
# 5. Verificar índices
# ============================================
Write-Step "Verificando índices..."

try {
    $indexes = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc @"
SELECT COUNT(*) 
FROM pg_indexes 
WHERE schemaname='public';
"@ 2>&1
    
    if ($indexes -match '^\d+$') {
        Write-Success "Índices encontrados: $indexes"
    }
} catch {
    Write-Warning "Não foi possível verificar índices"
}

# ============================================
# 6. Contar registros
# ============================================
Write-Step "Contando registros..."

foreach ($table in $tables) {
    try {
        $count = & psql -h $DbHost -p $DbPort -U $DbUser -d $DbName -tAc "SELECT COUNT(*) FROM $table;" 2>&1
        
        if ($count -match '^\d+$') {
            Write-Info "  $table`: $count registros"
        }
    } catch {
        Write-Warning "  $table`: Erro ao contar"
    }
}

# ============================================
# Resumo Final
# ============================================
Write-ColorOutput "`n✨ Testes concluídos!`n" "Green"

if ($allTablesExist) {
    Write-Success "Banco de dados está configurado corretamente"
} else {
    Write-Error "Algumas tabelas estão faltando. Execute setup-database.ps1"
    exit 1
}

$env:PGPASSWORD = $null
