#!/bin/bash

set -euo pipefail

readonly SRC="${1:-$HOME/Documents}"
readonly DEST="${2:-$HOME/Backups}"
readonly DATE=$(date +%Y%m%d_%H%M%S)
readonly HOST=$(hostname -s)
readonly ARCHIVE="${DEST}/backup-${HOST}-${DATE}.tar.gz"
readonly MAX_BACKUPS=7

calcSize() {
    du -sh "$1" | awk '{print $1}'
}

backup() {
    echo "Source: $SRC ($(calcSize "$SRC"))"
    echo "Creating backup..."

    tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$(basename "$SRC")" 2>&1 | \
        grep -v "Removing leading" || true

    [ -f "$ARCHIVE" ] || { echo "Backup failed"; exit 1; }
    echo "Created: $ARCHIVE ($(calcSize "$ARCHIVE"))"
}

verify() {
    tar -tzf "$ARCHIVE" > /dev/null 2>&1 || { echo "Verification failed"; exit 1; }
    echo "Verified OK"
}

cleanup() {
    local count=$(find "$DEST" -name "backup-*.tar.gz" -type f | wc -l)
    echo "Current backups: $count"

    if [ $count -gt $MAX_BACKUPS ]; then
        local to_del=$((count - MAX_BACKUPS))
        echo "Removing $to_del old backups..."
        find "$DEST" -name "backup-*.tar.gz" -type f -print0 | \
            xargs -0 ls -t | tail -n $to_del | xargs rm -f
    fi
}

list() {
    echo "Recent backups:"
    find "$DEST" -name "backup-*.tar.gz" -type f -print0 | \
        xargs -0 ls -lht | head -n $MAX_BACKUPS
}

main() {
    [ ! -d "$SRC" ] && { echo "Source not found: $SRC"; exit 1; }
    mkdir -p "$DEST"

    backup
    verify
    cleanup
    list

    echo "Backup complete: $(date)"
}

main "$@"
