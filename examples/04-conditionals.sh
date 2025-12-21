#!/bin/bash

# 基本 if
NAME="Brad"
[ "$NAME" = "Brad" ] && echo "Match"

# if-else
AGE=20
if [ $AGE -ge 18 ]; then
    echo "Adult"
else
    echo "Minor"
fi

# if-elif-else
SCORE=85
if [ $SCORE -ge 90 ]; then
    echo "A"
elif [ $SCORE -ge 80 ]; then
    echo "B"
elif [ $SCORE -ge 70 ]; then
    echo "C"
else
    echo "D"
fi

# 數值比較
NUM1=10
NUM2=20
[ $NUM1 -lt $NUM2 ] && echo "$NUM1 < $NUM2"

# 字串比較
STR="hello"
[ -n "$STR" ] && echo "Not empty"

# 檔案測試
FILE="/tmp/test.txt"
touch "$FILE"
[ -f "$FILE" ] && echo "File exists"
rm "$FILE"

# 多重條件
USER="admin"
PASS="secret"
[[ "$USER" == "admin" && "$PASS" == "secret" ]] && echo "Login OK"
