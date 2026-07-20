| 現象 | 原因 | 解法 |
|------|------|------|
| 裝備在角色身上不顯示 | 對應種族資料夾缺少 PNG | 為每個 `moddable_tile` 種族都新增相同命名的 PNG |
| 角色完全不顯示 | 缺少 `base_shadow_01.png` 或 `base_01.png` | 確認最小必要圖層都存在 |
| 武器方向顛倒 | `%s` 格式化寫錯 | 主手用 `right`，副手用 `left` |
| 護甲只顯示上半身 | 缺少 `moddable_tile2` | 身體護甲需設定 `moddable_tile2` 或提供 `lower_body_01.png` 預設圖 |
| 獨特武器不顯示 | `special/` 路徑不存在 | 檢查 `fs.exists("/data/gfx/shockbolt/player/human_female/special/right_XXXX.png")` |

---
