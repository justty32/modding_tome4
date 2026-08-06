# tome-witchwood — 三個 agent 的共用契約

> ⚠️ **這是歷史文件，不要當範本抄。** 要寫新契約請用
> [wf/workflows/agent-driving/CONTRACT.template.md](../../wf/workflows/agent-driving/CONTRACT.template.md)。
> 這份缺三節（共用檔擴充點、依賴宣告、必填欄位），而那三項正是這次整合失敗的原因；
> 下方「生圖」一節的去背做法也已於 2026-08-01 被推翻。

**動工前必讀。** 三個 agent 平行做同一個 addon，靠這份契約避免撞車。
違反契約會導致整合失敗，而且多半是**靜默**的（id 不符 → 東西不出現，沒有錯誤訊息）。

## 主題

**女巫森林（Witchwood）**——瑞文谷（Derth）西北方一片被詛咒的老林。
接續本 repo 已有的女巫職業（`self_mods/tome-witch/`）：這裡是女巫的源頭。

## 誰做什麼（檔案樹互不重疊）

| Agent | 負責 | 只准碰這些路徑 |
|---|---|---|
| **A 怪物** | 三種原生怪 + 它們的美術 | `data/npcs/witchwood.lua`、`overload/data/gfx/npc/witchwood_*.png` |
| **B 地圖** | zone 定義、地形、進入點 | `data/zones/witchwood/**`、`data/maps/**`、`overload/data/gfx/terrain/witchwood_*.png` |
| **C 劇情** | 任務、對話、任務 NPC | `data/quests/witchwood-*.lua`、`data/chats/witchwood-*.lua`、`data/npcs/witchwood-quest.lua` |

**`init.lua` 與 `hooks/load.lua` 已經寫好了，任何人都不要改。**
hook 會自己偵測哪些檔案存在並跳過缺的，所以你可以在別人還沒做完時就獨立跑 verify。

## id 命名（硬性，不得更動）

其他 agent 會直接引用這些字串。**先定好，不准自己改名。**

### Agent A 必須定義的怪物 id

| id | 中文名 | 大致定位 |
|---|---|---|
| `WITCHWOOD_HAG` | 林中老嫗 | 施法者，會下毒與詛咒，本區主要威脅 |
| `WITCHWOOD_THORNLING` | 荊棘幼苗 | 近戰雜兵，數量多、單體弱 |
| `WITCHWOOD_CAULDRON` | 遊走坩堝 | 耐打，會噴藥霧（範圍效果） |

用 `newEntity{ define_as = "WITCHWOOD_HAG", ... }`，並記得 `resolvers.talented`／`resolvers.equip` 之類照原版 NPC 慣例。

### Agent B 必須使用的 id

- zone short_name：**`witchwood`**（`data/zones/witchwood/zone.lua`）
- zone 內刷怪一律引用上表三個怪物 id，**不要自己再定義怪**
- 大地圖入口放在瑞文谷附近，`change_zone = "witchwood"`

### Agent C 必須使用的 id

- 任務 id：**`witchwood-curse`**（`data/quests/witchwood-curse.lua`）
- 任務 NPC：`WITCHWOOD_CRONE`（定義在 `data/npcs/witchwood-quest.lua`，**不是** A 的檔案）
- 對話檔：`data/chats/witchwood-crone.lua`
- 任務目標可以引用 `WITCHWOOD_HAG`（例如「討伐林中老嫗」）

## 美術規則（這批坑剛查清楚，照做就好）

**自製圖一律放 `overload/data/gfx/…`，引用時寫相對 `data/gfx/` 的路徑。**

`overload/` 是 prepend 掛在 VFS 根（`E/Module.lua:523` 第三參數 `false`），
所以 `overload/data/gfx/npc/witchwood_hag.png` 在遊戲裡就是 `/data/gfx/npc/witchwood_hag.png`，
引用寫 `image = "npc/witchwood_hag.png"`——**和借用原版資產的寫法完全一樣**。

**⚠️ 檔名一律加 `witchwood_` 前綴。** prepend 代表撞名會**靜默覆蓋原版、全遊戲生效**。
`R/deathknight` 全部加 `_raz` 字尾就是為了這個。

**addon 的 `data/` 掛在私有點 `/data-witchwood/`，放 PNG 在那裡讀不到**，別放錯。

細節見 `docs/knowledge/visuals-and-sounds.md`。

### 生圖

機器上有 `agy`，**有圖像生成能力**：

```bash
agy --dangerously-skip-permissions -p "生成一張 64x64 …，像素風格，存成 xxx.png"
```

> ⚠️ **下面這段的去背做法已於 2026-08-01 被實測推翻，不要照做。**
> 正確做法見 [assets.md](../../wf/workflows/agent-driving/assets.md)：
> 要透明的圖一律叫它畫在純洋紅 `#FF00FF` 底上再 `-transparent '#FF00FF'` key 掉；
> 驗收要看 `magick x.png -alpha extract -format 'min=%[fx:minima*255]\n' info:` 的
> `min` 是不是 0——**`identify %[channels]` 顯示 `srgba` 只證明通道存在，不證明有透明**。
> 本 addon 的兩張樹貼圖就是照下面這段做壞的（1-bit alpha，殘邊清不掉），
> 最後改成從原版資產色調位移才乾淨。

三個實測出來的坑：

1. **它存到自己的 scratch**（`~/.gemini/antigravity-cli/scratch/`），**不是**你的工作目錄。要自己 `cp` 出來。
2. **它會宣稱生成成功但實際沒產出檔案。** 生完一定要 `ls` 確認檔案真的在、mtime 是新的。
3. ~~**它給的 PNG 沒有 alpha 通道**（即使你要求透明背景）。要自己補：~~
   ```bash
   # ↓ 已作廢，見上方警告
   magick in.png -fuzz 12% -transparent white out.png
   magick identify -format '%[channels]\n' out.png   # 這條驗收是無效的
   ```

尺寸：地圖用的 npc/terrain 圖是 **64×64**。

**美術品質由使用者肉眼判斷，你不要自己讀圖評價。** 生完就好，把路徑列在回報裡。

## 驗證（每個 agent 各自跑）

```bash
tools/lint.sh tome-witchwood
TOME_PLAYTEST_STATE=/tmp/tome4-playtest-<你的代號> tools/verify.sh tome-witchwood
```

**`TOME_PLAYTEST_STATE` 一定要設成你自己的**，否則會 `rm -rf` 掉別人的 state。
代號用 `a` / `b` / `c`。

hook 結尾會印 `[WITCHWOOD] selfcheck <你的部分> = OK/FAIL`，verify 靠這個判定。

## 鐵律（違反會壞事）

- **絕不執行 `t-engine64`、`tools/run.sh`**。自動化只走 `verify.sh` / `playtest.sh`。
- 不要碰 `vendor/`（唯讀）、不要碰別的 agent 的檔案、不要改 `init.lua` / `hooks/load.lua`。
- 不要 commit、不要 push。
- 引擎行為結論要附 `檔案:行號`，寫完用 `sed -n '<行號>p'` 複驗那一行真的是你說的東西。
- 輸出繁體中文，不要 ASCII 框線圖。
