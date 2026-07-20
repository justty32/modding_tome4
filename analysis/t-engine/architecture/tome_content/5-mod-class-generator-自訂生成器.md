ToME 在引擎標準生成器之上，實作了許多特化生成器。

### 5.1 Actor 生成器 (generator/actor/)

| 檔案 | 大小 | 說明 |
|------|------|------|
| `Arena.lua` | 25KB | 競技場 NPC 生成（波次系統）|
| `Random.lua` | 2.6KB | 隨機 Actor 覆蓋（ToME 特定規則）|
| `OnSpots.lua` | 2.6KB | 在指定位置生成 NPC |
| `RandomStairGuard.lua` | 1.9KB | 在樓梯旁生成守衛 |
| `CharredScar.lua` | 1.8KB | 焦土峽谷特有 NPC |
| `Sandworm.lua` | 2KB | 沙蟲遭遇生成 |
| `ValleyMoon.lua` | 3.5KB | 月之谷遭遇 |
| `HighPeakFinal.lua` | 1.9KB | High Peak 最終 Boss 生成 |

**Arena.lua — 波次系統核心**：
- 按波次（Wave）定義不同難度的 NPC 組合
- 支援隨機選擇池（weighted random）
- 每波清除後自動生成下一波
- 記錄最高波次到排行榜

### 5.2 Map 生成器 (generator/map/)

| 檔案 | 大小 | 說明 |
|------|------|------|
| `StaticPredrawn.lua` | 25KB | 預繪製地圖載入器（最大）|
| `VaultLevel.lua` | 5KB | 寶庫關卡生成 |
| `GenericTunnel.lua` | 2.4KB | 通用隧道生成 |
| `SlimeTunnels.lua` | 2.6KB | 黏液隧道（視覺特化）|
| `CharredScar.lua` | 2KB | 焦土峽谷地圖 |
| `Caldera.lua` | 3.7KB | 火山口地圖生成 |

**StaticPredrawn.lua — 預繪製地圖系統**：

```lua
-- zone 定義中使用
generator = {
    map = {
        class = "mod.class.generator.map.StaticPredrawn",
        -- 指定多個替代佈局（隨機選一）
        maps = {
            "city/last-hope-1",
            "city/last-hope-2",
        },
    },
}
```

功能：
- 載入 `.lua` 靜態地圖文件（字元碼 → 實體）
- 支援 `subgen` 子生成器（在靜態地圖特定位置嵌入程序生成內容）
- 解析地圖標記（`@` = 玩家起始、`<` = 向上樓梯等）
- 支援多地圖替代版本（replayability）

---
