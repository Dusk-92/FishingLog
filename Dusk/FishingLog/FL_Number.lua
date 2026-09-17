-- FishingLog locale-safe numeric conversion.
-- LOTRO clients may use either a dot or a comma as decimal separator.

local FL_RawTonumber = tonumber

function FL_IsFiniteNumber(value)
    return type(value)=="number" and value==value and
           value~=math.huge and value~=-math.huge
end

local function FL_CheckedNumber(value)
    if FL_IsFiniteNumber(value) then return value end
    return nil
end

function FL_ToNumber(value,base)
    if type(value)=="number" then return FL_CheckedNumber(value) end
    if type(value)~="string" then
        return FL_CheckedNumber(FL_RawTonumber(value,base))
    end

    if base~=nil then return FL_CheckedNumber(FL_RawTonumber(value,base)) end

    local n=FL_CheckedNumber(FL_RawTonumber(value))
    if n~=nil then return n end

    n=FL_CheckedNumber(FL_RawTonumber((value:gsub(",","."))))
    if n~=nil then return n end

    return FL_CheckedNumber(FL_RawTonumber((value:gsub("%.",","))))
end

function FL_ToNonNegativeInteger(value)
    local n=FL_ToNumber(value)
    if n==nil or n<0 or n~=math.floor(n) then return nil end
    return n
end
