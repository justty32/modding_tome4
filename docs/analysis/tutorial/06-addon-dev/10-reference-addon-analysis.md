| Addon | 使用機制 | 主要功能 |
|-------|----------|----------|
| `tome-addon-dev` | hooks + overload + superload | 開發工具（FSHelper、NPCDesign 等），僅 cheat 模式可用 |
| `tome-possessors` | hooks + superload + data | 完整 DLC 職業：hooks 載入天賦，superload/Actor.lua 攔截 gainExp |
| `tome-items-vault` | hooks + overload + data | 線上物品保管庫：hooks 注入地圖子產生器與實體列表 |

### tome-possessors 的載入流程

```
init.lua (hooks=true, superload=true, overload=true, data=true)
    │
    ├─ hooks/load.lua
    │      bindHook("ToME:load", PO.hookLoad)
    │
    ├─ superload/mod/class/Actor.lua
    │      loadPrevious(...)  ← 取得原始 Actor
    │      _M.gainExp = 包裝版（遇到 EFF_POSSESSION 時阻止經驗）
    │
    └─ overload/mod/class/PossessorsDLC.lua  ← 新類別（不覆蓋任何現有類別）
           hookLoad():
               ActorTalents:loadDefinition("/data-possessors/talents/...")
               ActorTemporaryEffects:loadDefinition("/data-possessors/timed_effects.lua")
               Birther:loadDefinition("/data-possessors/birth/psionic.lua")
```

---
