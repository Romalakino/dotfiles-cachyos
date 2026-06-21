#!/usr/bin/env bash
set -euo pipefail

updates=$(checkupdates 2>/dev/null | wc -l)

echo "Pacman:$updates"
