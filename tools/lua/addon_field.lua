-- 從 addon 的 init.lua 取出一個頂層欄位的值。
--
-- 用法： lua tools/lua/addon_field.lua <addon_dir> <欄位名>
-- 輸出： 欄位值（table 用 "." 串接，例如 version={1,7,6} → "1.7.6"）；沒有該欄位就輸出空字串
--
-- 為什麼用 Lua 求值而不是 grep init.lua：
--   init.lua 是**真正的 Lua 原始碼**，欄位可能寫在註解裡、也可能是多行字串或運算式。
--   grep 會被騙；loadfile + setfenv 拿到的是引擎實際會看到的值。
--
-- setfenv 把 chunk 的全域環境換成空 table，所以 init.lua 裡的賦值全部落在 env 上，
-- 既讀得到值又不會污染本行程。pcall 是因為 init.lua 可能引用引擎才有的全域。

local dir, field = ...
if not dir or not field then
    io.stderr:write("用法: lua tools/lua/addon_field.lua <addon_dir> <欄位名>\n")
    os.exit(2)
end

local f = loadfile(dir .. "/init.lua")
if not f then os.exit(0) end   -- 沒有 init.lua：輸出空字串，交給呼叫端判斷

local env = {}
setfenv(f, env)
pcall(f)

local v = env[field]
if type(v) == "table" then
    io.write(table.concat(v, "."))
elseif v ~= nil then
    io.write(tostring(v))
end
