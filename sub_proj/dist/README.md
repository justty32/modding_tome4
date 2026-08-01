# dist —— 自製產物區

本工作區產出的**可對外使用產物**統一放這裡,等待被使用/發佈。這裡只放產物,不放原始碼(addon 原始碼在 repo 根的 `mods/`)。

## 結構

```text
dist/
└── addons/   # 打包好的 ToME4 addon(.teaa,可直接發佈或丟進 ~/.t-engine/4.0/addons/)
```

ToME4 modding 目前只有 addon 一種產物類型;若日後出現對外文檔、可重用 library 等,再加 `docs/`、`libs/` 子目錄並更新本檔與根 README。

> **在地化(zh_hant)成品在哪**:`sub_proj/tome4-ch/` 已把 18 個 `tome-*-zh` 翻譯伴生 addon 打包成 `.teaa`,放在 `sub_proj/tome4-ch/build/`(等同開發迴圈暫存產物,與 modkit 的 `build/` 同性質)。**尚未升格為此處的版本化正式成品**——比照 modkit build 的處理,發佈(cut release)是使用者觸發的動作。要正式發佈時,對選定的 `tome-*-zh` 各建一個 `dist/addons/<name>-zh-<版本>/`(含 `.teaa` 與 `SOURCE.md`,由 `sub_proj/tome4-ch/_tools/build.sh` 重建)。在那之前,要拿在地化 addon 去部署直接用 `sub_proj/tome4-ch/build/*.teaa`。

## 慣例

- 每個成品一個子資料夾,名字含版本:`<名稱>-<版本>/`(例:`tome-runewright-0.1.0/`),內含 `.teaa` 與 `SOURCE.md`(記錄由 repo 根的 `mods/` 哪個 addon、什麼日期、用什麼指令建出;addon 的 `version` 相容性要求見根 `AGENTS.md`「release/package 注意事項」)。
- **與 repo 根的 `build/` 的分工**:`build/` 是開發迴圈的暫存建置產物(build→deploy→測試,隨時被覆蓋,不保證與源碼同步);`dist/` 是確認過、帶版本、可交付的成品。要「找做好的 addon 去部署」一律以這裡為準,這裡沒有就代表尚未發佈。
- 部署到實機(`~/.t-engine/4.0/addons/`)的狀態**不在這裡記**——歸 `~/notes` 側管;這裡只是成品倉庫。
- 舊版本要不要留由使用者決定;預設保留最近一版,更舊的問過再刪。
