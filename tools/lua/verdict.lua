-- 判讀 t-engine 的 run.log，決定一個 addon 的無頭驗收是成功還是失敗。
--
-- 用法： lua tools/lua/verdict.lua <run.log> <ADDON_SHORT>
--        （ADDON_SHORT 是去掉 tome- 前綴的小寫名，例如 runewright）
-- 退出碼：0 通過 / 1 失敗 / 2 參數錯誤
-- 輸出：  人看得懂的證據行；呼叫端（tools/verify.sh）只需要看退出碼。
--
-- 判定順序刻意如此，改動前先讀：
--
--   1) Lua Error / stack traceback 一票否決。即使 hook 也印了 complete，
--      有 error 就是壞的——載入到一半炸掉仍可能留下部分成功的痕跡。
--
--   2) addon 自報的 `[SHORT] hook complete`（大寫）是**最可信**的成功訊號，
--      因為那行是 addon 自己在 hooks/load.lua 尾端印的，印得出來代表整個 hook 跑完。
--      此時再檢查 `selfcheck ... = FAIL`：selfcheck 是 addon 自己驗自己的定義有沒有註冊成功。
--
--   3) 沒有自報格式的 addon 走通用判定：引擎自己印的載入痕跡
--      （engine/Module.lua:411 "Checking addon"、:499 "with data"）。
--      這比較弱——只證明「引擎掃到並掛載了它」，不證明內容正確。
--
--   4) 什麼痕跡都沒有 → 失敗。多半是 version 與模組不相容被靜默移除
--      （engine/Module.lua:390 natural_compatible 為 false，全程沒有錯誤訊息）。

local log_path, short = ...
if not log_path or not short then
    io.stderr:write("用法: lua tools/lua/verdict.lua <run.log> <addon_short_name>\n")
    os.exit(2)
end

local upper = short:upper()

local fh, err = io.open(log_path, "r")
if not fh then
    io.stderr:write("讀不到 run.log: " .. tostring(err) .. "\n")
    os.exit(2)
end

-- Lua 的字串比對用的是 pattern 不是 regex，`[` `]` `-` 都要跳脫。
local function plain(s) return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")) end
local TAG = plain("[" .. upper .. "]")

local lines          = {}   -- 全部行，供 Lua Error 前後文用
local lua_error_at   = nil  -- 第一個 Lua Error 的行號
local hook_complete  = false
local selfchecks     = {}   -- {line_no, text}
local selfcheck_fail = false
local load_trace     = nil  -- 引擎自己印的載入痕跡

local n = 0
for line in fh:lines() do
    n = n + 1
    lines[n] = line

    if not lua_error_at and (line:find("Lua Error", 1, true) or line:find("stack traceback", 1, true)) then
        lua_error_at = n
    end
    if line:find(TAG) then
        if line:find("hook complete", 1, true) then hook_complete = true end
        if line:find("selfcheck", 1, true) then
            selfchecks[#selfchecks + 1] = { n, line }
            if line:find("= FAIL", 1, true) then selfcheck_fail = true end
        end
    end
    if not load_trace then
        local s = plain(short)
        if line:find("Checking addon.*" .. s)
            or line:find("with data.*" .. s)
            or line:find("loaded%-addons/" .. s .. "/") then
            load_trace = line
        end
    end
end
fh:close()

local function emit(fmt, ...) io.write(fmt:format(...), "\n") end

-- 1) Lua Error 一票否決
if lua_error_at then
    emit("偵測到 Lua Error（run.log:%d），以下是該處前後文：", lua_error_at)
    for i = lua_error_at, math.min(lua_error_at + 8, n) do
        emit("  %d: %s", i, lines[i])
    end
    emit("「%s」載入失敗。", short)
    os.exit(1)
end

-- 2) addon 自報格式
if hook_complete then
    for _, sc in ipairs(selfchecks) do emit("  %d: %s", sc[1], sc[2]) end
    if selfcheck_fail then
        emit("「%s」hook complete，但 selfcheck 有 FAIL（見上）。", short)
        os.exit(1)
    end
    emit("「%s」hook complete，%d 項 selfcheck 全過。", short, #selfchecks)
    os.exit(0)
end

-- 3) 通用判定
if load_trace then
    emit("  %s", load_trace)
    emit("偵測到「%s」的載入痕跡且無 Lua Error（通用判定：addon 未自報 hook complete）。", short)
    os.exit(0)
end

-- 4) 什麼都沒有
emit("沒看到「%s」的任何載入痕跡，也沒有明確錯誤。", short)
emit("最可能的原因：init.lua 的 version 與模組 1.7.6 不相容，addon 被靜默移除")
emit("（engine/Module.lua:390 natural_compatible 為 false，全程沒有錯誤訊息）。")
emit("先跑 tools/lint.sh %s 確認欄位，再看 run.log 有沒有 \"Checking addon\" 這行。", short)
os.exit(1)
