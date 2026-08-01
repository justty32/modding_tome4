# 自訂 UI 面板（Dialog）

> 目標版本 **ToME 1.7.6**。附行號複驗過。路徑代號見 [README.md](README.md)。
> 實作範例：`mods/tome-runewright/overload/mod/dialogs/RunewrightRuneBoard.lua`（符文盤）。

## 1. ⚠️ 自訂 dialog 必須放在 `overload/`，不能放 `data/`

`require("mod.dialogs.X")` 走 Lua 的 package path，對應 VFS 的 `/mod/…`。
addon 的 `data/` 掛在私有的 `/data-<short>/`（`E/Module.lua:498-503`），**require 永遠找不到**。
只有 `overload/` 會被掛到 VFS 根目錄（`E/Module.lua:519-524`）。

```
overload/mod/dialogs/MyPanel.lua   →  require("mod.dialogs.MyPanel")
```

這裡是**新增**一個原版沒有的檔案，不是覆寫，所以沒有 overload 常見的「兩個 addon 互相靜默吃掉」問題
（那個問題只在兩個 addon 覆寫**同一個既有路徑**時發生）。取一個夠獨特的檔名就好。

第三方前例：`zomnibus`、`possessors`、`items-vault` 的自訂 dialog 全部放 `overload/mod/dialogs/`；
`superload/mod/dialogs/` 則是拿來**覆寫**原版既有 dialog 的（`no-talent-caps`、`ignore_rc_locks`）。

別忘了 `init.lua` 要加 `overload = true`，否則目錄不會被掛載（`tools/lua/check_init.lua` 會擋）。

## 2. 最小面板骨架

抄 `M/mod/dialogs/ShowIngredients.lua`（77 行，最乾淨的「左列表＋豎線＋右詳情」）。

```lua
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    Dialog.init(self, "標題", math.floor(game.w * 0.8), math.floor(game.h * 0.8))
    -- 排版一律用 self.iw / self.ih（內容區），不是 self.w / self.h（含外框）
    local vsep = Separator.new{ dir = "horizontal", size = self.ih - 10 }  -- 注意：畫出來是「豎線」
    self.c_desc = TextzoneList.new{ width = math.floor(self.iw/2 - 10), height = self.ih, scrollbar = true }
    self.c_list = ListColumns.new{
        width = math.floor(self.iw/2 - vsep.w/2), height = self.ih, scrollbar = true,
        columns = { {name="欄名", width=50, display_prop="欄位名"} },
        list = self.list,
        fct = function(item) end,                       -- Enter / 雙擊
        select = function(item, sel) self:select(item) end,  -- 移動選取列
    }
    self:loadUI{
        { left = 0, top = 0, ui = self.c_list },
        { right = 0, top = 0, ui = self.c_desc },
        { hcenter = 0, top = 5, ui = vsep },
    }
    self:setFocus(self.c_list)
    self:setupUI()
    self:select(self.list[1])   -- 手動觸發一次，否則右邊是空的
    self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end }
end
```

幾個容易錯的點：

- **`top = self.c_status`（傳 widget 而不是數字）** 會自動排到那個 widget 底下（`E/ui/Dialog.lua:571-574`）。
- `setupUI()` 之後 widget 的 `.h` 才可靠。要拿高度來算別人的高度，先建好再讀。
- **一定要 `EXIT` 綁 `unregisterDialog`**。沒綁的話面板關不掉，還會吃光鍵盤事件。
- `game:unregisterDialog(d)`（`E/Game.lua:470-483`）會呼叫 `d:cleanup()` 與 `d:unload()`。

`TextzoneList` 比 `Textzone` 適合右側詳情：`switchItem(key, text)` 會把排版結果快取起來，
切換選取列時不用重排（`E/ui/TextzoneList.lua:140`）。

## 3. 文字顏色

`#GOLD#…#LAST#` 由 `string.toTString` 解析（`E/utils.lua:1628-1652`），色名必須在 `E/colors.lua` 註冊過。
複驗過可用的：`WHITE` `GREY` `GOLD` `LIGHT_GREEN` `LIGHT_RED` `LIGHT_BLUE` `AQUAMARINE` `ANTIQUE_WHITE`。
`#LAST#` 回到上一個顏色。換行用 `\n`。

`●` `○` 這類符號在遊戲字型（WenQuanYi Micro Hei）**渲染正常**，實測過。
但古弗薩克文字符（ᚠᚦᚲ）是豆腐方塊——見 [visuals-and-sounds.md](visuals-and-sounds.md)。

## 4. 三個開啟面板的入口

| 入口 | 怎麼做 | 代價 |
|---|---|---|
| **天賦**（推薦） | `mode="activated"` + `no_energy=true` + `action` 裡 `game:registerDialog(...)` | 玩家最容易找到。原版前例：`M/data/talents/cursed/cursed-aura.lua:255-258` |
| **遊戲目錄** | `Game:alterGameMenu` hook（`M/mod/class/Game.lua:2459`） | 最輕量、零覆寫。但玩家要按 Escape 才看得到 |
| **鍵位** | `KeyBind:defineAction{...}`（**不需要** overload 檔案，它只註冊 metadata）+ `game.key:addBinds{}` | 玩家要自己去綁 |

`Game:alterGameMenu` 的 hook data 是 `{menu=l, unregister=fn}`。`unregister` 是引擎現場建的閉包，
因為 hook 觸發時 GameMenu 物件還沒建立，addon 拿不到它——**先呼叫 `data.unregister()` 關掉選單，
再開自己的 dialog**：

```lua
class:bindHook("Game:alterGameMenu", function(self, data)
    if not <該顯示的條件> then return end
    table.insert(data.menu, 1, { "面板名", function()
        data.unregister()
        game:registerDialog(require("mod.dialogs.MyPanel").new(game.player))
    end })
end)
```
第三方前例：`zomnibus/hooks/hooks-savefile-note.lua:86-101`、`select-your-escorts/hooks/load.lua:65-104`。

**CharacterSheet 加不了分頁**：`M/mod/dialogs/CharacterSheet.lua` 沒有 tab 系統，
只有兩個「插幾行字」的 hook（`:998`、`:1132`）。要分頁就得 superload 整個檔。

## 5. 測 UI 的三個坑（實測）

1. **面板會吃掉 `ctrl+L`。** 它拿到鍵盤焦點後只處理自己綁的鍵，Lua console 開不起來。
   要用 console 就先 Escape 關掉面板。（`playtest.sh lua` 的 sentinel 會正確報「拿不到焦點」。）
2. **`playtest.sh lua` 結尾會按 Escape 關 console——那會把你剛開的面板一起關掉。**
   要看面板，改成用 console 把它綁到快捷鍵再按下去：
   ```bash
   tools/playtest.sh lua 'game.player.hotkey[1] = {"talent", game.player.T_MY_PANEL}'
   tools/playtest.sh do panel key 1 wait 3
   ```
3. **`--size 1280x800` 下 Xvfb 沒有視窗管理員，SDL 以「有邊框」模式建視窗，整個遊戲畫面會被平移約 200px**，
   看起來像對話框沒置中／右邊被切掉。那是測試環境的假象，不是版面 bug。
   要確認就印 `d.display_x` / `d.w` / `game.w` 出來對——別用肉眼判座標。
   用預設的 1024x768 比較不會誤導。

## 6. 面板不要自己算業務邏輯

符文盤把所有共鳴判定都丟回 `data/lib/resonance.lua` 的純函數（`evaluate` / `diff` / `withReplacement`）。
面板只負責問問題與畫答案。否則「面板顯示的」與「實際生效的」會慢慢分岔，而且那種 bug 極難發現。

這也是那個 lib 當初被硬性要求寫成純函數（不准碰 actor）的原因——
它要能對「假如玩家把槽 2 換成這顆符文」這種**假想狀態**求值。
