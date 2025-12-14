#!/bin/bash
# ============================================
# JurisPilot - Detecção de Sistema Operacional
# ============================================
# Detecta o sistema operacional e retorna: windows, macos, linux
# ============================================

detect_os() {
    case "$(uname -s)" in
        Linux*)
            echo "linux"
            ;;
        Darwin*)
            echo "macos"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Se executado diretamente, imprime o resultado
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_os
fi

