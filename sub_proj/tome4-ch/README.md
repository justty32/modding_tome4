# tome4-ch — ToME4 Addon 正體中文化工作區

以**非侵入式翻譯伴生 addon** 的方式，為已安裝的 ToME 4 (1.7.6) 第三方 addon 提供正體中文化。原 addon 檔案一律不動。

## 機制

- 引擎對每個宣告 `data = true` 的 addon 自動載入 `data/locales/<語系>.lua`
  （`Module.lua:506`，「addons just need to provide the file and it's autoloaded」）。
- locale 映射**全域、以原文字串為 key**：伴生 addon 的 `zh_hant.lua` 可以直接翻譯
  目標 addon 的字串，只要條目的原文與 tag 正確。
- 使用者遊戲語系：`zh_hant`（`~/.t-engine/4.0/settings/locale.cfg`）。
- 純 locale 條目、零 hooks/superload，停用伴生 addon 即完全還原英文。

## 目錄結構

```
tome4-ch/
├── README.md              # 本檔
├── GUIDE.md               # 漢化 agent 工作指南（格式、tag 規則、驗證）
├── _tools/
│   ├── check_locale.lua   # 驗證腳本（lua5.1）：語法/逐字比對/格式符
│   ├── init_template.lua  # 伴生 addon init.lua 模板
│   └── build.sh           # 打包全部伴生 addon 成 .teaa 到 build/
├── _reference/
│   ├── orig/<addon>/      # 各原 addon 解壓（唯讀參考）
│   └── chn-mod/           # 簡體翻譯包解壓（機制範本）
├── tome-<name>-zh/        # 各翻譯伴生 addon 原始碼
└── build/                 # 打包好的 tome-<name>-zh.teaa
```

## 漢化對象與狀態

| addon | 類型 | 條目 | 狀態 |
|---|---|---|---|
| arcanum | 職業內容包 | 1078 | ✅ 完成 |
| verdant | 職業內容包 | 997 | ✅ 完成 |
| nullpack | 職業內容包 | 616 | ✅ 完成 |
| possessors | 職業內容包 | 258 | ✅ 完成（原 addon 已內建 zh_hant，伴生版修 4 處舊譯） |
| midnight | 職業內容包 | 468 | ✅ 完成 |
| necromancy+ | 職業內容包 | 263 | ✅ 完成（伴生名 necromancy-plus-zh） |
| deathknight | 職業內容包 | 347 | ✅ 完成 |
| better_item_desc | QoL | 113 | ✅ 完成 |
| improved-restauto | QoL | 44 | ✅ 完成 |
| mod-descriptions | QoL | 198 | ✅ 完成 |
| player-ai | QoL | 9 | ✅ 完成（Dialog UI 字串不走 _t，見 NOTES） |
| faster_rre | QoL | — | 跳過（訊息與基礎遊戲相同，官方已覆蓋） |
| ignore_rc_locks | QoL | 2 | ✅ 完成 |
| no-talent-caps | QoL | — | 跳過（無可見文字） |
| combat-turn-separators | QoL | 5 | ✅ 完成 |
| hz-escorts | QoL | 20 | ✅ 完成 |
| select-your-escorts | QoL | 13 | ✅ 完成（只收玩家可見 UI/對話，內部 id 與 console print 不收） |
| skill-on-drop | QoL | 3 | ✅ 完成（簡體玩家可見字串轉正體；debug log 不收） |
| steamwitch | 職業內容包 | 346 | ✅ 完成 |
| zomnibus | QoL/整合包 | 858 | ✅ 完成（排除 1 條內部 Lua pattern） |
| neka_therianthropy_summoner | 職業內容包 | 11057 | 暫緩（原 addon 目前停用且與 1.7.6 相容性有問題） |

翻譯管線（`_tools/`）：`extract.py` 機械抽取 byte-exact 原文（用 possessors 官方級翻譯校準）→
`translate.py` 驅動 agy 批次翻譯（格式符/數字/色碼硬驗證+重試）→ `assemble.py` 組裝 locale
（salvage 的 Claude 翻譯優先）→ `check_locale.lua` 驗證。`resume_agy.sh` 監視 agy 額度自動續跑。

**不做**：master-spell-merchants（2026-07-18 使用者退訂該 addon，先前進行中的 356/1490 譯文作廢，
`_work/` 與 `_reference/orig/` 的相關檔已清除）、
chn-mod（本身是簡體翻譯包，且其 zh_hans 條目在 zh_hant 語系下不會載入）、
items-vault（官方已內建 zh_hant）、valley_water（純 bugfix 無可見文字）、
addon-dev / remote-designer（開發工具，暫緩）。

## 打包與安裝

```bash
~/repo/moddings/tome4/sub_proj/tome4-ch/_tools/build.sh        # 產出 build/*.teaa
# 安裝：把 build/*.teaa 複製到
#   ~/.local/share/Steam/steamapps/common/TalesMajEyal/game/addons/
# 移除：刪掉對應 tome-*-zh.teaa 即可，原 addon 不受影響
```

## 驗證

```bash
lua5.1 _tools/check_locale.lua tome-<name>-zh/data/locales/zh_hant.lua _reference/orig/<name>/
```
