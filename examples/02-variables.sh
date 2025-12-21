#!/bin/bash

# 基本變數
NAME="Brad"
AGE=36
echo "Name: $NAME, Age: $AGE"

# 陣列
FRUITS=("Apple" "Banana" "Orange")
echo "First: ${FRUITS[0]}"
echo "All: ${FRUITS[@]}"
echo "Count: ${#FRUITS[@]}"

for fruit in "${FRUITS[@]}"; do
    echo "- $fruit"
done

# 命令替換
CURRENT_DIR=$(pwd)
CURRENT_DATE=$(date +%Y-%m-%d)
FILE_COUNT=$(ls -1 | wc -l)

echo "Directory: $CURRENT_DIR"
echo "Date: $CURRENT_DATE"
echo "Files: $FILE_COUNT"
