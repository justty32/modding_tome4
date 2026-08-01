# vendor —— 唯讀第三方素材

**非本 repo 自製**、只當唯讀參考用的外部內容。全部由 `.gitignore` 排除（可重新取得，不做版控），
只有本檔進版控。

## 結構

```text
vendor/
├── t-engine4/   # Steam 版解壓的 T-Engine4 引擎層 + ToME 模組層 Lua 源碼（126MB）——引擎真相層
├── orig/        # 25 個第三方 addon 的解壓：arcanum / nullpack / midnight … 等職業包與 QoL addon（105MB）
└── chn-mod/     # 某簡體中文翻譯包解壓（在地化機制範本）
```

`t-engine4/` 是**權威真相層**；`orig/` 與 `chn-mod/` 是第三方 addon 素材層。

還原步驟（fresh clone 後）見根 [AGENTS.md](../AGENTS.md)「Fresh clone / 環境還原」。

## 由來與消費者

- `orig/` 與 `chn-mod/` 2026-07-18 從 `~/code/tome4-ch/_reference/` 提上來（原先各子專案各自持有，收攏成共用區）。
- 2026-08-01 repo 以 addon 開發為主體重整時，原 `projects/t-engine4/` 與 `external/` 合併成本目錄。
- **消費者一：主體工具鏈**——`knowledge/` 的真相層代號 `E`/`M` 指向 `vendor/t-engine4/` 的引擎與模組源碼，
  `R` 指向 `vendor/orig/`（見 [knowledge/README.md](../knowledge/README.md)），作為「實裝過的第三方 addon，唯讀」對照。
  `tools/lib/paths.sh` 的 `TOME_SRC` 預設值也指向 `vendor/t-engine4`。
- **消費者二：在地化子專案** `sub_proj/tome4-ch/`——其 `_reference/orig`、`_reference/chn-mod` 是指回這裡的
  symlink（`../../../vendor/...`），所以該子專案的相對路徑管線（`_tools/check_locale.lua _reference/orig/<name>/`、
  `resume_agy.sh`）照舊可用，不必改腳本。

## 慣例

- **唯讀**：這裡的檔案是別人的東西，一律不改。要對照就 grep/讀，不 in-place 編輯。
  這是根 [AGENTS.md](../AGENTS.md) 的鐵律第 3 條。
- 可重新取得（從 Steam 安裝 / Workshop / 遊戲 `addons/` 解壓），故不做版控備份；
  真正的自製產物在 `sub_proj/dist/`，自製源碼在 repo 根的 `mods/`。
- `orig/master-spell-merchants` 已於 2026-07-18 隨使用者退訂該 addon 一併移除。
- **`vendor/t-engine4/` 只有 Lua 層**——C 層原始碼（`src/`）不在本地，要對照需另從官方 git（te4.org）取得。
