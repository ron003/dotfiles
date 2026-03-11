#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.vscode-remote/data/Machine"
cp "vscode/settings.json" "$HOME/.vscode-remote/data/Machine/settings.json"
cp .bashrc .profile} "$HOME"
