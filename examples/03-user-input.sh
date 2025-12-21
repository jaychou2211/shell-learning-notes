#!/bin/bash

read -p "Name: " USERNAME
read -p "Age: " USER_AGE
read -sp "Password: " PASSWORD
echo

echo "Name: $USERNAME"
echo "Age: $USER_AGE"
echo "Password length: ${#PASSWORD}"

read -p "Confirm? (y/n) " CONFIRM
[[ "${CONFIRM,,}" == "y" ]] && echo "Saved" || echo "Cancelled"

# ============================================================
# 筆記
# ============================================================

# 1. -sp 選項說明
# ----------------
# read -sp "Password: " PASSWORD
#   -s (silent): 靜默模式，輸入時不會在終端顯示字符，常用於密碼輸入
#   -p (prompt): 指定提示文本

# 2. [[ ]] 增強型條件測試語法
# ----------------------------
# [[ "${CONFIRM,,}" == "y" ]]
#
# [[ ]] 相比傳統 [ ] 的優勢：
#   - 支援模式匹配和正則表達式
#   - 支援 && 和 || 邏輯運算符
#   - 不需要對變數進行引號保護（防止 word splitting）
#   - 支援字串比較操作符 < 和 >
#
# ${CONFIRM,,} 參數擴展：
#   ,, 將字串轉換為小寫
#
# 範例對比：
#   [ "$CONFIRM" = "y" ]      # 傳統語法 - 需要引號保護
#   [[ $CONFIRM == "y" ]]     # 增強語法 - 更安全，功能更強
