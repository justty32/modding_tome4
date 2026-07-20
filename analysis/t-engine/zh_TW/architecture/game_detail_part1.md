# T-Engine 4 — game/ 目錄原始碼詳細分析

> 本文件涵蓋 `game/` 目錄下所有子系統，包含引擎啟動、模組（boot/example/ToME）、Addon 與第三方函式庫。

---

## 目錄

1. [game/loader/ — 引擎啟動器](#1-gameloader--引擎啟動器)
2. [game/profile-thread/ — 在線 Profile 執行緒](#2-gameprofile-thread--在線-profile-執行緒)
3. [game/thirdparty/ — 第三方函式庫](#3-gamethirdparty--第三方函式庫)
4. [game/engines/te4-1.7.6/data/ — 引擎靜態資產](#4-gameengineste4-176data--引擎靜態資產)
5. [game/modules/boot — 啟動/主選單模組](#5-gamemodulesboot--啟動主選單模組)
6. [game/modules/example — 回合制範例模組](#6-gamemodulesexample--回合制範例模組)
7. [game/modules/example_realtime — 即時制範例模組](#7-gamemodulesexample_realtime--即時制範例模組)
8. [game/modules/tome-1.7.6 — Tales of Maj'Eyal](#8-gamemodustome-176--tales-of-majeyal)
9. [game/addons/ — Addon 系統](#9-gameaddons--addon-系統)

---

## 1. game/loader/ — 引擎啟動器

`game/loader/` 是整個引擎的第一段 Lua 程式碼，在任何模組載入前執行。

### pre-init.lua

- **LuaJIT 初始化**：嘗試啟用 JIT（`jit.on()`，最佳化等級 2），失敗則降級到標準 Lua
- **RNG 工具函式**：注入全域 `rng.*` 函式（`mbonus`、`avg`、`table*`）
- **Table 序列化**：`table.serialize()` / `table.unserialize()` 用於遊戲狀態持久化
- **安全強化**：停用危險 OS 函式（`os.execute`、`os.getenv`、`os.remove`、`os.rename`）

### init.lua

**引擎發現與載入**：
- 掃描 `/engines/` 目錄尋找可用引擎版本（支援目錄型或 `.teae` 壓縮包）
- 解析版本字串（`engine/version.lua` 或 `name-X.Y.Z.teae` 檔名格式）
- 選取指定版本（預設 "LATEST"），掛載到虛擬根目錄

**模組 Loader 鏈**（自訂 `package.loaders`）：
- `te4_loader()`：實作 Addon **Superload** 能力
  - 載入原始模組後，依 `__addons_superload_order` 順序在 `/mod/addons/<addon>/superload/` 找覆蓋
  - `loadPrevious()` 讓 superload 取得原始模組
- Stub DLC：`.lua.stub` 映射到預編譯 DLCD 內容

**設計模式**：
- **三層初始化**：pre-init（VM 設定）→ init（引擎選取）→ engine/init（遊戲設定）
- **Plugin 架構**：Addon superloading 讓模組在不修改基礎程式碼的情況下擴充任何模組

---

## 2. game/profile-thread/ — 在線 Profile 執行緒

獨立執行緒，負責維持與 te4.org 伺服器的連線，避免阻塞主遊戲迴圈。

### init.lua

執行緒初始化與生命週期管理。

### Client.lua

**雙 TCP Socket 架構**：
- 主 Socket（port 2257/2260）：請求/回應（認證、角色存檔、設定）
- Push Socket（port 2258/2260）：伺服器主動推送事件
- 元伺服器查詢：`profiles.te4.org:2240` 動態路由

**主要功能**：

| 功能 | 方法 |
|------|------|
| 認證 | Steam token（`STM_`）或帳號密碼（`AUTH`/`PASH`）|
| 角色管理 | `orderRegisterNewCharacter()`、chardump 兩段上傳 |
| 設定同步 | `orderSetConfigsBatch()` — 批次設定 + zlib 壓縮 |
| 雜湊驗證 | 模組/Addon MD5 批次校驗 |
| Addon 管理 | 版本上傳、Steam Workshop 整合、更新檢查 |
| 微交易 | Steam/TE4 購物車建立與完成 |
| 心跳 | 60 秒 keep-alive |

**設計模式**：Producer-Consumer（主執行緒推送命令，profile-thread 推回事件）、Non-blocking I/O（`socket.select()`）

### UserChat.lua

- 事件路由：talk、whisper、成就廣播、序列化資料
- 頻道管理：join/part 追蹤
- 好友列表：`FriendJoin`/`FriendPart` 事件

---

## 3. game/thirdparty/ — 第三方函式庫

| 函式庫 | 用途 |
|--------|------|
| `socket/` | TCP/UDP 網路（http, ftp, smtp, url 協議層） |
| `moonscript/` | MoonScript 編譯器（CoffeeScript 語法 → Lua 轉譯）|
| `jit/` | LuaJIT 位元碼生成與反組譯（bc, v, dis_* 多架構）|
| `lpeg/` | Lua PEG 解析表達式語法庫 |
| `lxp/` | Lua XML 解析器 |
| `remdebug/` | 遠端偵錯框架 |
| `algorithms/` | `binarysearch`、`unionfind`、`shuffling`、排序、Trie |
| `Json2.lua` | JSON ↔ Lua table 互轉 |
| `ltn12.lua` | LuaSocket 過濾器/泵浦（stream 資料管線）|
| `md5.lua` | MD5 雜湊（包裝 native md5.core）|
| `sha1.lua` | SHA1 雜湊 |
| `tween.lua` | 動畫 tween（緩動函數值內插）|
| `binpack.lua` | 2D 矩形打包（MAXRECTS，圖集生成）|
| `mime.lua` | MIME 編碼（Base64、Quoted-Printable）|
| `slt2.lua` | 簡易 Lua 模板引擎 |
| `vector.lua` | 2D 向量數學 |

---

## 4. game/engines/te4-1.7.6/data/ — 引擎靜態資產

| 目錄 | 內容 |
|------|------|
| `gfx/` | 材質圖集、粒子效果、UI 主題（dark/metal/parchment/stone/tombstone 等）|
| `gfx/shaders/` | GLSL 著色器（distortion/volumetric/advanced 等品質等級）|
| `gfx/ui/` | 按鈕、邊框、進度條、圖示 |
| `gfx/particles/` | 粒子特效精靈圖 |
| `font/` | TrueType + 位元圖字型，含 CJK 字集（ja_JP/ko_KR/zh_hans/zh_hant）|
| `locales/engine/` | 引擎 UI 翻譯（zh_hans、zh_hant、ja_JP、ko_KR）|
| `sound/ui/` | UI 互動音效（點擊、懸停、確認）|
| `keybinds/` | 預設按鍵設定 |

---

## 5. game/modules/boot — 啟動/主選單模組

**用途**：遊戲啟動時顯示的主選單模組（`is_boot=true`）。

**繼承**：`engine.GameEnergyBased + GameMusic + GameSound`（完整音訊/即時引擎）

**初始化流程**：`init.lua` → `load.lua` → `class/Game` → 顯示 MainMenu 對話框

**特色**：
- 即時模式（8 tick/s）
- 載入背景材質、Web tooltip、Discord Presence、shader 支援
- Player 繼承自 NPC（非獨立），使用 demo AI（`ai="player_demo"`）
- FOV 距離預計算用不同係數（除以 17 vs 14）
- 約 117 個 Lua 檔（21 mod + 96 data）

---

## 6. game/modules/example — 回合制範例模組

**用途**：最小化 RPG 模板，展示回合制地城探索 + 玩家 vs NPC 戰鬥。

**繼承**：`engine.GameTurnBased + engine.interface.GameTargeting`

**核心流程**：

```
tick() → engine.GameTurnBased.tick()
Player.act(): cooldowns → regen → timedEffects → 消耗 energy
  → game.paused = true（等待輸入）
```

**類別結構**：

```
Game (439行) ← GameTurnBased + GameTargeting
  Player ← Actor + PlayerRest/Run/Hotkeys/Mouse
  NPC    ← Actor + ActorAI
  Actor  ← Entity + ActorStats/Talents/Life/FOV/Resource...
  Grid
  interface/Combat.lua
```

**資料層**：30+ Lua 檔（talents、damage_types、birth、zones、grids、NPCs）

**顯示**：32×32 ASCII 圖磚，底部 80% 為 log，右側 20% 為快捷鍵/NPC 列表

**Birth 流程**：選擇 "base" + "role" 描述符，合併屬性、技能、裝備到角色

---

## 7. game/modules/example_realtime — 即時制範例模組

**用途**：與 `example/` 內容完全相同，但改為即時制（energy-based）。

**關鍵差異**：

| 項目 | example（回合制）| example_realtime（即時制）|
|------|-----------------|--------------------------|
| 繼承 | `GameTurnBased` | `GameEnergyBased` |
| tick 回傳 | `true`（有暫停邏輯）| `false`（永不暫停）|
| 即時設定 | 無 | `core.game.setRealtime(20)` |
| 玩家行動 | useEnergy → paused=false | 無暫停邏輯 |
