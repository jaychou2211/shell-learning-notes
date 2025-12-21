#!/bin/bash

set -euo pipefail

readonly LOG_DIR="/tmp/network-monitor"
readonly LOG_FILE="${LOG_DIR}/monitor-$(date +%Y%m%d).log"
readonly EMAIL="${EMAIL:-admin@example.com}"
readonly PING_COUNT=3

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] ${*:2}" | tee -a "$LOG_FILE"
}

checkHost() {
    ping -c "$PING_COUNT" "$1" > /dev/null 2>&1
}

notify() {
    log "NOTIFY" "Email to: $EMAIL"
    log "NOTIFY" "Host: $1 - Status: $2"

    cat >> "$LOG_FILE" << EOF
=== Notification ===
To: $EMAIL
Subject: Network Alert - $1
Host $1 is $2
Time: $(date)
====================
EOF
}

monitor() {
    local host=$1
    local status_file="${LOG_DIR}/${host}.status"
    local prev_status=""

    [ -f "$status_file" ] && prev_status=$(cat "$status_file")

    if checkHost "$host"; then
        curr_status="UP"
        log "INFO" "✓ $host online"
    else
        curr_status="DOWN"
        log "ERROR" "✗ $host offline"
    fi

    if [[ "$prev_status" != "$curr_status" && -n "$prev_status" ]]; then
        log "ALERT" "$host: $prev_status → $curr_status"
        notify "$host" "$curr_status"
    fi

    echo "$curr_status" > "$status_file"
}

stats() {
    log "INFO" "=== Status ==="
    for host in "$@"; do
        local status_file="${LOG_DIR}/${host}.status"
        [ -f "$status_file" ] && log "INFO" "  $host: $(cat "$status_file")"
    done
}

cleanup() {
    stats "$@"
    log "INFO" "Monitor stopped"
    exit 0
}

main() {
    local hosts=("$@")
    [ ${#hosts[@]} -eq 0 ] && { echo "Usage: $0 HOST [HOST...]"; exit 1; }

    trap 'cleanup "${hosts[@]}"' INT TERM

    mkdir -p "$LOG_DIR"
    log "INFO" "Monitor started"
    log "INFO" "Hosts: ${hosts[*]}"

    for host in "${hosts[@]}"; do
        monitor "$host"
    done

    stats "${hosts[@]}"
    log "INFO" "Check complete"
    log "INFO" "Log: $LOG_FILE"
}

main "$@"
