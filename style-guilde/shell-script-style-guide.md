# Shell Script 標準寫法

參考 [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)。

## Principles

- 使用 `snake_case` 命名函數和變數
- 變數展開加引號 `"${var}"`
- 函數內變數使用 `local`
- 錯誤訊息輸出到 STDERR (`>&2`)
- Indent 2 spaces. No tabs.

## 基本結構

```bash
#!/usr/bin/env bash

#==============================================================================
# Usage: ./script.sh [options] [command] [arguments]
#
# {{What this script does}}
#
# Commands:
#     {{command}}    {{description}}
#
# Options:
#     -h, --help     Show help message
#
# Examples:
#     ./script.sh {{example}}
#==============================================================================

set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Exit on pipe failure

#==============================================================================
# Utility Functions
#==============================================================================

print_info() { printf >&2 '\033[36m%s\033[0m\n' "$1"; }
print_action() { printf >&2 '\033[32m%s\033[0m\n' "$1"; }
print_warning() { printf >&2 '\033[33m%s\033[0m\n' "$1"; }
print_error() { printf >&2 '\033[31m%s\033[0m\n' "$1"; }
throw_error() { print_error "$1" && exit "${2:-1}"; }
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
show_help() {
  printf '\n%s\n\n' "$(sed -n '4,/^#==/p' "${BASH_SOURCE[0]}" | sed '/^#===/d; s/^# //; s/^#$//')"
}

#==============================================================================
# Cleanup (視需要實作)
#==============================================================================

# 需要清理臨時檔案、背景程序、檔案鎖時才實作
cleanup() {
  local exit_code=$?
  # rm -f /tmp/script_temp_*_$$
  exit "${exit_code}"
}
trap cleanup EXIT

#==============================================================================
# Configuration & Loaded Variables & Load Environment Variables
#==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly APP_ENV=$(required_env APP_ENV)
readonly APP_PORT=$(optional_env APP_PORT)

#==============================================================================
# Business Functions
#==============================================================================

#######################################
# Deploy application to target environment.
# Globals:
#   APP_ENV - target environment
# Arguments:
#   $1 - version to deploy
# Outputs:
#   Writes deployment status to stdout
# Returns:
#   0 on success, 1 on failure
#######################################
deploy() {
  local version="${1:?Version required}"
  print_action "Deploying ${version} to ${APP_ENV}..."
}

#==============================================================================
# Main
#==============================================================================

main() {
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) show_help; exit 0 ;;
      *) break ;;
    esac
  done

  local target="${1:-}"
  if [[ -z "${target}" ]]; then
    print_error "Target argument required"
    show_help
    exit 1
  fi

  deploy "${target}"
  print_info "Done"
}

# 判斷腳本是「直接執行」還是「被 source 引入」，以決定是否執行 main 函數
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

## Utility Functions

使用標準 print 函數處理訊息輸出，統一輸出到 STDERR 並帶顏色：

| 函數 | 顏色 | 用途 |
|------|------|------|
| `print_info` | 青色 | 一般資訊 |
| `print_action` | 綠色 | 執行中的動作 |
| `print_warning` | 黃色 | 警告訊息 |
| `print_error` | 紅色 | 錯誤訊息 |

```bash
# ✅ 使用 print 函數
print_action "Deploying ${version}..."
print_error "Failed to connect"

# ❌ 直接使用 echo
echo "Deploying..."
echo "Error: failed" >&2
```

## Environment Variable Helpers

使用 `required_env` 和 `optional_env` 處理環境變數：

| 函數 | 用途 |
|------|------|
| `required_env` | 必要變數，未設定則 exit 1 |
| `optional_env` | 可選變數，提供預設值 |

兩者都會：

1. `print_info` 輸出變數名稱和值到 STDERR
2. `echo` 值到 STDOUT 供 command substitution 捕獲

```bash
# ✅ 必要變數 - 未設定會報錯並退出
APP_ENV=$(required_env APP_ENV)
APP_PORT=$(required_env APP_PORT)

# ✅ 可選變數 - 提供預設值
ENABLE_FEATURE=$(optional_env ENABLE_FEATURE false)
MAX_RETRIES=$(optional_env MAX_RETRIES 3)
LOG_LEVEL=$(optional_env LOG_LEVEL "info")

# ❌ 手動檢查
if [[ -z "${APP_ENV}" ]]; then
  echo "Error: APP_ENV is not set" >&2
  exit 1
fi
```

## 命名規範

| 類型 | 格式 | 範例 |
|------|------|------|
| 函數 | `snake_case` | `deploy_nginx_conf()` |
| 常量 | `UPPER_SNAKE_CASE` | `readonly MAX_RETRIES=3` |
| 變數 | `lower_snake_case` | `local file_path=""` |

```bash
# ❌ 避免與內建命令衝突
command=""  # 改用 cmd
test=""     # 改用 is_test
```

## Function Header Comments

任何**不是既顯而易見又簡短**的函數都必須有 header comment。Library 中的所有函數無論長度或複雜度都必須有 header comment。

目標：讓其他人可以只看註解（不看程式碼）就學會如何使用這個函數。

### 格式

```bash
#######################################
# Description of the function.
# Globals:
#   VAR_NAME - description of usage
# Arguments:
#   $1 - description
#   $2 - description (optional)
# Outputs:
#   Side effects (Changes to files, systems, globals, etc.)
# Returns:
#   0 on success, non-zero on failure
#######################################
```

### 欄位說明

| 欄位 | 說明 | 必要性 |
|------|------|--------|
| Description | 函數的用途說明 | 必填 |
| Globals | 使用或修改的全域變數 | 有用到才寫 |
| Arguments | 接收的參數 | 有參數才寫 |
| Outputs | 產生的副作用（檔案、系統、全域變數等） | 有副作用才寫 |
| Returns | 回傳值（非預設的 exit status） | 有特殊回傳才寫 |

### 範例

```bash
#######################################
# Deploy application to specified version.
# Globals:
#   DEPLOY_DIR - deployment directory
# Arguments:
#   $1 - version to deploy
#   $2 - force flag (optional, default: false)
# Outputs:
#   The branch will be checked out to version in DEPLOY_DIR
# Returns:
#   version string on success
#######################################
deploy() {
  local version="${1:?Version required}"
  local force="${2:-false}"
  local force_flag=""
  if [[ "${force}" == "true" ]]; then
    force_flag="--force"
  fi
  cd "${DEPLOY_DIR}"
  git checkout "tags/${version}" "${DEPLOY_DIR}" ${force_flag}
  echo "${version}"
}

# ✅ 簡單且顯而易見的函數 - 可省略 header
print_info() { printf >&2 '\033[36m%s\033[0m\n' "$1"; }
```

## 函數返回值

Bash 函數**不能 return 字串**，只有三種方式：

```bash
# 1. Echo + command substitution
get_version() { echo "1.0.0"; }
version="$(get_version)"

# 2. Return exit status (0-255)
validate() { [[ -n "$1" ]]; }
if validate "${input}"; then echo "Valid"; fi

# 3. 共享變數（不推薦）
RESULT=""; get_data() { RESULT="data"; }
```

## 變數與引號

```bash
# ✅ 使用 ${var} 並加引號
echo "File: ${filename}.txt"
cp "${source}" "${dest}/"

# ✅ Command substitution 分開宣告
local output
output="$(some_command)"
```

## 條件與迴圈

```bash
# ✅ 使用 [[ ]] 和 (( ))
if [[ -z "${var}" ]]; then echo "empty"; fi
if (( count > 10 )); then echo "exceeded"; fi

# ✅ 安全的檔案迭代
while IFS= read -r -d '' file; do
  echo "${file}"
done < <(find "${dir}" -type f -print0)
```

## 陣列

```bash
# 使用 declare -a，分開宣告和賦值
# (local -a 需要 Bash 4.2+，macOS 預設 3.2 不支援)
declare -a flags
flags=(--foo --bar)
flags+=(--baz)
cmd "${flags[@]}"
```

## 禁止事項

```bash
# ❌ eval - 安全風險
eval "${user_input}"

# ❌ 反引號 - 難以嵌套
var="`cmd`"        # ✅ 改用 var="$(cmd)"

# ❌ 未加引號
cp $file $dest     # ✅ 改用 cp "${file}" "${dest}"

# ❌ for + command substitution
for f in $(ls); do # ✅ 改用 for f in *; do
```

## 常用指令最佳實踐

### 時間戳記

```bash
# ✅ 標準格式
timestamp=$(date +%Y%m%d_%H%M%S)      # 20250101_143052
date_only=$(date +%Y-%m-%d)            # 2025-01-01
iso_format=$(date -Iseconds)           # 2025-01-01T14:30:52+08:00
```

### 臨時檔案

使用 `mktemp` 建立，搭配 `trap` 清理：

```bash
# ✅ 安全建立臨時檔案
tmp_file=$(mktemp /tmp/script.XXXXXX)
trap 'rm -f "${tmp_file}"' EXIT

# ✅ 臨時目錄
tmp_dir=$(mktemp -d /tmp/script.XXXXXX)
trap 'rm -rf "${tmp_dir}"' EXIT

# ❌ 不安全
tmp_file="/tmp/my_temp_file"  # 可預測，有安全風險
```

### find 指令

```bash
# ✅ 刪除舊檔案
find "${backup_dir}" -type f -name "*.tar.gz" -mtime +7 -delete

# ✅ 安全迭代（處理檔名含空格）
while IFS= read -r -d '' file; do
  process_file "${file}"
done < <(find "${dir}" -type f -print0)

# ❌ 不安全
for f in $(find "${dir}" -type f); do  # 檔名含空格會出錯
```

## 參考資料

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/)
