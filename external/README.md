# external —— 他人素材(第三方 addon 參考)

根 README/AGENTS 預留的「他人 addon 參考素材」區。這裡放**非本工作區自製**、當唯讀參考用的第三方 addon 內容。與 `projects/t-engine4/`(引擎/模組 Lua 源碼)平行:那邊是引擎真相層,這裡是第三方 addon 素材層。

## 結構

```text
external/
├── orig/      # 25 個第三方 addon 的解壓(唯讀參考):arcanum / nullpack / midnight … 等真實職業包與 QoL addon
└── chn-mod/   # 某簡體中文翻譯包解壓(在地化機制範本)
```

## 由來與消費者

- 2026-07-18 從 `~/code/tome4-ch/_reference/` 提上來(原先各子專案各自持有,收攏成共用區)。
- **消費者一:在地化工作區** `derived/tome4-ch/`——其 `_reference/orig`、`_reference/chn-mod` 是指回這裡的 symlink(`../../../external/...`),所以該子專案的相對路徑管線(`_tools/check_locale.lua _reference/orig/<name>/`、`resume_agy.sh`)照舊可用,不必改腳本。
- **消費者二:addon 開發工具鏈** `derived/tome4-modkit/`——其知識庫的真相層代號 `R` 指向 `external/orig`(見 `derived/tome4-modkit/knowledge/README.md`),作為「實裝過的第三方 addon,唯讀」對照。

## 慣例

- **唯讀**:這裡的檔案是別人的 addon,一律不改。要對照就 grep/讀,不 in-place 編輯。
- 可重新取得(從 Steam Workshop / 遊戲 `addons/` 解壓),故不特別做版控備份;真正的自製產物在 `dist/`,自製源碼在 `derived/`。
- `orig/master-spell-merchants` 已於 2026-07-18 隨使用者退訂該 addon 一併移除。
