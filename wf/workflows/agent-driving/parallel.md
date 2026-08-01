# 平行跑多個 agent

← [agent-driving](README.md)

多個 agent 同時做**同一個 addon** 的編排規則。單一 agent 不必讀這份。

技術上可行，但**必須隔離 playtest 的 state dir**，否則後啟動的會 `rm -rf` 掉前一個的：

```bash
TOME_PLAYTEST_STATE=/tmp/tome4-playtest-<agent> pi -p ...
```

其餘本來就安全：`verify.sh` 用 `mktemp -d` 各自獨立（`tools/verify.sh:67`），
`pick_free_display` 會跳過已佔用的 display（`tools/lib/game.sh:10-18`）。

## ⚠️ 契約防得住 id 衝突，防不住「接縫」

**2026-08-01 三 agent 做 `tome-witchwood`（地圖／劇情／怪物）的實測結論。**
三個 agent 各自 verify 綠燈，**合起來卻是壞的**——因為沒有人負責檔案之間的交界：

| 接縫 | 後果 |
|---|---|
| A 的怪只有 `define_as` 沒有 `name` | 玩家一殺就 `all_kills[nil]` → Lua error（`M/mod/class/Actor.lua:3451`）。**verify 抓不到**，執行期才炸 |
| B 的 zone 沒把 C 的任務 NPC 載進 `npc_list` | NPC 不會出現，整條任務走不到 |

兩條都是 **C（最後跑完的那個）** 發現的，因為只有它看得到別人的成品。

所以：

1. **一定要有整合者。** 不是三個 agent 跑完就收工——編排者（你）必須在全部落地後
   自己跑一次 verify，並**主動檢查交界**：誰引用了誰、引用的欄位對方真的有嗎。
2. **排序讓最後一個當整合哨兵。** 相依性最高的（劇情＞地圖＞怪物）最後跑，
   它會順手抓出前面的漏洞。
3. **契約要明列「你依賴誰的什麼欄位」**，不只列 id。這次契約只寫了 id 名稱，
   沒寫「怪物必須有 `name`」，所以 A 沒做也不算違約。

## 共用檔要留擴充點，不要禁止修改

契約寫「不准改 `hooks/load.lua`」保證了平行安全，但 B 需要在那裡掛大地圖入口 hook，
結果變成**回報 → 編排者代改**的往返，白白多一輪。

下次改成：共用檔留一個明確的擴充點，各 agent 寫自己的 `hooks/parts/<agent>.lua`，
由 `load.lua` 迴圈載入。這樣既不互相踩，也不必經過人。

## 契約本身可能是錯的，要授權 agent 推翻它

這次契約寫 `change_zone = "witchwood"`——**錯的**。
`engine/Zone.lua:159-164` 靠 `+` 切出 addon 名，沒有 `+` 會去讀
`/data/zones/witchwood/`（原版不存在），進圖直接失敗；正解是 `"witchwood+witchwood"`。

Agent B 帶著行號證據偏離契約並回報，這是正確行為。所以契約裡要明講：

```text
契約若與引擎原始碼衝突，以原始碼為準。
偏離契約可以，但必須在回報裡說明偏離哪一條、為什麼，並附 檔案:行號。
```

