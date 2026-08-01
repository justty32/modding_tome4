# companions-and-party — 招募同伴、隨主人成長、對主人免傷

路徑代號見 [README.md](README.md)。前例：`tome-companions` addon（本工具鏈做的同伴系統）。

## 加入隊伍：`game.party:addMember(actor, def)`

`M/mod/class/Party.lua:46-88`。`def` 欄位：
- `control`：`"no"`（純召喚不可控）／`"order"`（可下令不可操控，如護送）／`"full"`（可切換操控）。
- `orders = {target=, leash=, anchor=, talents=, behavior=}`：可下達哪些指令白名單。
- addMember 會 `replaceWith(PartyMember.new(actor))`（`:76-84`）——但**同一 table identity 保留、欄位合併**，
  所以自訂標記（如 `co_owner`）放在 addMember **之後**設才不會被覆蓋。
- 入隊即自動 `tactic_leash_anchor=game.player`（跟隨玩家）、`tactic_leash=10`（`:67-69`）。

**招募既有 NPC 的最短路徑**（實測 `tome-companions` 的 `doRecruit`）：
```lua
target.faction = self.faction     -- 轉為玩家陣營
target.never_anger = true         -- 保險：不因誤傷反目（其實入隊後 NPC.lua:262 已自動短路）
game.party:addMember(target, {control="full", type="companion", title="...",
    orders={target=true, leash=true, anchor=true, talents=true, behavior=true}})
target.co_owner = self            -- 自訂標記，放在 addMember 之後
target.max_level = nil            -- ★ 必須：見下
target:forceLevelup(math.max(target.level or 1, self.level))
```
前例：`M/data/quests/love-melinda.lua:91-119`（完整可控可成長同伴）、
`M/data/chats/escort-quest-start.lua:23-107`（護送）、`golemancy.lua:228-249`（魁儡）。

## ★ 培養（隨主人成長）：`forceLevelup` + `callbackOnLevelup`，但先清 `max_level`

- `forceLevelup(lev)`（`E/interface/ActorLevel.lua:138`）把等級**升到** `lev`，
  但**遇到 `self.max_level` 且 `level >= max_level` 就 break**。
- **野生 NPC 幾乎都帶自己的 `max_level`（實測 black ooze=25）**，會把同伴的成長卡死在那個上限。
  招募時必須 `target.max_level = nil`，否則主人升到 30、同伴卡在 25。
  ——這是 verify 抓不到、只有 playtest 才現形的坑（2026-07-11 實測）。
- 隨主人升級：天賦裡定義 `callbackOnLevelup = function(self, t, new_level) ... end`，
  在主人升級時由 `M/mod/class/Actor.lua:4041` 的 `fireTalentCheck("callbackOnLevelup", self.level)` 觸發
  （註冊映射在 `Actor.lua:6062` `callbackOnLevelup = "talents_on_levelup"`）。
  callback 內遍歷 `game.party.m_list`，對 `co_owner==self` 的成員 `forceLevelup(new_level)`。
- **測試陷阱**：拿低血怪當測試同伴，別先用「敵人傷害」測完再測成長——30 傷害就把 level-1 的怪打死了，
  死掉的同伴 callback 會（正確地）跳過，看起來像「成長壞了」。測成長要用沒受傷的同伴。

## ★ 免傷（對主人免疫傷害）：沒有全域開關，只能 superload `onTakeHit`

基礎遊戲**沒有**「同隊/同陣營免傷」開關。faction 只管 AI 敵友判定；AOE 預設 `friendlyfire=true`
（`E/Target.lua:679-684`）仍會打到友軍，各技能得自己設 `friendlyfire=false`（魁儡技能就是逐一手動關）。
真正判斷點在 `E/interface/ActorProject.lua:254-255,493-494`。單體免傷唯一現成 attr 是
`invulnerable_others`（`M/mod/class/Actor.lua:2418`），但那是「對除自己外所有人免傷」，不是「只對主人」。

所以「同伴只免疫主人傷害、仍受敵人傷害」必須自己 superload：
```lua
-- superload/mod/class/Actor.lua
local _M = loadPrevious(...)
local base_onTakeHit = _M.onTakeHit
function _M:onTakeHit(value, src, death_note)
    if value and value > 0 and src and self.co_owner
       and (src == self.co_owner or (src.summoner and src.summoner == self.co_owner)) then
        return 0   -- 主人或主人的召喚物造成的傷害歸零
    end
    return base_onTakeHit(self, value, src, death_note)
end
return _M
```
實測：主人 99999 傷害 → 0；敵人 30 傷害 → 正常扣血。仿 `Actor.lua:2418` 的 `invulnerable_others` 寫法。

## 入隊即免「反目」（但不免「受傷」）

`M/mod/class/NPC.lua:262`：`if game.party:hasMember(self) then return end` 在 `checkAngered` 開頭短路——
只要在隊伍裡，被誰打都不會轉敵對。但這**只解決反目，不解決實際受傷**，兩者要分開處理（受傷靠上面的 onTakeHit）。

## 全角色可用：`ToME:birthDone` 教天賦

要讓某能力所有職業都有、且好測，用 `ToME:birthDone` hook（`M/mod/class/Game.lua:336,386` 廣播，此時
`game.player` 已存在）教一個 `no_energy` 天賦：
```lua
class:bindHook("ToME:birthDone", function(self, data)
    local p = game and game.player
    if p and not p:knowTalent(ActorTalents.T_X) then
        p:learnTalent(ActorTalents.T_X, true, nil, {no_unlearn=true})
    end
end)
```
天賦別設 `mana`/`is_spell`，否則無法力職業（狂戰士）用不了。
