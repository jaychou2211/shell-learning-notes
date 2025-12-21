#!/bin/bash

TEST_DIR="/tmp/file-ops"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 輸出重導向
echo "Line 1" > file1.txt
echo "Line 2" >> file1.txt
cat file1.txt

# Here Document
cat > multi.txt << 'EOF'
Line A
Line B
Line C
EOF
cat multi.txt

# 管道
echo "Apple
Banana
Orange" > fruits.txt
cat fruits.txt | grep 'a'
cat fruits.txt | sort

# 標準錯誤
ls nonexist 2> /dev/null

# 逐行讀取
cat > data.txt << EOF
Alice:25:Engineer
Bob:30:Designer
Charlie:28:Manager
EOF

while IFS=':' read -r name age role; do
    echo "$name - $role ($age)"
done < data.txt

# AWK
awk -F':' '{print $1}' data.txt
awk -F':' '{print $1 " - " $3}' data.txt

# SED
echo "hello world" | sed 's/world/shell/g'
sed 's/Alice/ALICE/g' data.txt

# 臨時檔案
TEMP=$(mktemp)
echo "temp data" > "$TEMP"
cat "$TEMP"
rm "$TEMP"

# 清理
cd - > /dev/null
rm -rf "$TEST_DIR"
