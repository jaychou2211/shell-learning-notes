#!/bin/bash

# 數字範圍
for i in {1..5}; do
    echo "Number: $i"
done

# 陣列遍歷
FRUITS=("Apple" "Banana" "Orange")
for fruit in "${FRUITS[@]}"; do
    echo "- $fruit"
done

# C 風格
for ((i=1; i<=5; i++)); do
    echo "Count: $i"
done

# 檔案遍歷
for file in *.sh; do
    [ -f "$file" ] && echo "Script: $file"
done

# 批次重命名
mkdir -p /tmp/test-rename
cd /tmp/test-rename
touch file{1..3}.txt

for file in *.txt; do
    mv "$file" "new-${file}"
done
ls -1
cd - > /dev/null
rm -rf /tmp/test-rename

# 巢狀迴圈
for i in {1..3}; do
    for j in {1..3}; do
        echo -n "$i x $j = $((i*j))  "
    done
    echo
done

# 條件跳過
for i in {1..10}; do
    [ $((i % 2)) -eq 0 ] && echo "Even: $i"
done
