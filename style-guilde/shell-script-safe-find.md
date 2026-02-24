# Shell Script — 安全迭代 find 結果

本文件深入解釋 `shell-script.md` 中安全迭代 pattern 的每個細節。

## 完整 Pattern

```bash
while IFS= read -r -d '' file; do
  process_file "${file}"
done < <(find "${dir}" -type f -print0)
```

---

## 1. `find` 指令基礎

`find` 遞迴搜尋目錄中符合條件的檔案。

```bash
find "${backup_dir}" -type f -name "*.tar.gz" -mtime +7 -delete
#     ^^^^^^^^^^^^^^  ^^^^^^  ^^^^^^^^^^^^^^^  ^^^^^^^^  ^^^^^^^
#     搜尋的目錄       只找檔案  檔名符合 pattern  超過 7 天  找到就刪除
```

常用參數：

| 參數 | 用途 |
|------|------|
| `-type f` | 只找檔案（`d` 是目錄） |
| `-name "*.log"` | 依檔名 glob pattern 篩選 |
| `-mtime +7` | 修改時間超過 7 天 |
| `-delete` | 找到後直接刪除 |
| `-print0` | 輸出時用 `\0`（null 字元）分隔，而非換行 |

---

## 2. `< <(...)` 不是 `<<`

`< <(...)` 容易跟 Here Document (`<<`) 搞混，但它們完全不同。
關鍵在於**中間有空格**，要拆成兩部分理解：

```
<   <(...)
^   ^^^^^^
|   Process Substitution
|
Input Redirection
```

### `<(...)` — Process Substitution

把指令的輸出**偽裝成一個臨時檔案**：

```bash
echo <(find . -type f)
# 印出類似: /dev/fd/63  ← 臨時的 file descriptor 路徑
```

### `<` — Input Redirection

把一個**檔案**的內容導入 stdin：

```bash
while read line; do
  echo "$line"
done < myfile.txt
```

### 組合起來

概念上等同於：

```bash
find "${dir}" -type f -print0 > /tmp/result.txt
while IFS= read -r -d '' file; do
  process_file "${file}"
done < /tmp/result.txt
```

但不需要真的建立中間檔案。

### 為什麼不用 pipe `|`？

```bash
# pipe 會開 subshell，while 裡修改的變數外面看不到
find ... | while read file; do
  count=$((count + 1))
done
echo "$count"  # 永遠是 0
```

`< <(...)` 讓 `while` 在**當前 shell** 執行，變數修改會保留。

---

## 3. `IFS= read -r -d '' file` 斷句

不是 `(IFS= (read -r -d '')) (file)`，正確斷句：

```
IFS=    read   -r   -d ''   file
^^^^^   ^^^^   ^^   ^^^^^   ^^^^
臨時      指令   旗標   旗標    參數
環境變數                       （變數名）
```

### `VAR=value command` 語法

Bash 中，指令前放 `VAR=value` 代表「**只在這個指令執行期間**暫時設定環境變數」：

```bash
PORT=3000 node server.js   # 只有這次 node 執行時 PORT=3000
LANG=C grep "pattern" file # 只有這次 grep 執行時 LANG=C
IFS= read -r -d '' file    # 只有這次 read 執行時 IFS 為空字串
```

`IFS=` 不是接收 `read` 的結果，方向是反過來的——它是 `read` 的**運行環境設定**。

### `read` 指令的參數

| 部分 | 用途 |
|------|------|
| `-r` | 不解釋反斜線（`\`），原樣讀取 |
| `-d ''` | 用 `\0` (null) 作為行分隔符（見下節） |
| `file` | 讀取的結果存進 `$file` 這個變數 |

---

## 4. `-d ''` 為什麼是 null 字元？

空字串 `''` 直覺上是「什麼都沒有」，但 `-d` 取的是「第一個字元」。
這涉及 C 語言字串的底層實作：

```
C 字串結尾一定有 \0 (null terminator)

"hello" → ['h', 'e', 'l', 'l', 'o', '\0']
""      → ['\0']
```

`read -d` 取空字串的「第一個字元」，拿到的就是 `\0`。
這不是語義設計，而是 **C 語言實作的副作用**。

驗證：

```bash
printf 'aaa\0bbb\0ccc\0' | while IFS= read -r -d '' item; do
  echo "got: $item"
done
# got: aaa
# got: bbb
# got: ccc
```

---

## 5. `IFS=` 和 `-d ''` 看似重工，實則不同

兩者作用在 `read` 的**不同階段**：

### `-d ''`：決定「讀到哪裡停」

`read` 預設讀到 `\n` 停。`-d ''` 改成讀到 `\0` 才停。

```
輸入流: my file.txt\0another.txt\0
                    ^
                    -d '' 在這裡切斷，一次讀到 "my file.txt"
```

### `IFS=`：決定「讀進來後要不要 trim」

`read` 拿到資料後，還會用 IFS 做頭尾空白的 trim：

```bash
# 假設輸入是 "  hello  "
IFS=' ' read -r -d '' var   # var = "hello"      ← 被 trim
IFS=    read -r -d '' var   # var = "  hello  "   ← 完整保留
```

### 完整流程

```
find 輸出: "  my file.txt\0another.txt\0"

Step 1 (-d ''):  讀到 \0 停 → 拿到 "  my file.txt"
Step 2 (IFS):    要不要 trim？
  IFS=' '  →  "my file.txt"    ← 前面空白不見了
  IFS=     →  "  my file.txt"  ← 完整保留
```

**缺一不可**：
- 少了 `-d ''`：檔名含換行會被切斷
- 少了 `IFS=`：檔名頭尾含空白會被吃掉

---

## 對照：不安全的寫法

```bash
# ❌ for + $() — 檔名含空格會被切割成多個迭代
for f in $(find "${dir}" -type f); do
  process_file "$f"
done
```

`"my file.txt"` 會被拆成 `"my"` 和 `"file.txt"` 兩次迭代。
