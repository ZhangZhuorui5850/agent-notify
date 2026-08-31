#!/bin/sh
set -eu

prefix="${PREFIX:-$HOME/.local}"
target="$prefix/bin/agent-notify"
mkdir -p "$prefix/bin"
install -m 755 "$(dirname "$0")/agent-notify" "$target"

echo "installed: $target"
echo "next: $target setup all"
echo "test: $target test"
