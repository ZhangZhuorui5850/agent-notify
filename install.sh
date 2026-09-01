#!/bin/sh
set -eu

prefix="${PREFIX:-$HOME/.local}"
target="$prefix/bin/agent-notify"
asset_dir="$prefix/share/agent-notify"
mkdir -p "$prefix/bin"
mkdir -p "$asset_dir"
install -m 755 "$(dirname "$0")/agent-notify" "$target"
install -m 644 "$(dirname "$0")/assets/agent-notify.png" "$asset_dir/agent-notify.png"

echo "installed: $target"
echo "installed: $asset_dir/agent-notify.png"
echo "next: $target setup all"
echo "test: $target test"
