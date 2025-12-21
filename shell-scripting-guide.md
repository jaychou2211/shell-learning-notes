# Shell Scripting 技術指南

## 核心概念

### Shell vs Bash
- **Shell**: 命令行解釋器，用戶與 Kernel 的接口
- **Bash**: Bourne-Again Shell，最常用的 Shell 實作
- **Shebang**: `#!/bin/bash` 指定解釋器路徑

### 執行方式
```bash
chmod +x script.sh    # 賦予執行權限
./script.sh           # 執行
bash script.sh        # 或直接用 bash 執行
```

---

## 變數

### 定義與使用
```bash
VAR="value"           # 定義（等號兩邊無空格）
echo "$VAR"           # 使用（推薦加雙引號）
echo "${VAR}"         # 更安全的寫法
```

### 陣列
```bash
ARRAY=("a" "b" "c")
${ARRAY[0]}           # 第一個元素
${ARRAY[@]}           # 所有元素
${#ARRAY[@]}          # 陣列長度
```

### 命令替換
```bash
RESULT=$(command)     # 將命令輸出存入變數
DATE=$(date +%Y%m%d)
```

### 特殊變數
```bash
$0      # 腳本名稱
$1-$9   # 位置參數
$#      # 參數數量
$@      # 所有參數（分別引用）
$?      # 上個命令退出狀態
$$      # 當前進程 ID
```

---

## 條件判斷

### 基本語法
```bash
if [ condition ]; then
    # commands
elif [ condition ]; then
    # commands
else
    # commands
fi
```

### 比較運算符

**數值:**
```bash
-eq  -ne  -gt  -lt  -ge  -le
```

**字串:**
```bash
=    !=    -z    -n
```

**檔案:**
```bash
-e    # 存在
-f    # 是檔案
-d    # 是目錄
-r    # 可讀
-w    # 可寫
-x    # 可執行
```

### Case 語句
```bash
case "$VAR" in
    pattern1)
        # commands
        ;;
    pattern2|pattern3)
        # commands
        ;;
    *)
        # default
        ;;
esac
```

---

## 迴圈

### For 迴圈
```bash
for i in {1..10}; do
    echo $i
done

for item in "${array[@]}"; do
    echo $item
done

for file in *.sh; do
    echo $file
done
```

### While 迴圈
```bash
while [ condition ]; do
    # commands
done

while read line; do
    echo $line
done < file.txt
```

### 迴圈控制
```bash
break       # 跳出迴圈
continue    # 跳過當前迭代
```

---

## 函數

### 定義與呼叫
```bash
func_name() {
    local var=$1
    echo $var
}

func_name "arg"
```

### 返回值
```bash
# 方法 1: return（僅支援 0-255）
func() {
    return 0
}

# 方法 2: echo（推薦）
func() {
    echo "result"
}
result=$(func)
```

### 作用域
```bash
local VAR="value"     # 局部變數
GLOBAL="value"        # 全域變數
```

---

## 輸入輸出

### 重導向
```bash
>      # 覆寫輸出
>>     # 附加輸出
<      # 輸入重導向
2>     # 錯誤輸出
&>     # 標準輸出與錯誤
|      # 管道
```

### 用戶輸入
```bash
read -p "Prompt: " VAR
read -sp "Password: " PASS    # 隱藏輸入
```

---

## 文字處理

### AWK
```bash
awk '{print $1}' file.txt           # 第一欄
awk -F',' '{print $2}' data.csv     # 指定分隔符
```

### SED
```bash
sed 's/old/new/g' file.txt          # 全局替換
sed -i.bak 's/old/new/g' file.txt   # 修改並備份
```

### Grep
```bash
grep "pattern" file.txt
grep -r "pattern" dir/
grep -v "pattern" file.txt          # 反向匹配
```

---

## 權限管理

### chmod 數字表示法
```
r=4  w=2  x=1

7 = rwx
6 = rw-
5 = r-x
4 = r--

chmod 755 script.sh    # rwxr-xr-x
chmod 644 file.txt     # rw-r--r--
```

---

## 錯誤處理

### 嚴格模式
```bash
set -e              # 遇錯即停
set -u              # 未定義變數報錯
set -o pipefail     # 管道任一失敗即報錯

# 組合使用
set -euo pipefail
```

### 退出狀態
```bash
command
if [ $? -eq 0 ]; then
    echo "成功"
else
    echo "失敗"
fi
```

---

## 實用模式

### 參數解析
```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--version)
            echo "v1.0"
            ;;
        *)
            shift
            ;;
    esac
done
```

### 檢查命令存在
```bash
command -v cmd &> /dev/null || {
    echo "cmd not found"
    exit 1
}
```

### 臨時檔案
```bash
TEMP=$(mktemp)
trap "rm -f $TEMP" EXIT
```

### Here Document
```bash
cat << 'EOF' > file.txt
content line 1
content line 2
EOF
```

---

## 常用指令速查

```bash
# 檔案操作
ls, cd, pwd, mkdir, touch, cp, mv, rm

# 文字處理
cat, less, grep, awk, sed, cut, sort, uniq

# 系統資訊
df, du, free, top, ps, uname

# 網路
ping, curl, wget, ssh, scp

# 壓縮
tar -czf archive.tar.gz dir/
tar -xzf archive.tar.gz
```

---

## 範例索引

- [01-hello-world.sh](examples/01-hello-world.sh) - 基本結構
- [02-variables.sh](examples/02-variables.sh) - 變數操作
- [03-user-input.sh](examples/03-user-input.sh) - 輸入處理
- [04-conditionals.sh](examples/04-conditionals.sh) - 條件判斷
- [05-case-statement.sh](examples/05-case-statement.sh) - Case 語句
- [06-for-loop.sh](examples/06-for-loop.sh) - For 迴圈
- [07-while-loop.sh](examples/07-while-loop.sh) - While 迴圈
- [08-functions.sh](examples/08-functions.sh) - 函數定義
- [09-file-operations.sh](examples/09-file-operations.sh) - 檔案操作
- [10-log-analyzer.sh](examples/10-log-analyzer.sh) - 日誌分析
- [11-backup.sh](examples/11-backup.sh) - 自動備份
- [12-network-monitor.sh](examples/12-network-monitor.sh) - 網路監控

---

## 參考資源

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [Explain Shell](https://explainshell.com/)
