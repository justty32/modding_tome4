| 機制 | 適用情境 | 風險 |
|------|----------|------|
| `hooks` | 注入生命週期、載入新定義 | 低；多個 Addon 共存沒問題 |
| `superload` | 修改現有方法行為 | 中；需正確呼叫 loadPrevious 維持鏈 |
| `overload` | 添加全新類別/替換資源 | 高；兩個 Addon 覆蓋同一檔案會衝突 |

**最佳實踐**：
1. 盡量用 `hooks/ToME:load` 載入定義，避免 superload
2. 必須修改現有方法時才用 superload，且一定要呼叫原始方法
3. 新增的類別放在 `overload/` 用獨特的路徑（如 `mod/class/MyAddonClass.lua`）
4. 資料檔案放在 `data/`，透過 `/data-<short_name>/` 路徑存取

---

**下一步**：→ [教學 07：為 ToME 新增職業與技能樹（進階）](./07-class-and-talents.md)
