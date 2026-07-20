即使已有 HUD 按鈕，加入鍵盤快捷鍵讓操作更方便：

### 修改 `mod/class/Game.lua → setupCommands()`

```lua
-- mod/class/Game.lua

function _M:setupCommands()
    -- 原有指令...

    self.key:addBinds{
        -- ★ 新增：開啟技能學習界面（預設綁定 K 鍵，可在設定中更改）
        SHOW_SKILL_TREE = function()
            game:registerDialog(
                require("mod.dialogs.SkillLearnDialog").new(self.player)
            )
        end,

        -- 保留舊版 UseTalents（預設 T 鍵）
        USE_TALENTS = function()
            game:registerDialog(
                require("engine.dialogs.UseTalents").new(self.player)
            )
        end,
    }
end
```

### 在 `data/keybinds/` 中宣告新鍵位

```lua
-- mod/data/keybinds/interface.lua（或建立新檔）
-- 讓玩家可以在設定界面中重新綁定此鍵

defineKeyBind{
    default = {{key="_k"}},   -- 預設 K 鍵
    id      = "SHOW_SKILL_TREE",
    name    = "開啟技能學習界面",
    type    = "interface",
}
```

---
