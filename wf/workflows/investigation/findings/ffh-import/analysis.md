# Fall from Heaven import analysis

Done when: installer拆包完成、資源分類索引落檔、Civ4地圖資料格式與ToME4大地圖導入路線明確。

## 來源

- Installer: `/home/lorkhan/Downloads/FallfromHeaven2041n.exe`
- Manual PDF: `/home/lorkhan/Downloads/FallFromHeaven030_Manual_v010.pdf`
- Extra Word doc: `/home/lorkhan/Downloads/fall from heaven.doc`
- Wiki整理: `/home/lorkhan/repo/narratives/gameplots/results/Fall_from_Heaven/`
- 本次工作解包目錄: `/tmp/ffh2_unpack.ecgdxe/Fall from Heaven 2`

`FallfromHeaven2041n.exe` 是 NSIS installer，`7z` 可直接解包。解包結果：1955 files，約 715 MB。

## 已歸檔索引

- `resource-inventory.tsv`: 解包後每個檔案的分類、大小、路徑。
- `resource-summary.tsv`: 依分類與副檔名統計。
- `maps-scenarios.tsv`: 每張 Civ4 WBSave 劇本地圖的尺寸、地形、文明、城市、單位摘要。
- `wb-tokens.tsv`: 全部 WBSave 中出現的 Terrain/Feature/Bonus/Improvement/Unit/Civ token 統計。

## 資源分類

| 類別 | 數量 | 大小 | 說明 |
|---|---:|---:|---|
| `art_media` | 1629 | 425.16 MiB | `.dds/.nif/.kf/.kfm/.bik/.wav/.tga/.fpk` |
| `maps_scenarios` | 23 | 4.66 MiB | 22 張 WBSave + `PrivateMaps/Erebus.py` |
| `text_xml_python` | 137 | 27.56 MiB | Civ4 XML、Python、RTF、ini |
| `tools_binaries` | 3 | 8.37 MiB | DLL、xlsm、lnk |
| `other` | 161 | 215.98 MiB | 主要是 `.mp3`、字型與雜項 |

注意：`Assets/Pak0.FPK` 約 331 MiB，是 Civ4 packed art。`7z` 不能直接讀；需要 Civ4 FPK 專用 unpacker 或自寫 parser。未解開前，美術索引只能覆蓋 installer 內明檔，不能覆蓋 FPK 內藏資源。

## Civ4 地圖來源

有兩種地圖來源：

1. 靜態劇本地圖：`Assets/XML/Scenarios/*.CivBeyondSwordWBSave`
2. 程序大地圖生成器：`PrivateMaps/Erebus.py`

第一版 ToME import 應先吃靜態 WBSave，不先移植 `Erebus.py`。理由：WBSave 是完整 tile grid，能直接轉成 ToME `engine.generator.map.Static` 的 ASCII map；`Erebus.py` 依賴 Civ4 Python API (`CvPythonExtensions`) 與 Civ4 map generator callbacks，先移植會變成重寫生成器。

## 候選第一張 import 地圖

優先候選：

- `Assets/XML/Scenarios/The Black Tower.CivBeyondSwordWBSave`
  - 84x52，大圖。
  - Sheaim 4、Infernal 1，與 FFH 末日/地獄主題最接近。
  - 地形含 `BROKEN_LANDS`、`FIELDS_OF_PERDITION`，但仍有海岸、草地、平原，視覺層次比較完整。
- `Assets/XML/Scenarios/Lord of the Balors.CivBeyondSwordWBSave`
  - 84x52，大圖。
  - Infernal 7，地獄地形最多。
  - `BROKEN_LANDS` 2442 格，適合作為「地獄化大地圖」壓力測試。

我建議先做 `The Black Tower`，因為它比 `Lord of the Balors` 更像可遊玩大地圖，而不是單一地獄地形壓測。

## WBSave tile 結構

WBSave 先有 `BeginMap`：

- `grid width=<n>`
- `grid height=<n>`
- `num plots written=<n>`

之後每個 `BeginPlot` 代表一格：

- `x=<n>,y=<n>`
- `TerrainType=...`
- 可選 `FeatureType=...`
- 可選 `BonusType=...`
- 可選 `ImprovementType=...`
- 可選城市與單位 block

ToME 靜態 map 需要固定寬高與逐格 symbol。轉換時應以 `TerrainType` 做底層地形，再由 `FeatureType` / `ImprovementType` 提升為特殊地標或覆蓋 tile。

## 初始 token 對應

底層地形優先：

| Civ4 token | ToME base | import 意義 |
|---|---|---|
| `TERRAIN_OCEAN` | `WATER_BASE_DEEP` / `SEA_EYAL` 類 | 不可走深海 |
| `TERRAIN_COAST`, `TERRAIN_SHALLOWS` | `WATER_BASE` 或可走淺灘自訂格 | 海岸/淺水 |
| `TERRAIN_GRASS` | `PLAINS` 或 `CULTIVATION` | 一般可走地 |
| `TERRAIN_PLAINS` | `PLAINS` | 一般可走地 |
| `TERRAIN_DESERT` | `DESERT` | 沙漠 |
| `TERRAIN_TUNDRA`, `TERRAIN_SNOW` | `POLAR_CAP` / `COLD_FOREST` | 寒地 |
| `TERRAIN_MARSH` | `JUNGLE_PLAINS` 或自訂沼澤 | 沼地 |
| `TERRAIN_BROKEN_LANDS` | `CHARRED_SCAR` 或自訂地獄荒地 | 地獄/破碎地 |
| `TERRAIN_FIELDS_OF_PERDITION` | 自訂地獄田野 | 高優先地獄地 |
| `TERRAIN_BURNING_SANDS` | `DESERT` + 火焰 display 或自訂 | 燃燒沙地 |

Feature 覆蓋：

| Civ4 token | ToME base/display | import 意義 |
|---|---|---|
| `FEATURE_FOREST`, `FEATURE_FOREST_NEW`, `FEATURE_FOREST_ANCIENT` | `FOREST` / `OLD_FOREST` | 森林 |
| `FEATURE_JUNGLE` | `JUNGLE_FOREST` | 叢林 |
| `FEATURE_ICE`, `FEATURE_BLIZZARD` | `FROZEN_SEA` / `POLAR_CAP` | 冰 |
| `FEATURE_FLOOD_PLAINS`, `FEATURE_OASIS` | `OASIS` or special display | 綠洲/氾濫平原 |
| `FEATURE_FALLOUT`, `FEATURE_FLAMES`, `FEATURE_TORMENTED_SOULS` | 自訂地獄 display | 末日/地獄覆蓋 |
| `FEATURE_WALLS`, `FEATURE_DOOR_*` | 自訂牆/門 | 劇本室內地圖，不適合第一張大地圖 |

Improvement / Bonus 第一版不必全部轉成互動物。建議：

- 城市、起點、唯一 improvement 轉成 ToME `change_zone` 或地標。
- `IMPROVEMENT_TOWER`, `BARROW`, `DUNGEON`, `RUINS`, `GOBLIN_FORT` 轉為未進入的地牢入口。
- `BONUS_MANA*` 轉為法力節點地標。
- 一般糧食/礦產先轉成 minimap/display 標記，暫不提供經濟系統。

## ToME 導入路線

沿用 `self_mods/tome-runeisles` 的第二張 worldmap 模式：

1. 建 `self_mods/tome-fall-from-heaven/` addon。
2. 建 `data/zones/worldmap/zone.lua`，設定：
   - `wilderness = true`
   - `persistent = "zone"`
   - `generator.map.class = "engine.generator.map.Static"`
   - `map = "fall-from-heaven+worldmap"`
3. 由轉換腳本讀 WBSave，生成 `data/maps/worldmap.lua`。
4. 建 `data/zones/worldmap/grids.lua`，先 `load("/data/zones/wilderness/grids.lua")`，再定義 FFH 地形與地標。
5. 用一個入口 grid 追加到原版 Eyal wilderness，進入 `fall-from-heaven+worldmap`。
6. 因為這是第二張 wilderness 大地圖，必須照 `tome-runeisles` 保存/還原 `wild_x/wild_y`，否則兩張大地圖會共用座標而跳錯位置。

## 目前不做

- 不先做職業。
- 不先做技能樹。
- 不先移植 `Erebus.py` 程序地圖生成器。
- 不先解 `Pak0.FPK` 內藏美術，除非下一步需要原始 tile art。
- 不把 715MB 解包內容放進 repo。

## 2026-08-08 實作結果

已建立 `self_mods/tome-fall-from-heaven/` 第一版，並在大地圖之下加上中層 zone 原型：

- addon 名稱：`Fall from Heaven: The Black Tower`
- short_name：`fall-from-heaven`
- 來源地圖：`The Black Tower.CivBeyondSwordWBSave`
- 生成地圖：`data/maps/worldmap.lua`
- zone：`fall-from-heaven+worldmap`
- 尺寸：84x52
- 入口：Eyal 大地圖 Derth 西側附近 `(22,17)`，目的地落點 `(44,23)`
- 場景資料表：`data/ffh/black-tower-sites.lua`
  - Civ4 原始 `civ_x/civ_y` 與 ToME map `map_x/map_y` 都保留。
  - 已抽出 9 座城市、1 個 Lanun 登陸營地、主要 faction/leader token。
- 中層 zone：
  - `fall-from-heaven+city`：所有 `C` 城市格先連到同一個可進可退的城市原型。
  - `fall-from-heaven+landing-camp`：`S` 起始格連到 Lanun 登陸營地原型。
  - 城市與營地目前是通用靜態場景，尚未把每座城市各自的 NPC、商店、劇情差異放進去。
- 大地圖 AI 原型：
  - `data/ffh/world-ai.lua`：穩定 facade，維持 hooks/probes 既有 API。
  - `data/ffh/world-state.lua`：可序列化的 world state，含城市、勢力、部隊、世界回合 log。
  - `data/ffh/world-rules.lua`：production、warband 生產、移動、攻城/capture 規則。
  - `data/ffh/world-report.lua`：probe/report 字串輸出。
  - `data/ffh/worldmap-projection.lua`：把 `game.ffh_ai.units` 投影到 FFH worldmap terrain，
    保留底層地形與入口，同時疊加 unit sprite marker 與可碰撞的 `WorldNPC` actor。
  - `data/ffh/worldmap-actors.lua`：world unit actor 建立、加入/移除 map、遭遇切入 skirmish。
  - `superload/mod/class/Player.lua`：玩家 `actBase` 後呼叫 `game.ffh_ai` 的 `maybeTick()`。
    若目前在 `fall-from-heaven+worldmap`，AI tick 後會重投影 unit marker。
    同檔也包裝 `onWorldEncounter()`，在進入 FFH 遭遇前保存 world unit id/kind/owner/sprite。
  - 規則薄片：每 1000 個 ToME game turn 跑 1 個 FFH 世界回合；城市累積 production，
    到 2 生一支 warband；warband 朝最近敵城每回合走一步，抵達時記錄 attack/capture。
  - 戰術遭遇原型：
    - `fall-from-heaven+skirmish`：從 FFH world unit encounter 進入的底層戰場。
    - `data/maps/sites/skirmish.lua`：34x22 靜態戰場，含返回 worldmap 的 `<`。
    - `data/zones/skirmish/npcs.lua`：暫有 FFH warband raider / archer，使用 NIF texture proxy sprite。
    - `data/ffh/skirmish.lua`：把 world encounter context 掛到 skirmish level，標記敵人所屬
      world unit；`player_won` 時會把對應 unit 從 `game.ffh_ai.units` 移除並寫入 AI log。
      `player_retreat` 則保留 world unit，只記錄 retreat log。
  - 工具 probe：`tools/playtest.sh probe ffh_ai`、`tools/playtest.sh probe ffh_ai_step <N>`、
    `tools/playtest.sh probe ffh_ai_map`、`tools/playtest.sh probe ffh_skirmish`、
    `tools/playtest.sh probe ffh_skirmish_resolve`、`tools/playtest.sh probe ffh_skirmish_retreat`。
- 美術資源第一批：
  - `tools/import-ffh-assets.sh`：從 FFH 解包目錄把明檔 DDS 轉成 ToME 可用 PNG。
  - `data/gfx/ffh/icons/units/*.png`：已匯入 8 個 FFH unit button（Archer、Beast of Agares、
    Son of the Inferno、Wrath 等）。
  - `data/gfx/ffh/icons/proxy/*.png`：城市、營地、warband 等暫用 proxy 圖。
  - `data/gfx/ffh/sprites/nif-proxy/*.png`：8 個由 NIF 周邊 texture 自動裁切的臨時 sprite
    proxy（Abaddon、Beast of Agares、Son of the Inferno、Scorpion、Archer、Mage/Spy、
    Vampire Lord、Chariot）。
  - `data/ffh/assets.lua`：addon 內部圖像 catalog。
  - `data/ffh/unit-art.lua`：AI unit kind -> sprite path 的對應表。
  - `ffh-imported-art-sheet.png`：第一批匯入 icon + texture proxy contact sheet。
  - `nif-sprite-manifest.tsv`：68 個 `.nif` 模型清單，含附近 texture；目前 8 個標記為
    `texture_proxy_generated`，60 個仍是 `needs_nif_renderer`。
  - 目前本機有 ImageMagick/Pillow，可轉 DDS/TGA；沒有 Blender/NIF renderer，所以 3D 模型
    尚未真正渲成 2D sprite。texture proxy 是中繼品質，不等於模型截圖；下一步需補
    Blender + NIF plugin、NifSkope 批次截圖，或其他 Civ4 NIF renderer。

驗證摘要：

- `tools/lint.sh tome-fall-from-heaven`：通過，40 個 Lua 檔語法通過。
- 靜態 map 尺寸檢查：`worldmap.lua` = 84x52，`sites/city.lua` = 34x20，
  `sites/landing-camp.lua` = 34x20。
- `tools/verify.sh tome-fall-from-heaven`：通過，27 項 `[FALL-FROM-HEAVEN] selfcheck` 全 OK。
- 無頭 playtest Lua 直接呼叫 `Zone:newLevel()`：Static generator 讀取
  `/data-fall-from-heaven/maps/worldmap.lua`，probe 回報 `map=84x52`。
- 無頭 playtest Lua 直接生成 `fall-from-heaven+city`：`map=34x20`，回程點為
  `leave the city`。
- 無頭 playtest Lua 直接生成 `fall-from-heaven+landing-camp`：`map=34x20`，
  `up=8,3`，回程點為 `leave the landing camp`。
- 無頭 playtest probe：
  - `tools/playtest.sh probe ffh_ai`：`civ_turn=0 units=1 cities=9`。
  - `tools/playtest.sh probe ffh_ai_step 2`：`civ_turn=2 units=10 cities=9`，
    log 顯示多支 warband 朝 Grottiburg / Tongurstad / Galveholm 等敵城移動。
  - `tools/playtest.sh probe ffh_ai` 也會回報 sample unit sprite，例如
    `sample=u1@77,14:ffh/sprites/nif-proxy/chariot.png`。
  - `tools/playtest.sh probe ffh_ai_map`：`placed=1 counted=1 marker=true
    sprite=ffh/sprites/nif-proxy/chariot.png`。2026-08-08 後已升級為 actor probe：
    `placed=1 counted=1 actors=1 actor=true actor_sprite=ffh/sprites/nif-proxy/chariot.png`。
  - `tools/playtest.sh probe ffh_skirmish`：`actors=4 up=3,10`，樣本含
    `FFH_SKIRMISH_RAIDER@15,5:ffh/sprites/nif-proxy/chariot.png` 與
    `FFH_SKIRMISH_ARCHER@29,6:ffh/sprites/nif-proxy/archer.png`。
    2026-08-08 後已帶入 world unit context：`unit=u1 resolved=false`，四個敵人都標記 `:u1`。
  - `tools/playtest.sh probe ffh_skirmish_resolve`：`before=1 after=0 unit=u1 result=player_won removed=true`；
    隨後 `probe ffh_ai` 回報 `units=0 sample=none last=... T000 skirmish removes u1 at 77,14`。
  - `tools/playtest.sh probe ffh_skirmish_retreat`：`before=1 after=1 unit=u1 result=player_retreat removed=false`；
    隨後 `probe ffh_ai` 回報 `units=1` 並追加 `T000 skirmish retreat from u1 at 77,14`。
  - `probe ffh_ai_step 1` 後再次投影，marker 可從 `77,14` 移到 `76,14`。
- `tools/deploy.sh tome-fall-from-heaven`：已部署到真 home。
- `tools/build.sh tome-fall-from-heaven`：產出 `self_mods/build/tome-fall-from-heaven.teaa`。

踩坑：

- `Zone:getLevel()` 在遊戲中臨時 probe 會牽動目前 level 的離開/存檔流程；要單純驗證生成器，
  用 `Zone:newLevel(level_data, 1, nil, game)` 比較乾淨。
- 手動 probe `engine.Zone` 時，要先 `Zone:setup{... grid_class="mod.class.Grid" ...}`；
  正常遊戲流程會做這件事，但 console 直接 new zone 不一定有 class 欄位。
- Static map 的起點在生成結果中是 `level.default_up`，不是 `level.startx/starty`
  （見 `engine/generator/map/Static.lua:758` 與 `engine/Zone.lua:1100` 附近）。
- ToME 的第二張 wilderness 大地圖必須保存/還原 `wild_x/wild_y`，否則會和 Eyal 共用座標。
  本版照 `tome-runeisles` 模式在入口與回程格中保存 `who.ffh_wild_pos`。
