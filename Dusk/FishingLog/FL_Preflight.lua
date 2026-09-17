-- FishingLog FR7.18 preflight hardening.
-- Sanitizes startup-critical saved data before FL_Main/FL_Window can consume it,
-- preserves rejected item shortcuts for later retry, keeps quarantine history,
-- then restores the normal Dusk.Common PluginData loader immediately.

import "Turbine.UI.Lotro"
import "Dusk.Common"
import "Dusk.FishingLog.FL_Number"

local FL718_RawLoad = Turbine.PluginData.Load
local FL718_RawSave = Turbine.PluginData.Save
local FL718_BadTotalsCount = 0
local FL718_BadLocCount = 0
local FL718_BadLocCounterCount = 0
local FL718_RestoredShortcutCount = 0

local function FL718_Save(scope,key,value)
    FL718_RawSave(scope,key,value)
end

-- Keep every recovery snapshot. Older FR7.17 quarantine files are preserved as
-- a legacy entry the first time they are converted to the cumulative format.
function FL_AppendQuarantine(scope,key,payload,callback)
    local previous = FL718_RawLoad(scope,key)
    local history
    if type(previous)=="table" and previous.__format=="FR7.18-history" and type(previous.entries)=="table" then
        history = previous
    else
        history = {__format="FR7.18-history",entries={}}
        if previous~=nil then
            table.insert(history.entries,{version="legacy",data=previous})
        end
    end
    table.insert(history.entries,{version="FR7.18",data=payload})
    return FL718_RawSave(scope,key,history,callback)
end

local function FL718_SanitizeOptions(scope,value)
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

    if changed then FL718_Save(scope,"FL_Options",value) end
    return value
end

local function FL718_IsShortcutUsable(saved)
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
        local data = restored:GetData()
        if type(data)~="string" or data=="" then
            error("empty restored item shortcut")
        end
    end)
    return ok
end

local function FL718_LoadPending(scope)
    local pending = FL718_RawLoad(scope,"FL_PendingShortcuts")
    if pending==nil then return {} end
    if type(pending)=="table" then return pending end
    FL_AppendQuarantine(scope,"FL_PendingShortcuts_Quarantine",pending)
    FL718_Save(scope,"FL_PendingShortcuts",{})
    return {}
end

local function FL718_SanitizeTotals(scope,value)
    if value==nil then return nil end
    local changed = false
    local quarantine = {}
    local badThisLoad = 0

    if type(value)~="table" then
        quarantine.__root = value
        value = {}
        changed = true
        FL718_BadTotalsCount = FL718_BadTotalsCount+1
        badThisLoad = badThisLoad+1
    end

    if value.fp~=nil then
        local fp = FL_ToNumber(value.fp)
        if fp~=nil and fp>=0 then
            if value.fp~=fp then changed=true end
            value.fp = fp
        else
            quarantine.fp = value.fp
            value.fp = nil
            changed = true
            FL718_BadTotalsCount = FL718_BadTotalsCount+1
            badThisLoad = badThisLoad+1
        end
    end

    -- An item shortcut rejected at this exact load may only be temporarily
    -- unavailable. Keep it outside FL_Totals so FL_Window stays safe, and retry
    -- it automatically on every future plugin load.
    local pending = FL718_LoadPending(scope)
    local pendingChanged = false
    for _,field in ipairs({"rod","wpn","shl"}) do
        local saved = value[field]
        local waiting = pending[field]
        if saved==false then
            if waiting==nil then
                value[field]=nil
                changed=true
            elseif type(waiting)~="string" or waiting=="" then
                FL_AppendQuarantine(scope,"FL_PendingShortcuts_Quarantine",{field=field,data=waiting})
                pending[field]=nil
                value[field]=nil
                pendingChanged=true
                changed=true
            elseif FL718_IsShortcutUsable(waiting) then
                value[field]=waiting
                pending[field]=nil
                changed=true
                pendingChanged=true
                FL718_RestoredShortcutCount=FL718_RestoredShortcutCount+1
            end
        elseif saved==nil and waiting~=nil then
            -- A pending placeholder is saved as false. nil therefore means the
            -- player deliberately cleared/replaced the slot during the last run.
            pending[field]=nil
            pendingChanged=true
        elseif saved~=nil then
            if type(saved)~="string" or saved=="" then
                quarantine[field]=saved
                value[field]=nil
                changed=true
                FL718_BadTotalsCount=FL718_BadTotalsCount+1
                badThisLoad=badThisLoad+1
                if waiting~=nil then
                    pending[field]=nil
                    pendingChanged=true
                end
            elseif FL718_IsShortcutUsable(saved) then
                if waiting~=nil then
                    pending[field]=nil
                    pendingChanged=true
                end
            else
                pending[field]=saved
                pendingChanged=true
                quarantine[field]=saved
                value[field]=false
                changed=true
                FL718_BadTotalsCount=FL718_BadTotalsCount+1
                badThisLoad=badThisLoad+1
            end
        end
    end
    if pendingChanged then FL718_Save(scope,"FL_PendingShortcuts",pending) end

    local removeIds = {}
    for id,n in pairs(value) do
        if type(id)=="string" and #id==5 then
            local count = FL_ToNumber(n)
            if count~=nil and count>0 then
                if n~=count then changed=true end
                value[id]=count
            else
                table.insert(removeIds,id)
                changed=true
                if count==nil or count<0 then
                    quarantine[id]=n
                    FL718_BadTotalsCount=FL718_BadTotalsCount+1
                    badThisLoad=badThisLoad+1
                end
            end
        end
    end
    for _,id in ipairs(removeIds) do value[id]=nil end

    if badThisLoad>0 then
        FL_AppendQuarantine(scope,"FL_TotalsPreload_Quarantine",quarantine)
    end
    if changed then FL718_Save(scope,"FL_Totals",value) end
    return value
end

local function FL718_SanitizeLocs(scope,value)
    if value==nil then return nil end
    if type(value)~="table" then
        FL718_BadLocCount=FL718_BadLocCount+1
        FL_AppendQuarantine(scope,"FL_LocsPreload_Quarantine",{{key="__root",data=value}})
        FL718_Save(scope,"FL_Locs",{})
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
            t.r,t.y,t.x=r,y,x

            local removeIds={}
            for id,n in pairs(t) do
                if type(id)=="string" and #id==5 then
                    local count=FL_ToNumber(n)
                    if count~=nil and count>0 then
                        if n~=count then changed=true end
                        t[id]=count
                    else
                        table.insert(removeIds,id)
                        changed=true
                        if count==nil or count<0 then
                            table.insert(badCounters,{location=tostring(loc),id=id,data=n})
                            FL718_BadLocCounterCount=FL718_BadLocCounterCount+1
                        end
                    end
                end
            end
            for _,id in ipairs(removeIds) do t[id]=nil end
        else
            table.insert(remove,loc)
            table.insert(bad,{key=tostring(loc),data=t})
            FL718_BadLocCount=FL718_BadLocCount+1
            changed=true
        end
    end

    for _,loc in ipairs(remove) do value[loc]=nil end
    if #bad>0 then FL_AppendQuarantine(scope,"FL_LocsPreload_Quarantine",bad) end
    if #badCounters>0 then FL_AppendQuarantine(scope,"FL_LocsCounterPreload_Quarantine",badCounters) end
    if changed then FL718_Save(scope,"FL_Locs",value) end
    return value
end

local function FL718_SanitizeLoaded(scope,key,value)
    if key=="FL_Options" then
        return FL718_SanitizeOptions(scope,value)
    elseif key=="FL_Totals" then
        return FL718_SanitizeTotals(scope,value)
    elseif key=="FL_Locs" then
        return FL718_SanitizeLocs(scope,value)
    end
    return value
end

local FL718_QuarantineKeys = {
    FL_Locs_Quarantine=true,
    FL_LocsCounter_Quarantine=true,
    FL_TotalsCounter_Quarantine=true,
    FL_Profs_Quarantine=true
}

-- FL_Loader still contains older fallback quarantine writes. While it imports,
-- make those writes cumulative too. Normal saves pass through untouched.
Turbine.PluginData.Save = function(scope,key,value,callback)
    if FL718_QuarantineKeys[key] then
        return FL_AppendQuarantine(scope,key,value,callback)
    end
    return FL718_RawSave(scope,key,value,callback)
end

Turbine.PluginData.Load = function(scope,key,callback)
    local wrappedCallback
    if callback then
        wrappedCallback=function(data)
            callback(FL718_SanitizeLoaded(scope,key,data))
        end
    end

    local value=FL718_RawLoad(scope,key,wrappedCallback)
    if value==nil and callback then return nil end
    return FL718_SanitizeLoaded(scope,key,value)
end

local FL718_OK,FL718_Error=pcall(function()
    import "Dusk.FishingLog.FL_Loader"
end)
Turbine.PluginData.Load=FL718_RawLoad
Turbine.PluginData.Save=FL718_RawSave
if not FL718_OK then error(FL718_Error) end

if FL718_BadTotalsCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Donnée(s) critique(s) de FL_Totals isolée(s) avant chargement : " or "Critical FL_Totals value(s) isolated before load: ")..FL718_BadTotalsCount)
end
if FL718_BadLocCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Lieu(x) invalide(s) retiré(s) et sauvegardé(s) avant chargement : " or "Invalid location(s) removed and saved before load: ")..FL718_BadLocCount)
end
if FL718_BadLocCounterCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and "Compteur(s) de lieu illisible(s) retiré(s) avant chargement : " or "Unreadable location counter(s) removed before load: ")..FL718_BadLocCounterCount)
end
if FL718_RestoredShortcutCount>0 and FL_Print then
    FL_Print((FL_Lang=="FR" and "Raccourci(s) d’équipement en attente restauré(s) : " or "Pending equipment shortcut(s) restored: ")..FL718_RestoredShortcutCount)
end
