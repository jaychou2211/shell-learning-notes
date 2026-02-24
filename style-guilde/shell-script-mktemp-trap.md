# Shell Script — mktemp 與 trap 安全臨時檔案處理

本文件深入解釋 `shell-script.md` 中臨時檔案 pattern 的每個細節。

## 完整 Pattern

```bash
tmp_file=$(mktemp /tmp/script.XXXXXX)
trap 'rm -f "${tmp_file}"' EXIT
```

---

## 1. `mktemp` — 產生不可預測的臨時檔名

```bash
tmp_file=$(mktemp /tmp/script.XXXXXX)
echo "$tmp_file"
# /tmp/script.4kR9z2  ← XXXXXX 被替換成隨機字元
```

| 參數 | 用途 |
|------|------|
| `/tmp/script.XXXXXX` | 模板，`XXXXXX` 會被替換為隨機字元 |
| `-d` | 建立臨時**目錄**而非檔案 |

### 為什麼不直接寫死檔名？

```bash
# ❌ 可預測的固定檔名
tmp_file="/tmp/my_temp_file"
```

**Symlink Attack**：攻擊者知道 script 會寫入 `/tmp/my_temp_file`，可以預先建立 symlink：

```bash
# 攻擊者預先做
ln -s /etc/passwd /tmp/my_temp_file
```

script 一寫入，實際上就是在覆寫 `/etc/passwd`。

`mktemp` 產生的檔名帶隨機字元，攻擊者無法預測，不存在這個問題。

---

## 2. `trap` — 系統訊號層級的 Event Listener

`trap` 是 shell 的 signal handler 註冊機制，概念上等同於 event listener：

```
trap   'handler'   SIGNAL
^^^^    ^^^^^^^^    ^^^^^^
註冊     callback    event name
```

### 常用 signal

| Signal | 觸發條件 | 典型用途 |
|--------|---------|---------|
| `EXIT` | 腳本結束（任何方式） | 清理臨時檔案 |
| `INT` | `Ctrl+C` | 中斷處理 |
| `TERM` | `kill` 指令 | 優雅關閉 |
| `ERR` | 上一行指令失敗（non-zero） | 錯誤處理 |

### 對應其他語言的概念

```javascript
// JavaScript
process.on('SIGINT', () => { cleanup(); });
window.addEventListener('beforeunload', () => { cleanup(); });
```

```bash
# Shell 等價
trap 'cleanup' INT
trap 'cleanup' EXIT
```

| 語言 | 對應概念 |
|------|---------|
| Shell | `trap '...' EXIT` |
| JavaScript | `process.on('exit', ...)` |
| Java / PHP | `try { ... } finally { cleanup }` |
| Go | `defer cleanup()` |
| Python | `with` context manager |

---

## 3. 為什麼需要 `trap`？

### 沒有 `trap`：臨時檔案可能殘留

```bash
tmp_file=$(mktemp /tmp/script.XXXXXX)

do_something
do_another_thing    # ← 如果這裡出錯 script 中斷
rm -f "$tmp_file"   # ← 永遠不會執行，臨時檔案殘留在 /tmp
```

### 有 `trap`：無論如何都會清理

```bash
tmp_file=$(mktemp /tmp/script.XXXXXX)
trap 'rm -f "${tmp_file}"' EXIT   # 註冊清理 callback

do_something
do_another_thing    # ← 就算這裡爆掉
                    #    EXIT trap 仍然會觸發 rm -f
```

不管是正常結束、`exit 1`、還是被 `Ctrl+C` 中斷，`EXIT` trap 都會執行。
