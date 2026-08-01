每個模組是獨立的遊戲，以 `.team` 壓縮包發佈：
- `tome-1.7.6.team` — Tales of Maj'Eyal（主遊戲）
- `boot-te4-1.7.6-nomusic.team` — 啟動/選單模組
- `example/`, `example_realtime/` — 範例模組（範本）

模組透過繼承 `engine.*` 類別並覆寫方法來實作遊戲規則，引擎不強制任何具體遊戲規則。

---
