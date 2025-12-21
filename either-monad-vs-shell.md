# Either Monad vs Shell Redirection

## 核心概念：雙通道設計

兩者都將「成功」和「失敗」分成兩條獨立的路徑處理。

### Either Monad (Haskell)

```haskell
data Either a b = Left a    -- 錯誤/失敗路徑
                | Right b   -- 成功/正確路徑
```

### Shell Redirection

```bash
command
  ├─ stdout (1)  # 成功/正常輸出
  └─ stderr (2)  # 錯誤/異常訊息
```

## 概念對應表

| Either Monad | Shell | 用途 |
|--------------|-------|------|
| `Right b` | `stdout` (1) | 成功的值/正常輸出 |
| `Left a` | `stderr` (2) | 錯誤/異常訊息 |
| Pattern matching | 重導向符號 | 分別處理兩種情況 |
| Monad bind `>>=` | Pipeline `\|` | 串接操作 |

## 錯誤處理對比

### Either: 顯式模式匹配

```haskell
divide :: Int -> Int -> Either String Int
divide _ 0 = Left "Division by zero"
divide x y = Right (x `div` y)

-- 使用
case divide 10 2 of
    Left err  -> putStrLn $ "Error: " ++ err
    Right val -> putStrLn $ "Result: " ++ show val
```

### Shell: 資料流分流

```bash
# 分別處理成功和錯誤
command > success.txt 2> error.txt
        │              │
     Right 值        Left 值

# 或合併處理
command 2>&1 | processAll
```

## 組合操作對比

### Either: Monadic 鏈式組合

```haskell
-- 串接可能失敗的操作
readFile path >>= parseJSON >>= validate
-- Right 值傳遞下去
-- Left 會短路（不執行後續）
```

**視覺化**：
```
Step1 ──Right──> Step2 ──Right──> Step3 ──Right──> Result
  │                │                │
 Left             Left             Left
  │                │                │
  └────────────────┴────────────────┴──> Error (短路)
```

### Shell: 管道串接

```bash
cat file.txt | grep pattern | sort | uniq
# stdout 沿著管道傳遞
# stderr 可以獨立處理
```

**視覺化**：
```
cat ──stdout──> grep ──stdout──> sort ──stdout──> uniq
 │               │                │               │
stderr          stderr           stderr          stderr
 │               │                │               │
 └───────────────┴────────────────┴───────────────> 可獨立捕獲
```

## 錯誤處理策略

### Either 策略

```haskell
-- 1. 顯式處理
case result of
    Left err  -> handleError err
    Right val -> processValue val

-- 2. 提供預設值
fromRight defaultValue result

-- 3. 轉換錯誤
mapLeft (\err -> "Error: " ++ err) result

-- 4. 組合多個可能失敗的操作
doA >>= doB >>= doC  -- 任一失敗即短路
```

### Shell 策略

```bash
# 1. 分開處理
command > output.txt 2> error.txt

# 2. 合併處理
command 2>&1 | processAll

# 3. 忽略錯誤
command 2> /dev/null

# 4. 只處理錯誤
command > /dev/null 2> error.txt

# 5. 條件執行（短路）
command1 && command2 && command3
```

## 關鍵差異

| 特性 | Either Monad | Shell |
|------|-------------|-------|
| **型別安全** | ✓ 編譯時檢查 | ✗ 執行時動態 |
| **短路行為** | 自動（`>>=` 遇到 Left 停止） | 需明確控制（`&&`） |
| **組合方式** | `fmap`, `<*>`, `>>=` | `\|`, `&&`, `;` |
| **錯誤傳遞** | 型別保證 | 靠約定 |
| **靈活性** | 嚴格但安全 | 靈活但易錯 |

## 實際範例

### Either: 資料處理管線

```haskell
-- 型別保證每一步都處理錯誤
processUser :: String -> Either String User
processUser input = do
    json <- parseJSON input       -- Left 會短路
    user <- validateUser json     -- Left 會短路
    enrichUser user               -- Right 繼續

-- 使用
case processUser rawData of
    Left err   -> logError err
    Right user -> saveUser user
```

### Shell: 日誌處理管線

```bash
# 彈性處理不同資料流
process_logs() {
    cat access.log \
        | grep "ERROR" \
        | awk '{print $1, $5}' \
        | sort \
        | uniq -c \
        > summary.txt 2> errors.log
    # stdout → 摘要
    # stderr → 錯誤日誌
}
```

## 函數式風格的 Shell 腳本

```bash
# 模擬 Either 的錯誤處理
safe_process() {
    local file=$1

    # 驗證（可能失敗）
    [[ -f "$file" ]] || {
        echo "File not found: $file" >&2  # stderr (Left)
        return 1
    }

    # 處理（可能失敗）
    result=$(grep pattern "$file") || {
        echo "Pattern not found" >&2      # stderr (Left)
        return 1
    }

    # 成功
    echo "$result"                        # stdout (Right)
}

# 使用（模擬 pattern matching）
if result=$(safe_process "data.txt"); then
    echo "Success: $result"               # Right case
else
    echo "Failed (see stderr)"            # Left case
fi
```

## 共同哲學：關注點分離

兩者都體現了相同的設計原則：

```
Either Monad              Shell Redirection
     ↓                           ↓
分離「成功」和「失敗」路徑
     ↓                           ↓
獨立處理兩條路徑
     ↓                           ↓
支援組合 (Composition)
```

**Either Monad**: 用型別系統在編譯時保證安全
**Shell**: 用約定和工具在執行時提供彈性

## 總結

```
Either a b        ≈  Shell Command
  ├─ Left a       ≈    stderr (2)  ──> 2> error.log
  └─ Right b      ≈    stdout (1)  ──> > output.txt

Pattern match     ≈  Redirection
Monad bind (>>=)  ≈  Pipeline (|)
Short-circuit     ≈  && operator
```

**相似**: 雙通道設計、關注點分離、可組合性
**不同**: 型別安全 vs 動態靈活、自動短路 vs 手動控制
