locale "zh_hant"

-- 來源：ignore_rc_locks/data/achievements/unlock.lua
section "data-ignore_rc_locks/achievements/unlock.lua"

-- name 欄位由 mod/class/interface/WorldAchievements.lua:48
-- `t.name = _t(t.name, "achievement name")` 自動查表，沿用官方成就名稱 tag。
t("Purely a Formality", "純屬形式", "achievement name")

-- desc 欄位在原始碼中已用 _t[[...]] 包裹（無指定 tag，預設為 "_t"）。
t("Unlock a locked race or class while playing a character of that race/class.", "在遊玩該種族／職業的角色時，解鎖一個原本被鎖定的種族或職業。", "_t")
