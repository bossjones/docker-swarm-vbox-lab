#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[38;5;220m'
NC='\033[0m' # No Color

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function log {
  if [[ $1 = "FAIL" ]]; then
    printf "$RED[FAIL]$NC $2\n"
  elif [[ $1 = "WARN" && -z "$SILENT" ]]; then
    printf "$YELLOW[WARN]$NC $2\n"
  elif [[ $1 = "INFO" && -z "$SILENT" ]]; then
    printf "[INFO] $2\n"
  elif [[ $1 = "PASS" && -z "$SILENT" ]]; then
    printf "$GREEN[PASS]$NC $2\n"
  fi
}
