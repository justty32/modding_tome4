`Dialog:simplePopup(title, text)` 是引擎 Dialog 基礎類別提供的方法，用於顯示簡單的確認彈窗。它的實作是在 Dialog 內部再開啟一個子 Dialog，不需要額外實作。

但如果你的模組沒有繼承完整的 Dialog 類別（例如使用極簡 UI），可以自行實作：

```lua
-- 替代版本：直接用 game.log 輸出錯誤，不開彈窗
function _M:doLearn()
    -- ...（省略前半段，直接換掉 simplePopup）

    local can, why = actor:canLearnTalent(t)
    if not can then
        game.logPlayer(actor,
            "#RED#無法學習「%s」：%s", t.name, why or "未知原因")
        return
    end
    -- ...
end
```

---
