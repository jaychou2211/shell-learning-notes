#!/bin/bash

# 基本 while
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    ((COUNT++))
done

# 讀取檔案
TEMP="/tmp/test-lines.txt"
cat > "$TEMP" << EOF
Line 1
Line 2
Line 3
EOF

LINE_NUM=1
while read -r line; do
    echo "$LINE_NUM: $line"
    ((LINE_NUM++))
done < "$TEMP"
rm "$TEMP"

# Until 迴圈
NUM=1
until [ $NUM -gt 5 ]; do
    echo "Number: $NUM"
    ((NUM++))
done

# 倒數計時
SECONDS=3
while [ $SECONDS -gt 0 ]; do
    echo "$SECONDS..."
    sleep 1
    ((SECONDS--))
done
echo "Done"

# 檔案監控（10秒）
MONITOR="/tmp/monitor.txt"
ELAPSED=0
touch "$MONITOR"

while [ $ELAPSED -lt 10 ]; do
    SIZE=$(stat -f%z "$MONITOR" 2>/dev/null || stat -c%s "$MONITOR" 2>/dev/null)
    echo "[$ELAPSED s] Size: $SIZE bytes"
    sleep 2
    ((ELAPSED+=2))
done
rm -f "$MONITOR"
