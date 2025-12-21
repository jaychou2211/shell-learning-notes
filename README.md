# Shell Scripting 學習筆記

Shell/Bash 學習筆記：涵蓋基礎語法、進階技巧，以及函數式程式設計視角的比較分析。

## 學習資源分類

### 基礎核心 (Core Fundamentals)

- **[shell-scripting-guide.md](shell-scripting-guide.md)**
  完整的 Shell 基礎指南，涵蓋變數、條件、迴圈、函數等所有核心概念

- **[shell-redirection.md](shell-redirection.md)**
  資料流重導向機制：理解 `>`, `>>`, `<`, `|`, `2>` 等符號如何控制資料流向

### 進階語法 (Advanced Syntax)

- **[bash-case-pattern-matching.md](bash-case-pattern-matching.md)**
  Case 語句的 glob pattern matching 本質，與 Haskell/Rust pattern matching 的異同

- **[bash-command-grouping.md](bash-command-grouping.md)**
  命令分組 `{}` vs `()`：當前 shell 和子 shell 的關鍵差異與應用場景

- **[bash-function-returns.md](bash-function-returns.md)**
  函數返回值的雙重策略：`echo` 返回數據 vs `return` 返回狀態碼

- **[shell-io-redirection.md](shell-io-redirection.md)**
  深入理解 `2>&1` 的執行順序、檔案描述符重導向原理

### 實用工具 (Practical Tools)

- **[grep-empty-lines.md](grep-empty-lines.md)**
  使用 `grep -v '^$'` 過濾空行，正則表達式 `^` 和 `$` 的實戰應用

### 跨領域思考 (Cross-Domain Perspectives)

- **[either-monad-vs-shell.md](either-monad-vs-shell.md)**
  Shell 雙通道資料流與 Either Monad 的相似性：函數式程式設計視角的比較

---

## 範例腳本

```
examples/
├── 01-hello-world.sh       # 基礎語法
├── 02-variables.sh         # 變數操作
├── 03-user-input.sh        # 輸入處理
├── 04-conditionals.sh      # 條件判斷
├── 05-case-statement.sh    # Case 語句
├── 06-for-loop.sh          # For 迴圈
├── 07-while-loop.sh        # While 迴圈
├── 08-functions.sh         # 函數定義
├── 09-file-operations.sh   # 檔案操作
├── 10-log-analyzer.sh      # 日誌分析
├── 11-backup.sh            # 自動備份
└── 12-network-monitor.sh   # 網路監控
```
