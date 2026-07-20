```
game/
├── loader/           ← 引擎啟動（JIT、安全、Addon superload）
├── profile-thread/   ← 非同步在線服務（TCP、認證、聊天）
├── thirdparty/       ← 第三方庫（網路、解析、加密、動畫等）
├── engines/
│   └── te4-1.7.6/
│       ├── engine/   ← 引擎核心 Lua（→ 見 engine_detail.md）
│       └── data/     ← 引擎靜態資產（圖形、字型、著色器、音效）
├── modules/
│   ├── boot/         ← 主選單（即時制 + 全音訊）
│   ├── example/      ← 回合制模板（教學用）
│   ├── example_realtime/ ← 即時制模板（教學用）
│   └── tome-1.7.6/   ← Tales of Maj'Eyal（完整遊戲）
│       ├── mod/
│       │   ├── class/         ← 核心類別（Game/Actor/Player/NPC/Party…）
│       │   ├── class/interface/ ← ToME 專用混入（Combat/Archery/ActorAI…）
│       │   ├── ai/            ← 14 個 AI 腳本（戰術/護送/影子/沙蟲…）
│       │   ├── init.lua       ← 元資料 + 145 載入提示
│       │   ├── load.lua       ← 系統初始化 + 16 槽揹包定義
│       │   ├── settings.lua   ← 使用者設定預設值
│       │   └── resolvers.lua  ← 進階物品生成
│       └── data/
│           ├── birth/         ← 職業/種族/世界 + 難度設定
│           ├── talents/       ← 13 類 200+ 技能檔案
│           ├── zones/         ← 89 個地區定義
│           ├── general/       ← 通用實體（NPC/物品/地形/商店/陷阱）
│           ├── damage_types.lua ← 40+ 傷害類型
│           ├── resources.lua  ← 11 種資源池
│           └── factions.lua   ← 25+ 個陣營
└── addons/
    ├── tome-addon-dev      ← 開發工具（FSHelper）
    ├── tome-items-vault    ← 跨角色保管庫（贊助功能）
    ├── tome-possessors     ← 附身者職業（付費 DLC）
    └── tome-remote-designer ← 即時實體設計器（開發工具）
```
