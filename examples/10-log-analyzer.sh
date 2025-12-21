#!/bin/bash

set -euo pipefail

readonly LOG_DIR="${1:-./logs}"
readonly REPORT="/tmp/log-report.txt"
readonly PATTERNS=("ERROR" "FATAL" "CRITICAL")
readonly THRESHOLD=10

init() {
    cat > "$REPORT" << EOF
Log Analysis Report
Time: $(date)
Directory: $LOG_DIR
==========================================

EOF
}

analyze() {
    local file=$1
    local alerts=0

    echo "File: $file" >> "$REPORT"
    echo "----------------------------------------" >> "$REPORT"

    for pattern in "${PATTERNS[@]}"; do
        local count=$(grep -c "$pattern" "$file" 2>/dev/null || echo "0")
        echo "  $pattern: $count" >> "$REPORT"

        if [ "$count" -gt "$THRESHOLD" ]; then
            echo "  WARNING: $count $pattern (> $THRESHOLD)" >> "$REPORT"
            alerts=1
        fi
    done

    echo >> "$REPORT"
    return $alerts
}

main() {
    [ ! -d "$LOG_DIR" ] && { echo "Directory not found: $LOG_DIR"; exit 1; }

    init

    local files total=0 alerts=0
    if [[ "$OSTYPE" == "darwin"* ]]; then
        files=$(find "$LOG_DIR" -name "*.log" -type f -mtime -1 2>/dev/null || echo "")
    else
        files=$(find "$LOG_DIR" -name "*.log" -type f -mtime -1 2>/dev/null || echo "")
    fi

    [ -z "$files" ] && { echo "No recent logs"; exit 0; }

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        analyze "$file" && ((alerts++))
        ((total++))
    done <<< "$files"

    cat >> "$REPORT" << EOF
==========================================
Summary:
  Total files: $total
  Alerts: $alerts
==========================================
EOF

    echo "Analyzed: $total files"
    echo "Alerts: $alerts"
    echo "Report: $REPORT"

    [ $alerts -gt 0 ] && cat "$REPORT"
}

main "$@"
