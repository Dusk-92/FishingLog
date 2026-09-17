-- FishingLog FR7.17 preflight hardening.
-- Sanitizes startup-critical saved data before FL_Main/FL_Window can consume it,
-- validates persisted item shortcuts in a real Quickslot, then restores the
-- normal Dusk.Common PluginData loader immediately.

import "Turbine.UI.Lotro"
import "Dusk.Common"
import "Dusk.FishingLog.FL_Number"

local FL717_RawLoad = Turbine.PluginData.Load
local FL717_RawSave = Turbine.PluginData.Save
local FL717_BadTotalsCount = 0
local FL717_BadLocCount = 0
local FL717_BadLocCounterCount = 0

local function FL717_Save(scope,key,value)
    FL717_RawSave(scope,key,value)
end

local function FL717_SanitizeOptions(scope,value)
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

    if changed then FL717_Save(scope,"FL_Options",value) end
    return value
end

local function FL717_IsShortcutUsable(saved)
    if type(saved)~="string" or saved=="" then return false end

    local ok = pcall(function()
        local probe = Turbine.UI.Lotro.Quickslot()
        probe:SetSize(1,1)
        probe:SetVisible(false)
        local shortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Item,saved)
        probe:SetShortcut(shortcut)
        local restored = probe:GetShortcut()
        if not restored or restored:GetType()~=Turbine.UI.Lotro.ShortcutType.Item then
            error("invalid restored item shortcut")
        end
    end)
    return ok
end

local function FL717_SanitizeTotals(scope,value)
    if value==nil then return nil end
    local changed = false
    local quarantine = {}
    local badThisLoad = 0

    if type(value)~="table" then
        quarantine.__root = value
        value = {}
        changed = true
        FL717_BadTotalsCount = FL717_BadTotalsCount+1
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
            FL717_BadTotalsCount = FL717_BadTotalsCount+1
            badThisLoad = badThisLoad+1
        end
    end

    for _,field in ipairs({"rod","wpn","shl"}) do
        local saved = value[field]
        if saved~=nil and not FL717_IsShortcutUsable(saved) then
            quarantine[field] = saved
            value[field] = nil
            changed = true
            FL717_BadTotalsCount = FL717_BadTotalsCount+1
            badThisLoad = badThisLoad+1
        end
    end

    local removeIds = {}
    for id,n in pairs(value) do
        if type(id)=="string" and #id==5 then
            local count = FL_ToNumber(n)
            if count~=nil then
                if n~=count then changed=true end
                value[id] = count
            else
                quarantine[id] = n
                table.insert(removeIds,id)
                changed = true
                FL717_BadTotalsCount = FL717_BadTotalsCount+1
                badThisLoad = badThisLoad+1
            end
        end
    end
    for _,id in ipairs(removeIds) do value[id]=nil end

    if badThisLoad>0 then
        FL717_Save(scope,"FL_TotalsPreload_Quarantine",quarantine)
    end
    if changed then FL717_Save(scope,"FL_Totals",value) end
    return value
end

local function FL717_SanitizeLocs(scope,value)
    if value==nil then return nil end
    if type(value)~="table" then
        FL717_BadLocCount = FL717_BadLocCount+1
        FL717_Save(scope,"FL_LocsPreload_Quarantine",{{key="__root",data=value}})
        FL717_Save(scope,"FL_Locs",{})
        return {}
    end

    local bad = {}
    local badCounters = {}
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

            local removeIds = {}
            for id,n in pairs(t) do
                if type(id)=="string" and #id==5 then
                    local count = FL_ToNumber(n)
                    if count~=nil then
                        if n~=count then changed=true end
                        t[id]=count
                    else
                        table.insert(removeIds,id)
                        table.insert(badCounters,{location=tostring(loc),id=id,data=n})
                        FL717_BadLocCounterCount=FL717_BadLocCounterCount+1
                        changed=true
                    end
                end
            end
            for _,id in ipairs(removeIds) do t[id]=nil end
        else
            table.insert(remove,loc)
            table.insert(bad,{key=tostring(loc),data=t})
            FL717_BadLocCount = FL717_BadLocCount+1
            changed = true
        end
    end

    for _,loc in ipairs(remove) do value[loc]=nil end
    if #bad>0 then FL717_Save(scope,"FL_LocsPreload_Quarantine",bad) end
    if #badCounters>0 then FL717_Save(scope,"FL_LocsCounterPreload_Quarantine",badCounters) end
    if changed then FL717_Save(scope,"FL_Locs",value) end
    return value
end

local function FL717_SanitizeLoaded(scope,key,value)
    if key=="FL_Options" then
        return FL717_SanitizeOptions(scope,value)
    elseif key=="FL_Totals" then
        return FL717_SanitizeTotals(scope,value)
    elseif key=="FL_Locs" then
        return FL717_SanitizeLocs(scope,value)
    end
    return value
end

Turbine.PluginData.Load = function(scope,key,callback)
    local wrappedCallback
    if callback then
        wrappedCallback=function(data)
            callback(FL717_SanitizeLoaded(scope,key,data))
        end
    end

    local value = FL717_RawLoad(scope,key,wrappedCallback)
    -- Preserve asynchronous callback semantics if an underlying loader returns
    -- no immediate value. Synchronous loads still receive sanitized data.
    if value==nil and callback then return nil end
    return FL717_SanitizeLoaded(scope,key,value)
end

local FL717_OK,FL717_Error = pcall(function()
    import "Dusk.FishingLog.FL_Loader"
end)
Turbine.PluginData.Load = FL717_RawLoad
if not FL717_OK then error(FL717_Error) end

if FL717_BadTotalsCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Donnée(s) critique(s) de FL_Totals réparée(s) avant chargement : " or "Critical FL_Totals value(s) repaired before load: ")..FL717_BadTotalsCount)
end
if FL717_BadLocCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Lieu(x) invalide(s) retiré(s) et sauvegardé(s) avant chargement : " or "Invalid location(s) removed and saved before load: ")..FL717_BadLocCount)
end
if FL717_BadLocCounterCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Compteur(s) de lieu illisible(s) retiré(s) avant chargement : " or "Unreadable location counter(s) removed before load: ")..FL717_BadLocCounterCount)
end
