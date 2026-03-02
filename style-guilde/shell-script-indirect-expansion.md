# Shell Script — 間接展開與環境變數 Helper

本文件深入解釋 `shell-script-style-guide.md` 中 `required_env` / `optional_env` 的每個細節。

## 完整 Pattern

```bash
required_env() {
  local value="${!1:-}"
  if [[ -z "${value}" ]]; then
    print_error "Required environment variable ${1} is not set"
    exit 1
  fi
  print_info "${1}=${value}"
  echo "${value}"
}
optional_env() {
  local value="${!1:-${2}}"
  print_info "${1}=${value}"
  echo "${value}"
}
```

---

## 1. `${!var}` — Indirect Expansion（間接展開）

一般的變數展開是「取變數本身的值」：

```bash
name="hello"
echo "${name}"   # hello
```

加上 `!` 變成「把變數的值當作另一個變數名，再取那個變數的值」：

```bash
APP_PORT="3000"
var_name="APP_PORT"
echo "${!var_name}"   # 3000
```

展開過程：

```
${!var_name}
  ↓ 先取 var_name 的值
${APP_PORT}
  ↓ 再取 APP_PORT 的值
"3000"
```

### 在函式中搭配 `$1`

`$1` 是函式的第一個參數。當 `$1="APP_PORT"` 時：

```
${!1}
  ↓ 先取 $1 的值
${APP_PORT}
  ↓ 再取 APP_PORT 的值
"3000"
```

這讓函式可以用「變數名稱」作為參數，動態讀取任意環境變數。

### 對應其他語言的概念

| 語言 | 對應寫法 |
|------|---------|
| Shell | `${!var_name}` |
| JavaScript | `process.env[varName]` |
| PHP | `$$varName` (variable variables) |
| Python | `os.environ[var_name]` |

---

## 2. `:-` — Default Value（預設值）

`${var:-default}` 表示：如果 `var` 為空或未設定，就用 `default`。

```bash
# 假設 APP_PORT 未設定
echo "${APP_PORT:-3000}"   # 3000

# 假設 APP_PORT="8080"
echo "${APP_PORT:-3000}"   # 8080
```

### Bash 的四種參數展開

| 語法 | var 未設定 | var 為空字串 | var 有值 |
|------|-----------|-------------|---------|
| `${var:-default}` | default | default | var 的值 |
| `${var-default}` | default | 空字串 | var 的值 |
| `${var:=default}` | 設定並回傳 default | 設定並回傳 default | var 的值 |
| `${var:?error}` | 印 error 並 exit | 印 error 並 exit | var 的值 |

---

## 3. 組合：`${!1:-}` 和 `${!1:-${2}}`

### `${!1:-}` — 間接展開 + 預設空字串

```
${!1:-}
 ^ ^  ^
 | |  └── 預設值：空字串
 | └──── $1 的值作為變數名
 └────── 間接展開
```

用在 `required_env`：先嘗試讀取環境變數，讀不到就得到空字串，再用 `[[ -z ]]` 判斷後報錯。

```bash
# 呼叫: required_env "APP_PORT"
# 如果 APP_PORT 未設定：
local value="${!1:-}"    # value=""  → 觸發 exit 1
# 如果 APP_PORT="3000"：
local value="${!1:-}"    # value="3000"  → 正常繼續
```

### `${!1:-${2}}` — 間接展開 + 預設值參數

```
${!1:-${2}}
 ^ ^   ^^
 | |   └└── $2（第二個參數）作為預設值
 | └────── $1 的值作為變數名
 └──────── 間接展開
```

用在 `optional_env`：讀不到就用函式的第二個參數當預設值。

```bash
# 呼叫: optional_env "APP_PORT" "3000"
# 如果 APP_PORT 未設定：
local value="${!1:-${2}}"    # value="3000"（用預設值）
# 如果 APP_PORT="8080"：
local value="${!1:-${2}}"    # value="8080"（用環境變數的值）
```

---

## 4. 雙輸出 Pattern：STDERR 顯示 + STDOUT 回傳

這兩個函式都有兩行輸出，各有不同用途：

```bash
print_info "${1}=${value}"   # → STDERR（顯示給人看）
echo "${value}"              # → STDOUT（給程式捕獲）
```

### 為什麼要分兩個 channel？

Command substitution `$()` 只捕獲 STDOUT：

```bash
APP_PORT=$(optional_env APP_PORT 3000)
```

執行時：

```
STDERR（螢幕顯示）: APP_PORT=3000     ← print_info 輸出，人看到
STDOUT（被捕獲）:   3000               ← echo 輸出，存進 APP_PORT 變數
```

如果兩者都用 `echo`（都走 STDOUT），變數會捕獲到多餘的文字：

```bash
# ❌ 如果 print_info 也走 STDOUT
APP_PORT=$(optional_env APP_PORT 3000)
# APP_PORT 的值變成 "APP_PORT=3000\n3000"，而不是 "3000"
```

### 流程圖

```
optional_env "APP_PORT" "3000"
│
├─ print_info "APP_PORT=3000"  ──→ STDERR ──→ 終端機畫面
│                                              （藍色文字，人看到）
│
└─ echo "3000"  ──→ STDOUT ──→ $(...) 捕獲
                                ──→ APP_PORT="3000"
```

---

## 5. 完整使用範例

```bash
# .env 檔案內容：
# NODE_ENV=production
# APP_PORT=8080

source .env

# 必要變數 — 沒設定就 exit 1
NODE_ENV=$(required_env NODE_ENV)           # ✅ "production"
DB_HOST=$(required_env DB_HOST)             # ❌ exit 1, 印出紅色錯誤

# 可選變數 — 沒設定就用預設值
APP_PORT=$(optional_env APP_PORT 3000)      # "8080"（.env 有設定）
LOG_LEVEL=$(optional_env LOG_LEVEL "info")  # "info"（沒設定，用預設）
MAX_RETRIES=$(optional_env MAX_RETRIES 3)   # "3"（沒設定，用預設）
```

### 對比：手動寫法

```bash
# ❌ 沒有用 helper — 重複且容易遺漏
if [[ -z "${NODE_ENV:-}" ]]; then
  echo "Error: NODE_ENV is not set" >&2
  exit 1
fi
echo "NODE_ENV=${NODE_ENV}" >&2

APP_PORT="${APP_PORT:-3000}"
echo "APP_PORT=${APP_PORT}" >&2
```

用 `required_env` / `optional_env` 把這些邏輯封裝起來，每個環境變數只需要一行。
