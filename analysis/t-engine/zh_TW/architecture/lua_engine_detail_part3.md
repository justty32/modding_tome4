## 7. 傷害類型系統 (`engine/DamageType.lua`)

```lua
DamageType:newDamageType{
    name = "FIRE",
    type = "fire",
    text_color = "#r#",
    projector = function(src, x, y, type, dam)
        -- 對 (x,y) 的 ACTOR 造成 dam 點火焰傷害
        local target = game.level.map(x, y, Map.ACTOR)
        if target then target:takeHit(dam, src) end
    end,
}
-- 自動生成 DamageType.FIRE 常數
```

- 每種傷害類型都有獨立的 projector 函數，由 `ActorProject:project()` 呼叫。
- 模組可自由定義新傷害類型（毒、神聖、冥界、…）。

---

## 8. 目標系統 (`engine/Target.lua`)

```lua
-- 描述投射形狀
{type = "bolt", range = 10}              -- 直線單目標
{type = "beam", range = 10}              -- 直線貫穿
{type = "ball", range = 5, radius = 3}  -- 球形 AOE
{type = "cone", range = 8, cone_angle = 45}  -- 扇形
{type = "hit"}                           -- 直接命中
```

- `Target:getType(t)` 解析 type 描述，回傳包含 `block_path`、`block_radius` 等函數的完整 typ table。
- 目標系統也負責 UI 層的目標選擇顯示（紅色游標、射程顯示）。
- `self.target = {x, y, entity}` 追蹤當前目標，entity 為弱引用（目標死後自動清空）。
- FBO 渲染模式下可做半透明 overlay 效果。

---

## 9. 地圖生成系統 (`engine/generator/`)

### 9.1 Generator 基底

所有 generator 繼承 `engine.Generator`，實作 `:generate(lev, old_lev)` 方法。

```lua
-- Zone 定義中指定 generator
generator = {
    map = {class="engine.generator.map.Roomer", -- 地圖 generator
           floor = "FLOOR", wall = "WALL", ...},
    actor = {class="engine.generator.actor.Random",
             nb_npc = {10, 15}, ...},
    object = {class="engine.generator.object.Random",
              nb_object = {3, 5}, ...},
}
```

### 9.2 主要地圖生成器

**Rooms（`engine/generator/map/Rooms.lua`）**：
- 遞迴 BSP 切割（預設 10 次）產生房間。
- 每個最終房間記錄一個 spot，用於放置出口、NPC。
- 最簡單、效能最高的地牢生成器。

**RoomsLoader（`engine/generator/map/RoomsLoader.lua`）**：
- 從預定義的 room template 檔案（`.lua`）讀取房間形狀。
- 用 MST（最小生成樹）連接所有房間，確保連通性。
- 支援 special rooms（boss 房、寶庫等）。

**Cavern**：
- 隨機洞窟，使用細胞自動機（多次 smooth 迭代）。

**Maze**：
- 標準迷宮演算法（recursive backtracking）。

**Forest**：
- Perlin noise 決定樹木/草地分佈。

**Heightmap**：
- 高度圖轉換為地形（山脈、平原、水域）。

**WaveFunctionCollapse**：
- 呼叫 C++ WFC 核心（`src/wfc/`），從樣本圖案學習並生成一致的地圖。

**Static**：
- 從 `.lua` 腳本直接讀取手工設計的地圖（多用於 boss 房、城鎮）。

**GOL（Game of Life）**：
- 多代細胞自動機生成有機感的洞穴。

### 9.3 Tilemap 中間表示（`engine/tilemaps/`）

部分生成器先產生抽象 tilemap（字元代號），再映射到實際 Entity。`Tilemap.lua` 提供此轉換。

---

## 10. 存檔系統 (`engine/Savefile.lua` + `engine/SavefilePipe.lua`)

### 10.1 存檔格式

每次存檔 = 一個 **zip 檔案**，內含多個 Lua 序列化字串：

```
/save/<player_name>/
    save.lua          -- 頂層 game 物件入口
    <hash1>.lua       -- 某個子物件（Level、Actor、...）
    <hash2>.lua
    ...
```

每個物件序列化為：
```lua
setLoaded("hash1", {
    __CLASSNAME = "game.actor.Player",
    name = "Bob", level = 5,
    _actor_ref_ = loadObject("hash2"),  -- 跨物件引用
    ...
})
```

### 10.2 存檔流程

1. `game:save()` → `Savefile:init(name)` → 建立 zip。
2. `game:save(filter)` → `core.serial.new()` → 序列化根物件。
3. 遞迴遇到子物件 → `addToProcess(t)` → 排隊，後續序列化為獨立檔案。
4. 相同物件引用 → `loadObject(hash)` 取代（避免重複儲存）。
5. 完成後關閉 zip，可選 Steam Cloud 上傳。

### 10.3 讀檔流程

1. `Savefile:load()` → 解壓 zip 到 `/tmp/loadsave/`。
2. `class.load(str)` 反序列化字串，遇到 `loadObject` 就遞迴讀取子物件。
3. 設回 metatable（根據 `__CLASSNAME`）。
4. 延遲呼叫 `:loaded()`（確保相互引用都已建立後才初始化）。

### 10.4 SavefilePipe

後台存檔（background save）：
- 主執行緒繼續遊戲，存檔在 coroutine 中分批進行。
- 每次 yield 讓出控制權，避免卡頓。

### 10.5 MD5 完整性

- 部分類型的存檔啟用 MD5 校驗（`Savefile:setSaveMD5Type(type)`）。
- 讀取時若 MD5 不符記錄到 `bad_md5_loaded`，可用來偵測存檔修改。

---

## 11. UI 框架 (`engine/ui/`)

### 11.1 Base (`engine/ui/Base.lua`)

所有 UI 元件的基底，提供：
- **字型**：`font`（DroidSans 12pt）、`font_mono`（等寬）、`font_bold`。
- **UI 主題**：`ui = "dark"`（可換皮），透過 `loadUIDefinitions(file)` 載入主題設定（顏色、圖片路徑）。
- **材質快取**：`cache` / `tcache`，避免重複載入圖像。
- **音效**：`sounds.button` 等互動音效。

### 11.2 Dialog (`engine/ui/Dialog.lua`)

視窗基底，提供：
```lua
local d = Dialog.new("Title", width, height)
d:loadUI{
    {left=3, top=3, ui=Button.new{...}},
    {right=3, bottom=3, ui=List.new{...}},
}
d:setupUI(auto_w, auto_h)  -- 自動計算大小
game:registerDialog(d)
```

- **Layout**：`{left, right, top, bottom, vcenter, hcenter}` 錨點定位，支援相對座標。
- **Modal 堆疊**：`game.dialogs` 是個堆疊，頂部 dialog 接收輸入。
- **工廠方法**：`simplePopup`, `simpleWaiter`, `simpleWaiterTip` 等快速建立常用對話框。

### 11.3 主要 UI 元件

| 元件 | 特色 |
|------|------|
| `Button` | 點擊回調，可禁用 |
| `List` | 可選清單，支援鍵盤操作，高亮當前行 |
| `ListColumns` | 多欄清單，可調整欄寬 |
| `TreeList` | 可展開/收合的樹狀清單 |
| `Textzone` | 富文本顯示（支援顏色 tag），可滾動 |
| `TextzoneList` | 多段文字 + 條目選擇 |
| `Textbox` | 單行輸入框，支援 Unicode |
| `Numberbox` | 數字輸入框 |
| `Slider` / `NumberSlider` | 滑桿 |
| `Checkbox` | 勾選框 |
| `Dropdown` | 下拉選單 |
| `Tabs` | 標籤頁切換 |
| `ImageList` | 圖像格狀選擇（技能、物品圖示列表） |
| `EquipDoll` | 人形裝備圖（點擊對應部位） |
| `EntityDisplay` | 顯示實體的圖像與描述 |
| `Waitbar` / `Waiter` | 進度條（loading 等） |
| `WebView` | 嵌入網頁（CEF3/Awesomium） |
| `UIContainer` / `UIGroup` | 容器/群組佈局 |
| `SurfaceZone` | 自由繪製區域（GL surface） |

### 11.4 輸入整合

每個 Dialog 持有獨立的 `KeyBind` 和 `Mouse` 實例，`setCurrent()` 後接收事件。
