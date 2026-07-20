**用途**：與 `example/` 內容完全相同，但改為即時制（energy-based）。

**關鍵差異**：

| 項目 | example（回合制）| example_realtime（即時制）|
|------|-----------------|--------------------------|
| 繼承 | `GameTurnBased` | `GameEnergyBased` |
| tick 回傳 | `true`（有暫停邏輯）| `false`（永不暫停）|
| 即時設定 | 無 | `core.game.setRealtime(20)` |
| 玩家行動 | useEnergy → paused=false | 無暫停邏輯 |

---
