# Shell 重導向 (Redirection) - 資料流控制

## 核心概念

**重導向 = 改變資料流向**

每個指令都有三條「水管」：

```
        ┌─────────────┐
輸入 →   │  指令/程式   │  → 輸出
        │             │  → 錯誤
        └─────────────┘
```

### 三種標準資料流

| 編號 | 名稱 | 英文 | 預設方向 |
|------|------|------|----------|
| 0 | 標準輸入 | stdin | 鍵盤 |
| 1 | 標準輸出 | stdout | 螢幕 |
| 2 | 標準錯誤 | stderr | 螢幕 |

## 重導向符號

### `>` 輸出導向（覆蓋）

```bash
# 資料流向: echo → file.txt
echo "hello" > file.txt
```

```
echo "hello" ───→ 螢幕 ✗
             └──→ file.txt ✓
```

### `>>` 輸出導向（附加）

```bash
echo "第一行" > log.txt
echo "第二行" >> log.txt   # 附加，不清空
echo "第三行" >> log.txt
```

```
> (覆蓋)  ═══╗
             ║ → [清空] → 寫入
             ╚═══════════════

>> (附加) ═══╗
             ║ → [保留] → 附加到末尾
             ╚═══════════════
```

### `<` 輸入導向

```bash
# 從檔案讀取而非鍵盤
read name < input.txt
```

### `2>` 錯誤導向

```bash
# 只導向錯誤訊息到檔案
ls 不存在的檔案 2> error.log
```

```
ls 指令
  ├─ stdout (1) → 螢幕（正常輸出）
  └─ stderr (2) → error.log（錯誤訊息）
```

### `2>&1` 合併輸出和錯誤

```bash
# stdout 和 stderr 都寫入同一個檔案
command > all.log 2>&1
```

```
command
  ├─ stdout (1) ─┐
  │              ├─→ all.log
  └─ stderr (2) ─┘
```

### `|` 管道（串接水管）

```bash
cat file.txt | grep "error" | wc -l
```

```
cat file.txt → grep "error" → wc -l → 螢幕
     │              │            │
   讀檔案         過濾內容      統計行數
```

## 實用範例

### 分別處理輸出和錯誤

```bash
# 1. 只儲存正確輸出
ls /tmp /不存在 > output.txt
# 螢幕還會顯示錯誤訊息

# 2. 只儲存錯誤訊息
ls /tmp /不存在 2> error.txt
# 螢幕還會顯示正確輸出

# 3. 分別儲存
ls /tmp /不存在 > output.txt 2> error.txt

# 4. 全部儲存在同一個檔案
ls /tmp /不存在 > all.txt 2>&1

# 5. 全部丟掉（靜音模式）
ls /tmp /不存在 > /dev/null 2>&1
```

### 常見組合

```bash
# 安靜執行（隱藏所有輸出）
command > /dev/null 2>&1

# 清理日誌並儲存
cat dirty.log | grep -v '^$' > clean.log

# 處理鏈：讀取 → 過濾 → 排序 → 去重 → 存檔
cat dirty.log | grep -v '^$' | sort | uniq > clean.log
```

### 附加 vs 覆蓋

```bash
# 覆蓋（每次都清空）
echo "新內容" > file.txt

# 附加（累積內容）
echo "第一行" >> log.txt
echo "第二行" >> log.txt
```

## 快速記憶

```bash
>    導向輸出到檔案（覆蓋）
>>   導向輸出到檔案（附加）
<    從檔案導入
2>   導向錯誤訊息
2>&1 錯誤合併到輸出
|    串接指令（前一個的輸出 → 下一個的輸入）
```

## 視覺化總結

```
資料流 = 水流

> file      水流向檔案（沖掉舊水）
>> file     水流向檔案（加入新水）
< file      水從檔案流入
2> file     錯誤水流向檔案
| command   水流向下一個水管
/dev/null   黑洞（水倒掉）
```

就像接水管一樣，你決定水（資料）要流去哪裡！💧
