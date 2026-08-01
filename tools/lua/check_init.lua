-- 檢查 addon 的 init.lua 是否宣告了引擎真的會讀的欄位。
-- 用法： lua tools/lua/check_init.lua <addon_dir>（一般由 tools/lint.sh 呼叫）
-- 退出碼：0 全過；1 有錯。
--
-- 欄位語意來源（1.7.6，全部實地複驗過行號）：
--   engine/Module.lua:390      natural_compatible = version_nearly_same(mod.version, add.version)
--                              且 add.for_module 必須等於模組 short_name
--   engine/Module.lua:409      addon 目錄必須以 "<for_module>-" 開頭才會被掃到
--   engine/Module.lua:437      table.sort(adds, a.weight < b.weight) ← weight 為 nil 會崩潰
--   engine/Module.lua:498-533  data/superload/overload/hooks 各自的 fs.mount 條件
--   engine/Module.lua:571-598  cheat_only / addons.cfg / natural_compatible 過濾
--   engine/version.lua:90-97   version_nearly_same：主版號需相同，且 addon 版本不得高於模組

local TARGET = { 1, 7, 6 }
-- 確保 require 找得到同目錄的 check_lib.lua，不管從哪個目錄執行
package.path = (arg[0]:match("^(.*/)") or ".") .. "?.lua;" .. package.path
local check = require("check_lib")

local dir = ...
if not dir then io.stderr:write("用法: lua tools/lua/check_init.lua <addon_dir>\n"); os.exit(2) end

local env = {}
local f, err = loadfile(dir .. "/init.lua")
if not f then io.stderr:write("init.lua 無法載入: " .. tostring(err) .. "\n"); os.exit(1) end
setfenv(f, env)
local okrun, runerr = pcall(f)
if not okrun then io.stderr:write("init.lua 執行錯誤: " .. tostring(runerr) .. "\n"); os.exit(1) end

-- 必填
for _, k in ipairs { "long_name", "short_name", "for_module", "version", "addon_version", "description" } do
    if env[k] == nil then check.err_("缺少必填欄位: " .. k) end
end

if env.for_module ~= nil and env.for_module ~= "tome" then
    check.warn_("for_module = " .. tostring(env.for_module) .. "（本工具鏈只驗證 tome）")
end

-- version 必須是 3 元素數字表，且要對得上實裝的引擎版本
check.check_ver(env, "version")
check.check_ver(env, "addon_version")

-- version 必須與 TARGET 相容（Module.lua:390 設 natural_compatible，否則靜態移除）
local v = env.version
if type(v) == "table" and #v == 3 and type(v[1]) == "number" then
    local compat = (v[1] == TARGET[1])
        and ((TARGET[2] == v[2] and TARGET[3] >= v[3]) or TARGET[2] > v[2])
    if not compat then
        check.err_(("version = {%s} 與模組 %d.%d.%d 不相容（engine/version.lua:90-97），"):format(
            table.concat(v, ","), TARGET[1], TARGET[2], TARGET[3])
            .. "addon 會被靜默移除、沒有任何錯誤訊息")
    end
end

-- short_name 決定 PhysFS 掛載點與 addons.cfg 的 key，不能含路徑分隔或空白
if type(env.short_name) == "string" then
    if env.short_name:find("[^%w%-_+]") then
        check.err_("short_name 只能用英數、- _ +（目前: " .. env.short_name .. "）")
    end
else
    if env.short_name ~= nil then check.err_("short_name 必須是字串") end
end

-- 目錄名慣例：Module.lua:409 用 `^tome%-` 篩選目錄，所以資料夾必須叫 tome-<short_name>
local base = dir:gsub("/+$", ""):match("([^/]+)$")
if type(env.short_name) == "string" then
    local want = env.for_module and (env.for_module .. "-" .. env.short_name) or ("tome-" .. env.short_name)
    if base ~= want then
        check.err_(("資料夾名「%s」必須等於「%s」，否則 Module.lua:409 掃不到"):format(base, want))
    end
end

-- 至少要開一個內容旗標，否則 addon 什麼都不做
if not (env.data or env.superload or env.overload or env.hooks) then
    check.err_("data/superload/overload/hooks 全未啟用，此 addon 不會載入任何東西")
end

-- 旗標宣告了就必須有對應目錄（Module.lua:505-517 用 fs.exists 判斷，缺了是靜默失效）
for flag, sub in pairs { data = "data", superload = "superload", overload = "overload", hooks = "hooks" } do
    if env[flag] and not check.has_dir(dir, sub) then
        check.err_(("宣告了 %s = true 但沒有 %s/ 目錄（會靜默失效）"):format(flag, sub))
    end
    if not env[flag] and check.has_dir(dir, sub) then
        check.warn_(("有 %s/ 目錄但沒宣告 %s = true，內容不會被載入"):format(sub, flag))
    end
end

-- weight 必填（Module.lua:437 直接 a.weight < b.weight，nil 會讓 table.sort 崩潰）。
if env.weight == nil then
    check.err_("必須設定 weight（Module.lua:437 用它排序，nil 會讓整個 addon 清單載入崩潰）")
elseif type(env.weight) ~= "number" then
    check.err_("weight 必須是數字")
end

-- data=true 掛到私有的 /data-<short_name>/（Module.lua:498-503），須手動 loadDefinition。
if env.data then
    local hook_src = check.read_file(dir .. "/hooks/load.lua") or ""
    local needs = {
        ["data/birth"] = { "Birther:loadDefinition", "職業/種族" },
        ["data/talents"] = { "ActorTalents:loadDefinition", "技能" },
    }
    for sub, spec in pairs(needs) do
        if check.has_dir_(dir, sub) then
            if not env.hooks then
                check.err_(("有 %s/ 但沒宣告 hooks = true；addon 的 data 掛在 /data-%s/，"):format(sub, tostring(env.short_name))
                    .. "不會被自動掃描，必須用 hooks/load.lua 的 ToME:load 手動載入")
            elseif not hook_src:find(spec[1], 1, true) then
                check.err_(("有 %s/ 但 hooks/load.lua 沒呼叫 %s()——%s定義不會生效"):format(sub, spec[1], spec[2])
                    .. "（見 Module.lua:498-503 與 arcanum/hooks/load.lua:47-54）")
            end
        end
    end
end

-- hooks/load.lua 內用 ActorTalents / Birther 等為全域是 runtime 錯（mod/load.lua 宣告為 local）。
if env.hooks then
    local hook_src = check.read_file(dir .. "/hooks/load.lua")
    if hook_src then
        local needs_require = {
            ActorTalents = "engine.interface.ActorTalents",
            ActorTemporaryEffects = "engine.interface.ActorTemporaryEffects",
            ActorResource = "engine.interface.ActorResource",
            Birther = "engine.Birther",
            DamageType = "engine.DamageType",
            PartyLore = "mod.class.interface.PartyLore",
        }
        -- 把註解剝掉再找用法，避免文件裡提到名字就誤判
        local code = hook_src:gsub("%-%-%[%[.-%]%]", ""):gsub("%-%-[^\n]*", "")
        for name, modpath in pairs(needs_require) do
            local used = code:find(name .. "%s*[:%.]")
            local required = code:find("local%s+" .. name .. "%s*=%s*require")
            if used and not required then
                check.err_(("hooks/load.lua 用了 %s 卻沒有 `local %s = require \"%s\"`——"):format(name, name, modpath)
                    .. "它在 mod/load.lua 是 local 不是全域，runtime 會 nil index")
            end
        end
    end
end

if env.author == nil then check.warn_("未設 author") end
if env.tags == nil then check.warn_("未設 tags") end

for _, m in ipairs(check.warns) do print("[WARN] " .. m) end
for _, m in ipairs(check.errors) do print("[FAIL] " .. m) end

if #check.errors > 0 then
    print(("init.lua 檢查失敗：%d 錯誤 / %d 警告"):format(#check.errors, #check.warns))
    os.exit(1)
end
print(("init.lua 檢查通過（%d 警告）"):format(#check.warns))
