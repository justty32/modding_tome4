-- 把 tools/probes/<名字>.lua 壓成**單行純 ASCII** 的 Lua，好讓 xdotool 打進遊戲的
-- debug console。
--
-- 用法： lua tools/lua/flatten_probe.lua <probe.lua> [ARG1 的值] [ARG2 的值] ...
-- 輸出： 一行 Lua
-- 退出碼：0 成功 / 1 probe 有問題（訊息在 stderr）/ 2 參數錯誤
--
-- 為什麼需要壓平：
--   `playtest.sh lua` 是用 xdotool 把字元「打」進 Lua console，有兩個硬限制
--   （見 docs/knowledge/playtesting-parts/03-state-probes.md）：
--     1. 不吃換行——送出去的必須是一行
--     2. 只能 ASCII——中文送不進去，那一行會**靜默消失**（不報錯，只是沒有輸出）
--   所以 probe 可以正常排版、寫中文註解，但壓平後的**程式碼**必須是 ASCII。
--
-- 寫 probe 的規矩（刻意訂得死，換取壓平器可以很笨、很可預測）：
--   * 註解只能整行寫（該行第一個非空白字元是 `--`）。**不准行尾註解**——
--     壓平器不解析字串，分不出 `--` 是註解還是字串內容，會把後面整段吃掉。
--   * 每一行要是完整的敘述，因為壓平就只是「用空白把行接起來」。
--   * 要印東西一律自己 `print("[標籤] ...")`；console 的回傳值不會進 stdout。
--   * 需要參數就寫裸識別字 `ARG1`、`ARG2`，會被換成加好引號的 Lua 字串。

local path = ...
if not path then
    io.stderr:write("用法: lua tools/lua/flatten_probe.lua <probe.lua> [ARG1] [ARG2] ...\n")
    os.exit(2)
end
local args = { select(2, ...) }

local fh, err = io.open(path, "r")
if not fh then
    io.stderr:write("讀不到 probe: " .. tostring(err) .. "\n")
    os.exit(2)
end

local parts = {}
local lineno = 0
for line in fh:lines() do
    lineno = lineno + 1
    -- 整行註解與空行直接丟掉
    if not line:match("^%s*$") and not line:match("^%s*%-%-") then
        local code = line:match("^%s*(.-)%s*$")
        -- 行尾註解會在壓平後把後續所有行變成註解，一定要擋下來
        if code:find("%-%-") then
            io.stderr:write(("%s:%d 有行尾註解，probe 只准整行註解：\n  %s\n")
                :format(path, lineno, code))
            os.exit(1)
        end
        parts[#parts + 1] = code
    end
end
fh:close()

local flat = table.concat(parts, " ")

-- ARG1 / ARG2 ... 換成加好引號的字串常值
for i = 1, #args do
    local v = tostring(args[i]):gsub('[\\"]', "\\%0")
    flat = flat:gsub("%f[%w_]ARG" .. i .. "%f[^%w_]", '"' .. v .. '"')
end
local leftover = flat:match("%f[%w_](ARG%d+)%f[^%w_]")
if leftover then
    io.stderr:write(("probe 需要 %s，但沒有提供對應的參數\n"):format(leftover))
    os.exit(1)
end

-- 壓平後必須是純 ASCII，否則送進 xdotool 會靜默失敗
local pos = flat:find("[\128-\255]")
if pos then
    io.stderr:write(("壓平後第 %d 個字元非 ASCII：%s\n"):format(pos, flat:sub(pos - 20, pos + 20)))
    io.stderr:write("probe 的**程式碼**只能用 ASCII（註解可以寫中文，會被剝掉）。\n")
    os.exit(1)
end

-- 語法檢查：壞掉的 probe 在這裡就該擋下，而不是打進遊戲後靜默無輸出
local chunk, lerr = loadstring(flat, "probe")
if not chunk then
    io.stderr:write("壓平後語法錯誤: " .. tostring(lerr) .. "\n")
    io.stderr:write(flat .. "\n")
    os.exit(1)
end

io.write(flat)
