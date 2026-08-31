#!/bin/sh
set -eu

target="${PREFIX:-$HOME/.local}/bin/agent-notify"
if [ -f "$target" ]; then
    "$target" remove all
    rm "$target"
    echo "removed: $target"
fi
