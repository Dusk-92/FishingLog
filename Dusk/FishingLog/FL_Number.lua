-- FishingLog locale-safe numeric conversion.
-- LOTRO clients may use either a dot or a comma as decimal separator.

local FL_RawTonumber = tonumber

function FL_ToNumber(value,base)
    if type(value)=="number" then return value end
    if type(value)~="string" then return FL_RawTonumber(value,base) end

    -- Preserve normal Lua semantics when an explicit base is supplied.
    if base~=nil then return FL_RawTonumber(value,base) end

    local n=FL_RawTonumber(value)
    if n~=nil then return n end

    n=FL_RawTonumber((value:gsub(",",".")))
    if n~=nil then return n end

    return FL_RawTonumber((value:gsub("%.",",")))
end
