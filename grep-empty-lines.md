# grep -v '^$' 如何過濾空行

## 逐步解析

### 1. `grep` 的 `-v` 參數

- `-v` = **invert match**（反向匹配）
- 正常的 `grep` 是「顯示符合條件的行」
- 加了 `-v` 變成「顯示**不符合**條件的行」

### 2. `^$` 正則表達式

這是一個**正則表達式 (regex)**，由兩個特殊符號組成：

| 符號 | 意義 | 說明 |
|------|------|------|
| `^` | 行首 (start of line) | 匹配一行的開始位置 |
| `$` | 行尾 (end of line) | 匹配一行的結束位置 |

當 `^` 和 `$` 連在一起：`^$`
- 意思是：**從行首直接到行尾，中間什麼都沒有**
- 也就是：**空行**

## 實際測試

```bash
# 建立測試檔案
echo -e "apple\n\nbanana\n\ncherry" > test.txt

# 查看內容
cat test.txt
# 輸出:
# apple
# (空行)
# banana
# (空行)
# cherry

# 只顯示空行
cat test.txt | grep '^$'
# 輸出: (兩個空行)

# 過濾掉空行（顯示非空行）
cat test.txt | grep -v '^$'
# 輸出:
# apple
# banana
# cherry
```

## 其他常見正則表達式範例

```bash
# 匹配以 "start" 開頭的行
grep '^start' file.txt

# 匹配以 ".sh" 結尾的行
grep '\.sh$' file.txt

# 匹配只有空白字元的行（空格或 tab）
grep '^[[:space:]]*$' file.txt

# 過濾掉只有空白的行
grep -v '^[[:space:]]*$' file.txt
```

## 總結

```bash
grep -v '^$'
│    │  └─ 匹配空行（行首直接接行尾）
│    └──── 反向匹配（排除匹配的行）
└───────── grep 指令
```

所以整體意思是：**排除空行，只顯示有內容的行**！

## 應用場景

```bash
# 原始範例：sed 產生的空行
ls examples/*.sh | sed 's/exam/\nexam/g' | grep -v '^$'

# 清理日誌檔案中的空行
cat app.log | grep -v '^$' > app-clean.log

# 統計非空行數量
cat file.txt | grep -v '^$' | wc -l
```
