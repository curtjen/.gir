#!/bin/bash

# Colored logging helpers

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_header() { echo -e "\n${BOLD}${CYAN}==> $*${NC}"; }
log_info()   { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()     { echo -e "${GREEN}[ OK ]${NC}  $*"; }
log_skip()   { echo -e "${YELLOW}[SKIP]${NC}  $*"; }
log_warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()  { echo -e "${RED}[ERR ]${NC}  $*"; }
