#!/bin/sh
set -eu

target="${PREFIX:-$HOME/.local}/bin/agent-notify"
asset_dir="${PREFIX:-$HOME/.local}/share/agent-notify"
command="$target"
cleanup_status=0
if [ ! -x "$command" ]; then
    command="$(dirname "$0")/agent-notify"
fi
if [ -x "$command" ]; then
    if ! "$command" remove all; then
        echo "warning: integration or Windows cleanup failed; continuing with local uninstall" >&2
        cleanup_status=1
    fi
fi
if [ -f "$target" ]; then
    rm "$target"
    echo "removed: $target"
fi
if [ -f "$asset_dir/agent-notify.png" ]; then
    rm "$asset_dir/agent-notify.png"
    rmdir "$asset_dir" 2>/dev/null || true
    echo "removed: $asset_dir/agent-notify.png"
fi
exit "$cleanup_status"
