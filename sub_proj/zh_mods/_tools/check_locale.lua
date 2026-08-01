#!/usr/bin/env lua5.1
-- check_locale.lua <locale_file> <addon_src_dir>
-- 驗證翻譯 locale 檔：語法、src 逐字存在於原始碼、格式符一致、譯文非空
local locale_file, addon_dir = arg[1], arg[2]
if not locale_file or not addon_dir then
  print("usage: lua5.1 check_locale.lua <locale_file> <addon_src_dir>")
  os.exit(2)
end

local entries = {}
local cur_section = "(none)"
local env = {
  locale = function(_) end,
  section = function(s) cur_section = s end,
  setFlag = function(...) end,
  t = function(src, dst, tag)
    entries[#entries+1] = {src=src, dst=dst, tag=tag, section=cur_section}
  end,
}
local f, err = loadfile(locale_file)
if not f then print("SYNTAX ERROR: "..tostring(err)) os.exit(1) end
setfenv(f, env)
local ok, rerr = pcall(f)
if not ok then print("RUNTIME ERROR: "..tostring(rerr)) os.exit(1) end

-- 載入 addon 全部 lua 原始碼
local srcs = {}
local p = io.popen("find '"..addon_dir.."' -name '*.lua' -type f 2>/dev/null")
for path in p:lines() do
  local fh = io.open(path, "rb")
  if fh then
    local c = fh:read("*a"); fh:close()
    srcs[path] = c
    -- Lua 詞法器會把長字串內的 CRLF 正規化為 \n，比對時比照辦理
    if c:find("\r", 1, true) then srcs[path .. "#lf"] = c:gsub("\r\n", "\n") end
  end
end
p:close()

local function escape_variant(s)
  return (s:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub('"', '\\"'))
end
local function escape_variant_nl(s)
  -- "...\<真換行>" 延續寫法：只跳脫反斜線與引號，換行前補反斜線
  local e = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\\n")
  return e
end
local function escape_variant_sq(s)
  return (s:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("'", "\\'"))
end
local function found(needle)
  for _, content in pairs(srcs) do
    if content:find(needle, 1, true) then return true end
  end
  return false
end
local function specs(s)
  local list = {}
  for sp in s:gmatch("%%[%-%d%.]*[a-zA-Z%%]") do list[#list+1] = sp end
  return table.concat(list, "|")
end

local unmatched, badspec, empty = {}, {}, {}
for i, e in ipairs(entries) do
  if type(e.dst) ~= "string" or e.dst == "" then
    empty[#empty+1] = e
  end
  if type(e.src) == "string" then
    if not (found(e.src) or found(escape_variant(e.src)) or found(escape_variant_sq(e.src)) or found(escape_variant_nl(e.src))) then
      unmatched[#unmatched+1] = e
    end
    if type(e.dst) == "string" and e.src:find("%%") and specs(e.src) ~= specs(e.dst) then
      badspec[#badspec+1] = e
    end
  end
end

print(("entries=%d  unmatched=%d  badspec=%d  empty=%d")
  :format(#entries, #unmatched, #badspec, #empty))
local function dump(label, list, max)
  if #list == 0 then return end
  print("---- "..label.." ----")
  for i = 1, math.min(#list, max or 20) do
    local e = list[i]
    print(("[%s] tag=%s src=%q"):format(e.section, tostring(e.tag), e.src:sub(1, 100)))
  end
  if #list > (max or 20) then print(("... 共 %d 條"):format(#list)) end
end
dump("UNMATCHED（src 在原始碼找不到逐字對應）", unmatched)
dump("BADSPEC（格式符不一致）", badspec)
dump("EMPTY（譯文為空）", empty)
os.exit((#badspec == 0 and #empty == 0) and 0 or 1)
