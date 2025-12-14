# ============================================
# JurisPilot - Detecção de Sistema Operacional
# ============================================
# Detecta o sistema operacional e retorna: windows, macos, linux
# ============================================

function Detect-OS {
    $os = $env:OS
    
    if ($IsWindows -or $os -like "*Windows*") {
        return "windows"
    }
    elseif ($IsMacOS) {
        return "macos"
    }
    elseif ($IsLinux) {
        return "linux"
    }
    else {
        # Fallback para versões antigas do PowerShell
        $platform = [System.Environment]::OSVersion.Platform
        
        if ($platform -eq "Win32NT") {
            return "windows"
        }
        else {
            return "unknown"
        }
    }
}

# Se executado diretamente, imprime o resultado
if ($MyInvocation.InvocationName -ne '.') {
    Detect-OS
}

