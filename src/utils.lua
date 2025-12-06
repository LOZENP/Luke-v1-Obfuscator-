-- utils.lua
-- Utility functions for the obfuscator

local Utils = {}

function Utils.randomSeed()
    math.randomseed(os.time() + os.clock() * 1000000)
end

function Utils.randName(style)
    style = style or "random"
    
    if style == "random" then
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        local name = ""
        for i = 1, math.random(8, 16) do
            local pos = math.random(1, #chars)
            name = name .. chars:sub(pos, pos)
        end
        return name
    elseif style == "readable" then
        local prefixes = {"get", "set", "do", "run", "exec", "call", "init", "load", "check", "validate", "process", "handle"}
        local suffixes = {"Data", "Value", "Info", "Result", "State", "Config", "Handler", "Manager", "Cache", "Buffer"}
        return prefixes[math.random(#prefixes)] .. suffixes[math.random(#suffixes)] .. math.random(100, 999)
    elseif style == "chinese" then
        local chars = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千", "万"}
        local name = "_"
        for i = 1, math.random(2, 5) do
            name = name .. chars[math.random(#chars)]
        end
        return name
    elseif style == "unicode" then
        local ranges = {
            {0x0391, 0x03A9}, -- Greek uppercase
            {0x0410, 0x042F}, -- Cyrillic uppercase
        }
        local name = "_"
        for i = 1, math.random(3, 6) do
            local range = ranges[math.random(#ranges)]
            local codepoint = math.random(range[1], range[2])
            name = name .. utf8.char(codepoint)
        end
        return name
    end
    
    return "var" .. math.random(1000, 9999)
end

function Utils.xorByte(a, b)
    local result = 0
    local bitval = 1
    while a > 0 or b > 0 do
        if a % 2 ~= b % 2 then
            result = result + bitval
        end
        bitval = bitval * 2
        a = math.floor(a / 2)
        b = math.floor(b / 2)
    end
    return result
end

function Utils.generateKey(length)
    local key = {}
    for i = 1, length do
        key[i] = math.random(1, 255)
    end
    return key
end

function Utils.deepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = Utils.deepCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

function Utils.escape(str)
    return str:gsub("([\\\"'])", "\\%1")
end

function Utils.tableToString(tbl)
    local result = "{"
    for i, v in ipairs(tbl) do
        if i > 1 then result = result .. "," end
        if type(v) == "table" then
            result = result .. Utils.tableToString(v)
        else
            result = result .. tostring(v)
        end
    end
    result = result .. "}"
    return result
end

return Utils
