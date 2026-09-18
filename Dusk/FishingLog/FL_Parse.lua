-- FishingLog pure parsing helpers.
-- Kept free of Turbine dependencies so message formats can be regression-tested.

local FL_IIDDIDPattern =
    "<Examine:IIDDID:0x0%x+:0x700(%x+)>%[(.-)%]<\\Examine>"

function FL_ExtractIIDDID(message)
    if type(message)~="string" then return nil,nil end
    return message:match(FL_IIDDIDPattern)
end

local function FL_HasFishingKeyword(message,lang)
    local low=string.lower(message)
    if lang=="FR" then
        return low:find("peche",1,true)~=nil or
               low:find("pêche",1,true)~=nil or
               message:find("Pêche",1,true)~=nil or
               message:find("PÊCHE",1,true)~=nil
    elseif lang=="DE" then
        return low:find("angeln",1,true)~=nil or
               low:find("fischen",1,true)~=nil
    end
    return low:find("fishing",1,true)~=nil
end

function FL_ParseFishingAdvancement(message,lang)
    if type(message)~="string" then return nil end
    lang=lang or "EN"

    if lang=="EN" then
        local fp=message:match("^Your proficiency in Fishing has increased to (%d+)%.?$")
        return FL_ToFishingLevel(fp)
    end

    if not FL_HasFishingKeyword(message,lang) then return nil end

    -- Localized LOTRO wording has changed over time. Require exactly one number
    -- in a fishing advancement message instead of blindly taking the first one.
    local only,count=nil,0
    for raw in message:gmatch("(%d+)") do
        count=count+1
        if count>1 then return nil end
        only=raw
    end
    if count~=1 then return nil end
    return FL_ToFishingLevel(only)
end
