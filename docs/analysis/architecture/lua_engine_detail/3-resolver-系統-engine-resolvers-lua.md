Resolver 是一個「延遲計算」框架，讓實體定義可以包含亂數、條件邏輯，直到 resolve 時才實際執行。

### 3.1 Resolver 結構

```lua
resolvers.foo(...)    -- 回傳 {__resolver="foo", ...data...}
resolvers.calc.foo(t, e)  -- 實際計算，t=resolver table，e=entity
```

- `__resolve_instant = true`：在其他 resolver 之前優先執行。

### 3.2 內建 Resolvers

| Resolver | 說明 |
|----------|------|
| `resolvers.rngrange(x, y)` | 隨機整數 [x, y] |
| `resolvers.rngfloat(x, y)` | 隨機浮點數 |
| `resolvers.rngavg(x, y)` | 平均隨機（更集中於中間值） |
| `resolvers.dice(x, y)` | xdy 擲骰 |
| `resolvers.rngtable(t)` | 從 table 隨機取一個值 |
| `resolvers.mbonus(max, add)` | 依當前層數縮放的加成（越深越強） |
| `resolvers.talents(list)` | 學習技能列表 |
| `resolvers.rngtalent(list)` | 從列表隨機學一個技能 |
| `resolvers.rngtalentsets(list)` | 從集合隨機選一組技能 |
| `resolvers.tmasteries(list)` | 設定技能類型熟練度 |
| `resolvers.inventory(list)` | 生成物品放入揹包 |
| `resolvers.drops(list)` | 定義死亡掉落物 |
| `resolvers.equip(list)` | 生成物品並裝備 |
| `resolvers.racial()` | 種族特性 |
| `resolvers.sustains_at_birth()` | 出生時啟動持續技能 |

`resolvers.current_level` 是全局變數，生成前由 Zone 設定，讓 mbonus 等 resolver 感知當前深度。

---
