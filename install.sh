#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.vscode-remote/data/Machine"
cp "$HOME/.dotfiles/vscode/settings.json" "$HOME/.vscode-remote/data/Machine/settings.json"
