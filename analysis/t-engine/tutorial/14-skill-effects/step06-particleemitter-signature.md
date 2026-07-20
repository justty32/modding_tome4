```lua
game.level.map:particleEmitter(
    x,          -- 格座標 X（不是像素）
    y,          -- 格座標 Y
    radius,     -- 半徑（格數，用於 sradius 計算；0 = 單格）
    "def_name", -- 粒子定義檔名稱（不含 .lua，相對 data/gfx/particles/）
    {           -- args 表格：在粒子 Lua 中作為全域變數可用
        radius = radius,   -- → 粒子 Lua 中的 radius 變數
        tx = x,            -- → tx 變數
        ty = y,            -- → ty 變數
        color = {r=1,g=0,b=0},  -- 自訂（粒子 Lua 中自行讀取）
        -- 任何你想傳的額外參數都可以加在這裡
    }
)
```

> `args` 表格的內容在粒子 Lua 環境中作為**全域變數**存在。`bolt_fire.lua` 能讀到 `tx`、`ty` 是因為 `Particles:loaded()` 用 `setfenv` 把 `args` 表設為函式環境：
> ```lua
> setfenv(f, setmetatable(t, {__index=_G}))
> ```
> 所以 `args.tx` 在粒子 Lua 中直接寫成 `tx` 即可存取。

---
