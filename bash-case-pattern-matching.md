# Bash Case 語句：Shell 的 Pattern Matching

## 目錄
- [基本語法](#基本語法)
- [核心概念](#核心概念)
- [Pattern Matching 語法詳解](#pattern-matching-語法詳解)
- [Glob Pattern 本質](#glob-pattern-本質)
- [與其他語言比較](#與其他語言比較)
- [實戰範例](#實戰範例)

---

## 基本語法

```bash
case "$VARIABLE" in
    pattern1)
        # 執行的命令
        ;;
    pattern2 | pattern3)
        # 多個 pattern (OR 邏輯)
        ;;
    *)
        # 預設情況 (wildcard)
        ;;
esac  # case 反寫，結束語句
```

---

## 核心概念

### Bash Case 的本質：**字串 Glob Matching**

Bash 的 case 語句不是簡單的值比對，而是基於 **glob pattern matching**，這是 Unix shell 用於匹配檔名和字串的模式匹配機制。

**關鍵特性：**
- 使用 glob patterns（如 `*`, `?`, `[...]`）而非正則表達式
- 順序匹配：從上到下，找到第一個匹配就停止執行
- 字串導向：主要用於處理字串和檔名，而非結構化資料

---

## Pattern Matching 語法詳解

### 1. 字元類別 `[...]`

```bash
[yY]          # 匹配 y 或 Y
[nN]          # 匹配 n 或 N
[0-9]         # 匹配任何數字 0-9
[a-zA-Z]      # 匹配任何字母
[!0-9]        # 匹配任何非數字字元
```

**範例：**
```bash
case "$INPUT" in
    [yY])
        echo "You entered y or Y"
        ;;
    [0-9])
        echo "You entered a single digit"
        ;;
esac
```

### 2. 多字元組合 `[x][y][z]`

```bash
[yY][eE][sS]  # 匹配 yes 的所有大小寫組合
              # yes, Yes, YES, yEs, YeS, yeS, YEs, yES
```

**範例：**
```bash
read -p "Continue? " ANSWER

case "$ANSWER" in
    [yY] | [yY][eE][sS])
        # 匹配: y, Y, yes, Yes, YES, yEs, etc.
        echo "Continuing..."
        ;;
    [nN] | [nN][oO])
        # 匹配: n, N, no, No, NO, nO
        echo "Stopping..."
        ;;
esac
```

### 3. OR 運算子 `|`

```bash
pattern1 | pattern2 | pattern3
# 匹配其中任何一個 pattern
```

**範例：**
```bash
case "$FRUIT" in
    apple | banana | orange)
        echo "Common fruit"
        ;;
    strawberry | blueberry | raspberry)
        echo "Berry family"
        ;;
esac
```

### 4. 萬用字元 Wildcards

| 符號 | 意義 | 範例 | 匹配 |
|------|------|------|------|
| `*` | 匹配任何字串（包含空字串） | `*.txt` | 任何 .txt 結尾的字串 |
| `?` | 匹配任何單一字元 | `?.log` | a.log, b.log, 1.log |
| `[abc]` | 匹配括號內任一字元 | `[abc].txt` | a.txt, b.txt, c.txt |
| `[a-z]` | 匹配範圍內字元 | `[0-9][0-9]` | 00 到 99 |
| `[!abc]` | 匹配不在括號內的字元 | `[!0-9]` | 任何非數字 |

### 5. 預設情況 `*)`

```bash
*)
    # 匹配所有其他情況
    # 類似其他語言的 default 或 else
    # 應該放在最後
```

### 6. 分支結束符號 `;;`

```bash
pattern)
    command1
    command2
    ;;  # 結束此分支，跳出整個 case 語句
```

**重要：** `;;` 類似其他語言的 `break`，告訴 shell「這個分支執行完畢，離開 case」

---

## Glob Pattern 本質

### 什麼是 Glob Patterns？

Glob patterns 是 Unix shell 用於檔名匹配的模式語法，Bash case 繼承了這個機制。

### 檔名匹配範例

```bash
case "$FILENAME" in
    *.txt)
        echo "Text file"
        ;;

    *.{jpg,png,gif})
        echo "Image file"
        ;;

    [Mm]akefile)
        echo "Build file (Makefile or makefile)"
        ;;

    ???.log)
        echo "Log file with exactly 3-character name"
        # 匹配: abc.log, 123.log, foo.log
        # 不匹配: ab.log, abcd.log
        ;;

    backup-[0-9][0-9][0-9][0-9].tar.gz)
        echo "Numbered backup archive"
        # 匹配: backup-2024.tar.gz, backup-1999.tar.gz
        ;;

    *)
        echo "Unknown file type"
        ;;
esac
```

### 字串前綴/後綴匹配

```bash
case "$URL" in
    http://*)
        echo "HTTP URL"
        ;;

    https://*)
        echo "HTTPS URL"
        ;;

    ftp://*)
        echo "FTP URL"
        ;;

    *github.com*)
        echo "GitHub URL"
        ;;

    *.git)
        echo "Git repository URL"
        ;;
esac
```

### 為什麼叫 "Glob"？

"Glob" 來自 "global"，最早用於 Unix 的 `glob` 命令，用於展開檔名模式。

```bash
# Shell 中的 glob 展開
ls *.txt        # 展開為所有 .txt 檔案
rm file?.log    # 刪除 file1.log, file2.log 等
```

Bash case 使用相同的匹配邏輯，但應用在字串比對而非檔案系統。

---

## 與其他語言比較

### Bash vs Haskell

#### Bash 實現

```bash
case "$ANSWER" in
    [yY] | [yY][eE][sS])
        echo "Yes!"
        ;;
    [nN] | [nN][oO])
        echo "No!"
        ;;
    *)
        echo "Unknown"
        ;;
esac
```

#### Haskell 等效實現

```haskell
-- 方法 1: 使用 case of
import Data.Char (toLower)

processAnswer :: String -> String
processAnswer answer = case map toLower answer of
    "y"   -> "Yes!"
    "yes" -> "Yes!"
    "n"   -> "No!"
    "no"  -> "No!"
    _     -> "Unknown"  -- 對應 Bash 的 *)

-- 方法 2: 使用 pattern matching + guards
processAnswer' :: String -> String
processAnswer' answer
    | answer `elem` ["y", "Y", "yes", "Yes", "YES"] = "Yes!"
    | answer `elem` ["n", "N", "no", "No", "NO"]    = "No!"
    | otherwise                                      = "Unknown"

-- 方法 3: 函數定義中的 pattern matching
processAnswer'' :: String -> String
processAnswer'' "y"   = "Yes!"
processAnswer'' "Y"   = "Yes!"
processAnswer'' "yes" = "Yes!"
processAnswer'' "Yes" = "Yes!"
processAnswer'' "YES" = "Yes!"
processAnswer'' "n"   = "No!"
processAnswer'' "N"   = "No!"
processAnswer'' "no"  = "No!"
processAnswer'' "No"  = "No!"
processAnswer'' "NO"  = "No!"
processAnswer'' _     = "Unknown"
```

#### Glob Pattern 在 Haskell 中的等效

Bash 的 glob patterns 在 Haskell 需要使用字串函數：

```haskell
import Data.List (isPrefixOf, isSuffixOf, isInfixOf)

processFile :: String -> String
processFile filename
    | ".txt" `isSuffixOf` filename     = "Text file"       -- *.txt
    | ".jpg" `isSuffixOf` filename     = "Image file"      -- *.jpg
    | "backup-" `isPrefixOf` filename  = "Backup file"     -- backup-*
    | "temp" `isInfixOf` filename      = "Temporary file"  -- *temp*
    | otherwise                        = "Unknown"
```

**對應關係：**
- Bash `*)` ↔ Haskell `_` (wildcard pattern)
- Bash `|` ↔ Haskell 需要多個 pattern 或使用 `elem`
- Bash `;;` ↔ Haskell 的分支結束是隱式的

---

### Bash vs Rust

#### Bash 實現

```bash
case "$FRUIT" in
    apple)
        echo "Red fruit"
        ;;
    banana | orange)
        echo "Tropical fruit"
        ;;
    berry*)
        echo "Some kind of berry"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

#### Rust 等效實現

```rust
fn process_fruit(fruit: &str) -> &str {
    match fruit {
        "apple" => "Red fruit",
        "banana" | "orange" => "Tropical fruit",  // | 語法相同！
        _ => "Unknown fruit",                      // _ 對應 *)
    }
}

// Glob patterns 需要額外處理
fn process_fruit_with_patterns(fruit: &str) -> &str {
    match fruit {
        "apple" => "Red fruit",
        "banana" | "orange" => "Tropical fruit",

        // Bash 的 berry* 需要用 if guard
        s if s.starts_with("berry") => "Some kind of berry",

        _ => "Unknown fruit",
    }
}

// 檔名匹配範例
fn process_filename(filename: &str) -> &str {
    match filename {
        // Bash: *.txt
        s if s.ends_with(".txt") => "Text file",

        // Bash: *.{jpg,png}
        s if s.ends_with(".jpg") || s.ends_with(".png") => "Image file",

        // Bash: [Mm]akefile
        "Makefile" | "makefile" => "Build file",

        _ => "Unknown file type",
    }
}
```

#### 使用 Rust 的 glob 庫

```rust
use glob::Pattern;

fn process_with_glob(filename: &str) -> &str {
    if Pattern::new("*.txt").unwrap().matches(filename) {
        return "Text file";
    }
    if Pattern::new("backup-[0-9][0-9][0-9][0-9].tar.gz").unwrap().matches(filename) {
        return "Backup archive";
    }
    "Unknown"
}
```

**Rust 的優勢：**
- 編譯時檢查 pattern 是否窮盡（exhaustiveness checking）
- 型別安全：不僅能匹配字串，還能解構任何資料型別
- `|` 語法和 Bash 完全一樣
- `_` wildcard 和 Bash `*)` 概念相同

---

## 核心差異總結

| 特性 | Bash Case | Haskell Pattern Matching | Rust Pattern Matching |
|------|-----------|--------------------------|------------------------|
| **本質** | 字串 glob matching | 代數資料型別解構 | 代數資料型別解構 |
| **Pattern 類型** | Glob patterns (`*`, `?`, `[...]`) | 建構子、字面值、wildcard | 建構子、字面值、wildcard |
| **多重 pattern** | `\|` | 多個 case 或 guards | `\|` |
| **Wildcard** | `*)` | `_` | `_` |
| **類型安全** | ❌ 無 | ✅ 編譯時檢查 | ✅ 編譯時檢查 |
| **窮盡性檢查** | ❌ 不檢查 | ✅ 編譯器強制 | ✅ 編譯器強制 |
| **主要用途** | 檔名、使用者輸入 | 任何資料結構 | 任何資料結構 |
| **Guards** | ❌ 不支援 | ✅ `\|` guards | ✅ `if` guards |

---

## 實戰範例

### 範例 1: 處理命令列選項

```bash
#!/bin/bash

read -p "Choose an action (start/stop/restart/status): " ACTION

case "$ACTION" in
    start | s)
        echo "Starting service..."
        # systemctl start myservice
        ;;

    stop | S)
        echo "Stopping service..."
        # systemctl stop myservice
        ;;

    restart | r | reload)
        echo "Restarting service..."
        # systemctl restart myservice
        ;;

    status | stat | st)
        echo "Checking status..."
        # systemctl status myservice
        ;;

    *)
        echo "Invalid action: $ACTION"
        echo "Usage: start|stop|restart|status"
        exit 1
        ;;
esac
```

### 範例 2: 檔案類型處理器

```bash
#!/bin/bash

for file in *; do
    case "$file" in
        *.txt)
            echo "Processing text file: $file"
            wc -l "$file"
            ;;

        *.jpg | *.png | *.gif)
            echo "Processing image: $file"
            # convert "$file" -resize 800x600 "thumb-$file"
            ;;

        *.sh)
            echo "Shell script: $file"
            if [ -x "$file" ]; then
                echo "  ✓ Executable"
            else
                echo "  ✗ Not executable"
            fi
            ;;

        [Mm]akefile)
            echo "Build file detected: $file"
            ;;

        .*)
            echo "Hidden file: $file (skipping)"
            ;;

        *)
            echo "Unknown file type: $file"
            ;;
    esac
done
```

### 範例 3: URL 路由處理

```bash
#!/bin/bash

URL="$1"

case "$URL" in
    http://localhost*)
        echo "Local development server"
        ;;

    https://*.github.com/*)
        echo "GitHub repository"
        # 可以進一步解析 repo 名稱
        ;;

    https://*/api/*)
        echo "API endpoint detected"
        ;;

    ftp://*)
        echo "FTP protocol (consider using SFTP instead)"
        ;;

    */download/*.zip | */download/*.tar.gz)
        echo "Downloadable archive"
        ;;

    *)
        echo "Unrecognized URL pattern"
        ;;
esac
```

### 範例 4: 語義化版本號檢查

```bash
#!/bin/bash

VERSION="$1"

case "$VERSION" in
    [0-9].[0-9].[0-9])
        echo "Valid semantic version: $VERSION"
        ;;

    [0-9][0-9].[0-9][0-9].[0-9][0-9])
        echo "Valid semantic version (double digits): $VERSION"
        ;;

    v[0-9]*)
        echo "Version with 'v' prefix: $VERSION"
        ;;

    *-alpha* | *-beta* | *-rc*)
        echo "Pre-release version: $VERSION"
        ;;

    *)
        echo "Invalid version format: $VERSION"
        echo "Expected: X.Y.Z or vX.Y.Z"
        exit 1
        ;;
esac
```

### 範例 5: 環境檢測

```bash
#!/bin/bash

OS="$(uname -s)"

case "$OS" in
    Linux*)
        echo "Linux system detected"
        PACKAGE_MANAGER="apt"
        ;;

    Darwin*)
        echo "macOS system detected"
        PACKAGE_MANAGER="brew"
        ;;

    CYGWIN* | MINGW* | MSYS*)
        echo "Windows system detected"
        PACKAGE_MANAGER="choco"
        ;;

    *)
        echo "Unknown operating system: $OS"
        exit 1
        ;;
esac

echo "Using package manager: $PACKAGE_MANAGER"
```

---

## 進階技巧

### 1. 大小寫不敏感匹配

```bash
# 方法 1: 手動列舉所有大小寫組合
case "$INPUT" in
    [yY][eE][sS]) echo "Yes" ;;
esac

# 方法 2: 先轉換為小寫 (Bash 4+)
case "${INPUT,,}" in
    yes) echo "Yes" ;;
esac

# 方法 3: 使用 shopt (Bash 4+)
shopt -s nocasematch
case "$INPUT" in
    yes) echo "Yes" ;;
esac
shopt -u nocasematch
```

### 2. 嵌套 case 語句

```bash
case "$FILE_TYPE" in
    image)
        case "$FILE_EXT" in
            jpg | jpeg) echo "JPEG image" ;;
            png)        echo "PNG image" ;;
            *)          echo "Other image format" ;;
        esac
        ;;
    document)
        case "$FILE_EXT" in
            pdf)  echo "PDF document" ;;
            docx) echo "Word document" ;;
            *)    echo "Other document format" ;;
        esac
        ;;
esac
```

### 3. 結合條件判斷

```bash
case "$FILE" in
    *.txt)
        if [ -r "$FILE" ]; then
            echo "Readable text file: $FILE"
            cat "$FILE"
        else
            echo "Text file not readable: $FILE"
        fi
        ;;
esac
```

---

## 常見陷阱與注意事項

### 1. 引號的重要性

```bash
# ✗ 錯誤：沒有引號，如果變數包含空格會出問題
case $FILE in
    *.txt) echo "text" ;;
esac

# ✓ 正確：總是使用引號
case "$FILE" in
    *.txt) echo "text" ;;
esac
```

### 2. 忘記 `;;` 導致 fall-through

```bash
# ✗ 錯誤：缺少 ;;
case "$INPUT" in
    yes)
        echo "Yes"  # 會繼續執行下一個 case！
    no)
        echo "No"
        ;;
esac

# ✓ 正確
case "$INPUT" in
    yes)
        echo "Yes"
        ;;
    no)
        echo "No"
        ;;
esac
```

### 3. Pattern 順序很重要

```bash
# ✗ 錯誤：通配符在前面會捕獲所有內容
case "$FILE" in
    *)
        echo "Unknown"
        ;;
    *.txt)
        echo "Text file"  # 永遠不會執行到！
        ;;
esac

# ✓ 正確：特定 pattern 在前，通配符在後
case "$FILE" in
    *.txt)
        echo "Text file"
        ;;
    *)
        echo "Unknown"
        ;;
esac
```

---

## 總結

Bash 的 case 語句本質上是 **字串 glob pattern matching**，它：

1. **繼承自 Unix 的檔名匹配機制**
   - 使用 `*`, `?`, `[...]` 等 glob patterns
   - 專為字串和檔名設計

2. **有 pattern matching 的特徵**
   - Wildcard (`*)`) 類似 Haskell/Rust 的 `_`
   - 多重 pattern (`|`) 和 Rust 語法相同
   - 順序匹配，找到就停止

3. **但不是真正的代數資料型別 pattern matching**
   - 無型別安全
   - 無窮盡性檢查
   - 無法解構複雜資料結構

4. **實用場景**
   - 處理使用者輸入
   - 檔案類型判斷
   - 命令列選項解析
   - URL/路徑處理

如果你熟悉 Haskell 或 Rust 的 pattern matching，可以把 Bash case 想成是「字串專用的簡化版 pattern matching」！
