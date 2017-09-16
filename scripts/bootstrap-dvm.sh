#!/usr/bin/env bash

set -x

[ -f /usr/local/opt/dvm/dvm.sh ] && . /usr/local/opt/dvm/dvm.sh
[[ -r $DVM_DIR/bash_completion ]] && . $DVM_DIR/bash_completion

# source: http://www.rushiagr.com/blog/2016/08/16/kubernetes-in-30-minutes-with-minikube-on-mac/
# [[ -s "$(brew --prefix dvm)/dvm.sh" ]] && source "$(brew --prefix dvm)/dvm.sh"
# FIXME: Does this work better? ^
