-- 程式化建角：讓 agent 不碰滑鼠鍵盤就走完 Birther。
--
-- 為什麼需要 superload：
--   建角對話框（Dialog）會攔下所有鍵盤事件，ctrl+L 的 Lua console
--   （E/data/keybinds/debug.lua:20-26）在那個畫面**進不去**（已實測 FAIL）。
--   所以建角完成前沒有任何程式化入口，這是整條無頭測試鏈唯一的斷點。
--
-- 為什麼不用引擎的 __module_extra_info.auto_birth（E/Birther.lua:335）：
--   ToME 用自訂 GUI birther，把引擎的 selectType/updateList 覆寫成空函式
--   （M/mod/dialogs/Birther.lua:1140-1141），那條清單流程根本不會跑。
--
-- 做法抄原版自己的 makeDefault()（M/mod/dialogs/Birther.lua:392，註解寫著
-- "Make a default character when using cheat mode, for easier testing"）：
-- 設好全部 descriptor 再 atEnd("created")。差別有三：
--   1. makeDefault 漏設 order 裡的 "base"，於是 setDescriptor 算出的 ok 是 false，
--      c_ok 保持 hidden，atEnd 第一行 `not self.ui_by_ui[self.c_ok].hidden` 直接擋掉
--      （:306）——實測按 Enter 觸發 makeDefault 後紙娃娃會變、但 birth 不會完成。
--      本檔補上 "base"（M/data/birth/descriptors.lua:32-33，name 就叫 "base"）。
--   2. makeDefault 寫死 Cornac Berserker；本檔從規格檔讀，才能測自訂職業。
--   3. atEnd 會 unregisterDialog 自己，在 on_register 當下做太危險，改用
--      game:onTickEnd 延到本 tick 結束。

local _M = loadPrevious(...)

local base_on_register = _M.on_register

-- 規格檔放使用者 home 根目錄：loader/init.lua:22 `fs.mount(homepath, "/")`
-- 把 <home>/.t-engine/4.0 掛在 PhysFS 根，所以 "/autobirth.lua" 就是那個檔。
-- 檔案不存在就整個 addon 靜默 no-op。
local SPEC_PATH = "/autobirth.lua"

local DEFAULTS = {
    name       = "autotest",
    base       = "base",
    world      = "Maj'Eyal",
    difficulty = "Normal",
    permadeath = "Adventure",
    race       = "Human",
    subrace    = "Cornac",
    sex        = "Female",
    class      = "Warrior",
    subclass   = "Berserker",
}

local function read_spec()
    if not fs.exists(SPEC_PATH) then return nil end
    local f, err = loadfile(SPEC_PATH)
    if not f then
        print("[AUTOBIRTH] 規格檔讀取失敗: " .. tostring(err))
        return nil
    end
    local ok, spec = pcall(f)
    if not ok or type(spec) ~= "table" then
        print("[AUTOBIRTH] 規格檔要 return 一個 table，實得: " .. tostring(spec))
        return nil
    end
    return spec
end

function _M:on_register()
    base_on_register(self)

    local spec = read_spec()
    if not spec then return end

    -- 名字至少 2 字元，否則 setDescriptor 算出的 ok 永遠 false（:749）。
    local name = tostring(spec.name or DEFAULTS.name)
    if #name < 2 then name = DEFAULTS.name end
    self.c_name.text = name

    -- 依 order 的順序設，讓每次 setDescriptor 的 updateDescriptors 都看到前置條件
    -- （M/mod/class/Game.lua:280 的 order）。
    for _, key in ipairs(self.order) do
        self:setDescriptor(key, tostring(spec[key] or DEFAULTS[key]))
    end

    -- 自報現況，失敗時才有東西可看（規格打錯字的話 descriptor 會是 nil）。
    local missing = {}
    for _, key in ipairs(self.order) do
        if not self.descriptors_by_type[key] then missing[#missing + 1] = key end
    end
    local hidden = self.ui_by_ui[self.c_ok].hidden
    print(("[AUTOBIRTH] name=%s race=%s/%s class=%s/%s missing=%s ok_hidden=%s"):format(
        name, tostring(self.descriptors_by_type.race), tostring(self.descriptors_by_type.subrace),
        tostring(self.descriptors_by_type.class), tostring(self.descriptors_by_type.subclass),
        (#missing > 0 and table.concat(missing, ",") or "none"), tostring(hidden)))

    if #missing > 0 or hidden then
        print("[AUTOBIRTH] 放棄自動建角，留在建角畫面（規格可能有錯字，descriptor 名稱要用英文原名）")
        return
    end

    -- no_birth_popup 同時跳過升級對話框與開場劇情（M/mod/class/Game.lua:341,345）。
    __module_extra_info.no_birth_popup = true

    -- atEnd 會 game:unregisterDialog(self)，不能在 on_register 執行中做。
    game:onTickEnd(function()
        print("[AUTOBIRTH] atEnd(created)")
        self:atEnd("created")
    end)
end

return _M
