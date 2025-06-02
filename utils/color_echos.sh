#!/bin/bash

red_echo() {
  echo -e "\033[1;31m $1\033[0m"
}

green_echo() {
  echo -e "\033[1;32m $1\033[0m"
}

yellow_echo() {
  echo -e "\033[1;33m $1\033[0m"
}

blue_echo() {
  echo -e "\033[1;34m $1\033[0m"
}

# ==========

title_echo() {
  echo -e "\033[1;34m $1\033[0m"
  echo
}

status_echo() {
  echo -e "\033[1;34m $1\033[0m"
  echo 
}

error_echo() {
  echo -e "\033[1;31m $1\033[0m"
  echo
}

success_echo() {
  echo -e "\033[1;32m $1\033[0m"
  echo
}

warn_echo() {
  echo -e "\033[1;33m $1\033[0m"
  echo
}

div_echo() {
  echo -e "\033[1;33m $1\033[0m"
}

divider() {
  div_echo "============================================================"
}


