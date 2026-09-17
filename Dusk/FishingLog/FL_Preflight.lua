-- FishingLog FR7.16 preflight hardening.
-- Sanitizes startup-critical saved data before FL_Main/FL_Window can consume it,
-- then restores the normal Dusk.Common PluginData loader immediately.

import "Dusk.Common"
import "Dusk.FishingLog.FL_Number"

local FL716_RawLoad = Turbine.PluginData.Load
local FL716_RawSave = Turbine.PluginData.Save
local FL716_BadTotalsCount = 0
local FL716_BadLocCount = 0

local function FL716_Save(scope,key,value)
    FL716_RawSave(scope,key,value)
end

local function FL716_SanitizeOptions(scope,value)
    local changed = false
    if type(value)~="table" then
        value = {}
        changed = true
    end

    local rawScale = value.scale
    local scale = FL_ToNumber(rawScale)
    if scale==nil then
        scale = 1
    else
        scale = math.max(0.5,math.min(2,scale))
    end
    if rawScale~=scale then
        value.scale = scale
        changed = true
    end

    if changed then FL716_Save(scope,"FL_Options",value) end
    return value
end

local function FL716_SanitizeTotals(scope,value)
    if value==nil then return nil end
    local changed = false
    local quarantine = {}
    local badThisLoad = 0

    if type(value)~="table" then
        quarantine.__root = value
        value = {}
        changed = true
        FL716_BadTotalsCount = FL716_BadTotalsCount+1
        badThisLoad = badThisLoad+1
    end

    if value.fp~=nil then
        local fp = FL_ToNumber(value.fp)
        if fp~=nil then
            if value.fp~=fp then changed=true end
            value.fp = fp
        else
            quarantine.fp = value.fp
            value.fp = nil
            changed = true
            FL716_BadTotalsCount = FL716_BadTotalsCount+1
            badThisLoad = badThisLoad+1
        end
    end

    for _,field in ipairs({"rod","wpn","shl"}) do
        local saved = value[field]
        if saved~=nil and (type(saved)~="string" or saved=="") then
            quarantine[field] = saved
            value[field] = nil
            changed = true
            FL716_BadTotalsCount = FL716_BadTotalsCount+1
            badThisLoad = badThisLoad+1
        end
    end

    for id,n in pairs(value) do
        if type(id)=="string" and #id==5 then
            local count = FL_ToNumber(n)
            if count~=nil then
                if n~=count then changed=true end
                value[id] = count
            else
                quarantine[id] = n
                value[id] = 0
                changed = true
                FL716_BadTotalsCount = FL716_BadTotalsCount+1
                badThisLoad = badThisLoad+1
            end
        end
    end

    if badThisLoad>0 then
        FL716_Save(scope,"FL_TotalsPreload_Quarantine",quarantine)
    end
    if changed then FL716_Save(scope,"FL_Totals",value) end
    return value
end

local function FL716_SanitizeLocs(scope,value)
    if value==nil then return nil end
    if type(value)~="table" then
        FL716_BadLocCount = FL716_BadLocCount+1
        FL716_Save(scope,"FL_LocsPreload_Quarantine",{{key="__root",data=value}})
        FL716_Save(scope,"FL_Locs",{})
        return {}
    end

    local bad = {}
    local remove = {}
    local changed = false
    for loc,t in pairs(value) do
        local valid = type(loc)=="string" and type(t)=="table"
        local r,y,x
        if valid then
            r,y,x = FL_ToNumber(t.r),FL_ToNumber(t.y),FL_ToNumber(t.x)
            valid = r~=nil and y~=nil and x~=nil
        end
        if valid then
            if t.r~=r or t.y~=y or t.x~=x then changed=true end
            t.r,t.y,t.x = r,y,x
        else
            table.insert(remove,loc)
            table.insert(bad,{key=tostring(loc),data=t})
            FL716_BadLocCount = FL716_BadLocCount+1
            changed = true
        end
    end

    for _,loc in ipairs(remove) do value[loc]=nil end
    if #bad>0 then FL716_Save(scope,"FL_LocsPreload_Quarantine",bad) end
    if changed then FL716_Save(scope,"FL_Locs",value) end
    return value
end

Turbine.PluginData.Load = function(scope,key,callback)
    local value = FL716_RawLoad(scope,key,callback)
    if key=="FL_Options" then
        return FL716_SanitizeOptions(scope,value)
    elseif key=="FL_Totals" then
        return FL716_SanitizeTotals(scope,value)
    elseif key=="FL_Locs" then
        return FL716_SanitizeLocs(scope,value)
    end
    return value
end

local FL716_OK,FL716_Error = pcall(function()
    import "Dusk.FishingLog.FL_Loader"
end)
Turbine.PluginData.Load = FL716_RawLoad
if not FL716_OK then error(FL716_Error) end

if FL716_BadTotalsCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Donnée(s) critique(s) de FL_Totals réparée(s) avant chargement : " or "Critical FL_Totals value(s) repaired before load: ")..FL716_BadTotalsCount)
end
if FL716_BadLocCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Lieu(x) invalide(s) retiré(s) et sauvegardé(s) avant chargement : " or "Invalid location(s) removed and saved before load: ")..FL716_BadLocCount)
end
