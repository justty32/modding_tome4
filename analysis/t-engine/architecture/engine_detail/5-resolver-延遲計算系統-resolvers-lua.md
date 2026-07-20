Resolver 是「延遲計算」框架，讓實體定義包含亂數/條件邏輯，直到 `resolve()` 時才執行。

**結構**：`resolvers.foo(...)` 建立 `{__resolver="foo", ...data}`；`resolvers.calc.foo(t, e)` 執行計算。

| Resolver | 說明 |
|----------|------|
| `rngrange(x, y)` | 隨機整數 [x, y]（`__resolve_instant`）|
| `rngfloat(x, y)` | 隨機浮點數 |
| `rngavg(x, y)` | 平均隨機（集中於中間值）|
| `dice(x, y)` | xdy 擲骰 |
| `rngtable(t)` | 從 table 隨機取一值 |
| `rngcolor(t)` | 隨機顏色並設 color_r/g/b |
| `mbonus(max, add)` | 依當前層數縮放的加成 |
| `talents(list)` | 學習技能列表 |
| `rngtalent(list)` | 從列表隨機學一個技能 |
| `rngtalentsets(list)` | 從集合隨機選一組技能 |
| `tmasteries(list)` | 設定技能類型熟練度 |
| `levelup(base, every, inc, max)` | 升級屬性進程設定 |
| `generic(fct)` | 自訂函數 resolver |

- `__resolve_instant`：在其他 resolver 之前優先執行（適合即時亂數）
- `__resolve_last`：在其他 resolver 之後執行
- `resolvers.current_level`：全域變數，Zone 生成前設定，讓 `mbonus` 感知當前深度

---
