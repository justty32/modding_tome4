-- 驗證輔助函式，由 check_init.lua 使用。
-- 欄位語意來源見 check_init.lua 檔頭。
local M = {}

M.errors, M.warns = {}, {}
function M.err_(m) M.errors[#M.errors + 1] = m end
function M.warn_(m) M.warns[#M.warns + 1] = m end

function M.check_ver(env, k)
    local v = env[k]
    if v == nil then return end
    if type(v) ~= "table" or #v ~= 3 then M.err_(k .. " 必須是 {a,b,c} 三元素數字表"); return end
    for i = 1, 3 do if type(v[i]) ~= "number" then M.err_(k .. "[" .. i .. "] 必須是數字") end end
end

function M.has_dir(dir, p)
    local ok_ = os.execute('test -d "' .. dir .. "/" .. p .. '"')
    return ok_ == 0 or ok_ == true
end

function M.read_file(p)
    local fh = io.open(p, "r"); if not fh then return nil end
    local c = fh:read("*a"); fh:close(); return c
end

function M.has_dir_(dir, p)
    return M.has_dir(dir, p)
end

return M
