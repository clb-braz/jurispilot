#!/bin/bash
# ============================================
# JurisPilot - Funções de Cores para Bash
# ============================================
# Funções auxiliares para output colorido
# ============================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Funções de output
write_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

write_error() {
    echo -e "${RED}❌ $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

write_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

write_step() {
    echo -e "\n${MAGENTA}📋 $1${NC}"
}

write_title() {
    echo -e "\n${CYAN}$1${NC}"
    echo -e "${CYAN}$(printf '=%.0s' {1..${#1}})${NC}\n"
}

