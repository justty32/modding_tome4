locale "zh_hant"

-- 來源：player-ai/hooks/load.lua
-- game.log() 訊息會經由 engine/LogDisplay.lua 的 str:tformat(...) 自動查表，
-- 不需原始碼自行呼叫 _t()，故沿用官方慣例使用 "log" tag。
section "data-player-ai/hooks/load.lua"

t("#GOLD#Player AI Toggle requested!", "#GOLD#已請求切換玩家 AI！", "log")

-- 來源：player-ai/superload/mod/class/Player.lua
-- 同上，皆為 aiStop(msg) 或 game.log(msg) 的固定字面量參數，
-- 於 LogDisplay:call 內自動 tformat()，故可用 locale 覆蓋。
section "data-player-ai/superload/mod/class/Player.lua"

t("#LIGHT_RED#AI Stopping!", "#LIGHT_RED#AI 停止運作！", "log")
t("#RED#AI cancelled for low health", "#RED#因生命值過低，AI 已取消行動", "log")
t("#LIGHT_RED#Attacked by unseen enemy! AI Stopping!#WHITE#", "#LIGHT_RED#遭到未知敵人攻擊！AI 停止運作！#WHITE#", "log")
t("#RED#AI stopped: Suffocating, no air in sight!", "#RED#AI 已停止：正在窒息，且視野內找不到空氣！", "log")
t("#GOLD#AI stopping: level change found", "#GOLD#AI 停止運作：偵測到樓層變換點", "log")
t("#GOLD#Disabling Player AI!", "#GOLD#正在關閉玩家 AI！", "log")
t("#RED#Player AI cannot be used in the wilderness!", "#RED#玩家 AI 無法在野外使用！", "log")
t("#RED#Player AI cancelled by wilderness zone!", "#RED#因進入野外區域，玩家 AI 已取消！", "log")
