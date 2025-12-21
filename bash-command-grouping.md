# Bash 命令分組：{} vs () 快速參考

## 核心差異速查表

| 特性 | `{ cmd; }` 當前 Shell | `( cmd )` 子 Shell |
|------|---------------------|-------------------|
| 執行環境 | 同一進程 | 新建進程 |
| 變數修改 | ✅ 影響外部 | ❌ 不影響外部 |
| 目錄切換 | ⚠️ 會改變 `pwd` | ✅ 隔離不影響 |
| `exit` 行為 | 退出整個腳本 | 只退出子 Shell |
| 性能 | 快 | 慢（fork 開銷）|

---

## 語法規則

```bash
# 當前 Shell - 注意空格和分號
{ cmd1; cmd2; }

# 子 Shell - 無需分號（但加上也可以）
( cmd1; cmd2 )

# 多行寫法
{
    cmd1
    cmd2
}

(
    cmd1
    cmd2
)
```

---

## 使用場景決策樹

```
需要命令分組？
  │
  ├─ 需要修改外部變數？          → 用 {}
  ├─ 需要隔離 cd/環境變數？       → 用 ()
  ├─ 需要局部 exit 不終止腳本？   → 用 ()
  ├─ 需要並行執行（配合 &）？     → 用 ()
  └─ 只是組合命令、重視性能？     → 用 {}
```

---

## 典型案例

### 案例 1：條件命令分組

```bash
# ✅ 使用 {} - 無需隔離，性能更好
[ -z "$files" ] && { echo "Empty"; exit 0; }

# 等價於（但更簡潔）
if [ -z "$files" ]; then
    echo "Empty"
    exit 0
fi
```

### 案例 2：修改外部變數

```bash
count=0

# ✅ 當前 Shell - 成功修改
{ count=10; echo "Set"; }
echo $count  # 10

# ❌ 子 Shell - 修改無效
( count=20; echo "Set"; )
echo $count  # 10（未改變）
```

### 案例 3：臨時切換目錄

```bash
pwd  # /home/user

# ✅ 子 Shell - 隔離目錄切換
( cd /tmp && ls *.log )
pwd  # /home/user（未改變）

# ❌ 當前 Shell - 污染狀態
{ cd /tmp && ls *.log; }
pwd  # /tmp（已改變！）
```

### 案例 4：臨時環境變數

```bash
export DEBUG=0

# ✅ 子 Shell - 隔離環境變數
( export DEBUG=1; ./script.sh )
echo $DEBUG  # 0（未改變）
```

### 案例 5：局部錯誤處理

```bash
# ✅ 子 Shell - exit 不終止主腳本
process() {
    ( cd "$1" || exit 1; grep ERROR *.log )
    echo "Continue..."  # 仍會執行
}

# ❌ 當前 Shell - exit 終止腳本
process() {
    { cd "$1" || exit 1; grep ERROR *.log; }
    echo "Continue..."  # 永遠不會執行
}
```

### 案例 6：並行處理

```bash
# ✅ 子 Shell + 背景執行
for file in *.log; do
    ( analyze "$file"; report "$file" ) &
done
wait
```

### 案例 7：重定向整組輸出

```bash
# ✅ 當前 Shell - 無需隔離
{
    echo "=== Report ==="
    cat data.txt
    echo "=== End ==="
} > report.txt
```

---

## 性能對比

```bash
# {} 循環 1000 次：~0.05 秒
time for i in {1..1000}; do { echo test; } > /dev/null; done

# () 循環 1000 次：~0.8 秒（慢 16 倍）
time for i in {1..1000}; do ( echo test; ) > /dev/null; done
```

**結論**：避免在循環中使用不必要的子 Shell

---

## 最佳實踐

1. **預設用 `{}`**，除非需要隔離副作用
2. **需要隔離時用 `()`**：cd、環境變數、exit
3. **修改變數必須用 `{}`**：子 Shell 無法影響外部
4. **並行執行必須用 `()`**：配合 `&` 背景執行
5. **性能敏感場景避免 `()`**：如大量循環

---

## 常見錯誤

### ❌ 忘記空格和分號

```bash
{echo "test"}           # 錯誤
{ echo "test"}          # 錯誤
{echo "test"; }         # 錯誤
{ echo "test" }         # 錯誤：缺少分號
```

### ✅ 正確寫法

```bash
{ echo "test"; }        # 正確
```

### ❌ 誤用導致變數未修改

```bash
# 在循環中修改計數器
count=0
while read line; do
    ( count=$((count + 1)); )  # ❌ 無效
done < file.txt
echo $count  # 0（未改變）

# 正確寫法
count=0
while read line; do
    count=$((count + 1))       # ✅ 直接修改，無需分組
done < file.txt
echo $count  # 正確的行數
```

---

## 記憶口訣

- **`{}`** = **同一個家**（Same house）→ 修改會影響家裡所有人
- **`()`** = **獨立房間**（Private room）→ 在裡面做什麼都不影響外面

---

## 參考資源

- `man bash` → 搜尋 "Compound Commands"
- [Bash Guide - Command Grouping](https://mywiki.wooledge.org/BashGuide/CompoundCommands#Command_grouping)
