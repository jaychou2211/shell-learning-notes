#!/bin/bash

# 基本函數
sayHello() {
    echo "Hello, World!"
}
sayHello

# 帶參數
greet() {
    echo "Hello, $1 (age $2)"
}
greet "Brad" 36

# 返回值（echo）
add() {
    echo $(( $1 + $2 ))
}
SUM=$(add 10 20)
echo "10 + 20 = $SUM"

# 返回值（return）
isEven() {
    [ $(($1 % 2)) -eq 0 ]
}
isEven 10 && echo "10 is even"

# 局部變數
GLOBAL="global"
testScope() {
    local LOCAL="local"
    echo "Function: $GLOBAL, $LOCAL"
}
testScope
echo "Outside: $GLOBAL"

# 多參數
calcAvg() {
    local sum=0
    local count=$#
    for num in "$@"; do
        sum=$((sum + num))
    done
    echo $((sum / count))
}
AVG=$(calcAvg 10 20 30 40 50)
echo "Average: $AVG"

# 檢查命令
commandExists() {
    command -v "$1" &> /dev/null
}
commandExists "git" && echo "git installed"

# 確認提示
confirm() {
    read -p "$1 (y/n): " resp
    [[ "${resp,,}" =~ ^y ]]
}
confirm "Continue?" && echo "OK" || echo "Cancelled"
