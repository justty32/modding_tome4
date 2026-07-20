### 初始化時機

`camp_state` 掛在 `game` 物件上，隨 `game:save()` 自動序列化。在 `newGame()` 時初始化，確保每個新存檔都有乾淨的起始狀態：

```lua
-- 已在步驟一的 Game.lua 中完整實作，這裡重申關鍵點：
game.camp_state = {
    buildings = {farm=false, chest=false, upgraded_fire=false},
    farms     = {},   -- 以 "x_y" 為 key 的農田狀態表
    workers   = {},   -- uid → 任務描述
}
```

### 存檔欄位宣告

```lua
-- mod/class/Game.lua → save()
function _M:save()
    return class.save(self, self:defaultSavedFields{
        camp_state = true,   -- ★ 必須宣告，否則存檔後據點進度消失
    }, true)
end
```

> **`farms` 使用 `"x_y"` 字串 key 的原因**：Lua table 的整數 key 與字串 key 行為略有不同，而座標組合 `x.."_"..y` 是安全的字串 key，不會因 Lua 的 hash table 特性造成序列化問題。也能輕鬆支援多格農田同時種植。

---
