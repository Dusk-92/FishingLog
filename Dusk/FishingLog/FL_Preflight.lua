-- FishingLog FR9.0 release preflight.
-- Validates saved state before FL_Main/FL_Window, keeps localized name caches
-- separated, validates equipment shortcuts without unstable category IDs, and
-- guards legacy runtime paths without adding another loader layer.

import "Turbine.UI.Lotro"
import "Dusk.Common"
import "Dusk.Common.EII_ID"
import "Dusk.FishingLog.FL_Number"

local FL8_NativeLoad = Turbine.PluginData.Load
local FL8_NativeSave = Turbine.PluginData.Save
local FL8_RawLoad = (Dusk.Common and Dusk.Common.PluginDataLoad) or FL8_NativeLoad
local FL8_RawLoadChecked = Dusk.Common and Dusk.Common.PluginDataLoadChecked
local FL8_RawSave = (Dusk.Common and Dusk.Common.PluginDataSave) or FL8_NativeSave
local FL8_LoadFailures = {}
local FL8_Lang =
    Turbine.Shell.IsCommand("aide") and "FR" or
    (Turbine.Shell.IsCommand("zusatzmodule") and "DE" or "EN")
local FL8_NamesKey = "FL_Names_"..FL8_Lang
local FL8_QuarantineLimit = 25

local FL8_BadTotalsCount = 0
local FL8_BadLocCount = 0
local FL8_BadLocCounterCount = 0
local FL8_RestoredShortcutCount = 0
local FL8_ProbeWatcher = nil
local FL8_Active = true
local FL81_NamesReset = false

local function FL8_Load(scope,key,callback)
    if type(FL8_RawLoadChecked)=="function" then
        local value,ok,err=FL8_RawLoadChecked(scope,key,callback)
        if ok==false then FL8_LoadFailures[key]=tostring(err or "load failed") end
        return value
    end
    local ok,value=pcall(FL8_RawLoad,scope,key,callback)
    if not ok then
        FL8_LoadFailures[key]=tostring(value)
        return nil
    end
    return value
end

local function FL8_Save(scope,key,value,callback)
    if FL8_LoadFailures[key] then
        if callback then pcall(callback,false,"load failed earlier in this session") end
        return false
    end
    return FL8_RawSave(scope,key,value,callback)
end

local function FL8_HasEntries(t)
    return type(t)=="table" and next(t)~=nil
end

-- Keep recent recovery snapshots without allowing an unbounded save file.
local function FL8_AppendQuarantine(scope,key,payload,callback)
    local previous = FL8_Load(scope,key)
    local history
    if type(previous)=="table" and previous.__format=="FR9-history" and
       type(previous.entries)=="table" then
        history = previous
    elseif type(previous)=="table" and
           (previous.__format=="FR8-history" or previous.__format=="FR7.18-history") and
           type(previous.entries)=="table" then
        history = {__format="FR9-history",entries=previous.entries}
    else
        history = {__format="FR9-history",entries={}}
        if previous~=nil then
            table.insert(history.entries,{version="legacy",data=previous})
        end
    end

    table.insert(history.entries,{version="FR9.0",data=payload})
    while #history.entries>FL8_QuarantineLimit do
        table.remove(history.entries,1)
    end
    return FL8_Save(scope,key,history,callback)
end

-- FR8.0 could migrate an old language-agnostic FL_Names cache into FR. Reset the
-- FR dynamic cache once, preserve a backup, then let the client probe repopulate
-- only the few names absent from the static French database.
if FL8_Lang=="FR" then
    local cacheVersion=FL8_Load(Turbine.DataScope.Server,"FL_FRNamesCacheVersion")
    if cacheVersion~=1 then
        local oldCache=FL8_Load(Turbine.DataScope.Server,"FL_Names_FR")
        if FL8_HasEntries(oldCache) then
            FL8_AppendQuarantine(
                Turbine.DataScope.Server,"FL_NamesFR_Quarantine",oldCache)
        end
        FL8_Save(Turbine.DataScope.Server,"FL_Names_FR",{})
        FL8_Save(Turbine.DataScope.Server,"FL_FRNamesCacheVersion",1)
        FL81_NamesReset=true
    end
end

local function FL8_ParseDisplayCoords(text)
    if type(text)~="string" then return nil,nil end
    local ys,yd,xs,xd =
        text:match("^%s*([%d%.,]+)%s*([NS])%s+([%d%.,]+)%s*([EWO])%s*$")
    if not ys then return nil,nil end
    local y,x = FL_ToNumber(ys),FL_ToNumber(xs)
    if y==nil or x==nil then return nil,nil end
    if yd=="S" then y=-y end
    if xd=="W" or xd=="O" then x=-x end
    return y,x
end

local function FL8_SanitizeOptions(scope,value)
    local changed=false
    if type(value)~="table" then
        value={}
        changed=true
    end

    local rawScale=value.scale
    local scale=FL_ToNumber(rawScale)
    if scale==nil then scale=1 end
    scale=math.max(0.5,math.min(2,scale))
    if rawScale~=scale then
        value.scale=scale
        changed=true
    end

    if value.pos1~=nil then
        if type(value.pos1)=="table" then
            local x,y=FL_ToNumber(value.pos1.x),FL_ToNumber(value.pos1.y)
            if x~=nil and y~=nil then
                local sw,sh=Turbine.UI.Display.GetWidth(),Turbine.UI.Display.GetHeight()
                local ww=math.max(1,math.floor(340*scale+0.5))
                local wh=math.max(1,math.floor(285*scale+0.5))
                local nx=math.max(0,math.min(x,math.max(0,sw-ww)))
                local ny=math.max(0,math.min(y,math.max(0,sh-wh)))
                if value.pos1.x~=nx or value.pos1.y~=ny then changed=true end
                value.pos1={x=nx,y=ny}
            else
                value.pos1=nil
                changed=true
            end
        else
            value.pos1=nil
            changed=true
        end
    end

    if FL81_NamesReset then
        if value.fr8ProbeVersion~=nil or value.frProbeVersion~=nil then
            changed=true
        end
        value.fr8ProbeVersion=nil
        value.frProbeVersion=nil
    end

    if changed then FL8_Save(scope,"FL_Options",value) end
    return value
end

-- Validate only stable Quickslot invariants: Item type + exact payload.
-- Numeric LOTRO item-category IDs are intentionally not used for equipment.
local function FL8_ValidateShortcut(saved)
    if type(saved)~="string" or saved=="" then return false end

    local ok,accepted=pcall(function()
        local probe=Turbine.UI.Lotro.Quickslot()
        probe:SetSize(1,1)
        probe:SetVisible(false)
        probe:SetShortcut(Turbine.UI.Lotro.Shortcut())

        local shortcut=Turbine.UI.Lotro.Shortcut(
            Turbine.UI.Lotro.ShortcutType.Item,saved)
        probe:SetShortcut(shortcut)

        local restored=probe:GetShortcut()
        return restored and
               restored:GetType()==Turbine.UI.Lotro.ShortcutType.Item and
               restored:GetData()==saved
    end)

    return ok and accepted==true
end

local function FL8_LoadPending(scope)
    local pending=FL8_Load(scope,"FL_PendingShortcuts")
    if pending==nil then return {} end
    if type(pending)=="table" then return pending end
    FL8_AppendQuarantine(scope,"FL_PendingShortcuts_Quarantine",pending)
    FL8_Save(scope,"FL_PendingShortcuts",{})
    return {}
end

local function FL8_SanitizeTotals(scope,value)
    local rootWasMissing=value==nil
    local pending=FL8_LoadPending(scope)
    if rootWasMissing and not FL8_HasEntries(pending) then return nil end

    local changed=false
    local quarantine={}
    local badThisLoad=0

    if type(value)~="table" then
        if value~=nil then
            quarantine.__root=value
            FL8_BadTotalsCount=FL8_BadTotalsCount+1
            badThisLoad=badThisLoad+1
        end
        value={}
        changed=true
    end

    if value.fp~=nil then
        local fp=FL_ToFishingLevel(value.fp)
        if fp~=nil then
            if value.fp~=fp then changed=true end
            value.fp=fp
        else
            quarantine.fp=value.fp
            value.fp=nil
            changed=true
            FL8_BadTotalsCount=FL8_BadTotalsCount+1
            badThisLoad=badThisLoad+1
        end
    end

    -- FR9.0: category-based rod validation was removed in FR8.3, so the old
    -- Shift bypass marker no longer has any meaning. Clean it from old saves.
    if value.rodBypass~=nil then
        value.rodBypass=nil
        changed=true
    end

    local pendingChanged=false
    for _,field in ipairs({"rod","wpn","shl"}) do
        local saved=value[field]
        local waiting=pending[field]

        if rootWasMissing and saved==nil and waiting~=nil then
            value[field]=false
            saved=false
            changed=true
        end

        if saved==false then
            if waiting==nil then
                value[field]=nil
                changed=true
            elseif type(waiting)~="string" or waiting=="" then
                FL8_AppendQuarantine(
                    scope,"FL_PendingShortcuts_Quarantine",
                    {field=field,data=waiting})
                pending[field]=nil
                value[field]=nil
                pendingChanged=true
                changed=true
            elseif FL8_ValidateShortcut(waiting) then
                value[field]=waiting
                pending[field]=nil
                changed=true
                pendingChanged=true
                FL8_RestoredShortcutCount=FL8_RestoredShortcutCount+1
            else
                value[field]=false
            end
        elseif saved==nil and waiting~=nil then
            pending[field]=nil
            pendingChanged=true
        elseif saved~=nil then
            if type(saved)~="string" or saved=="" then
                quarantine[field]=saved
                value[field]=nil
                changed=true
                FL8_BadTotalsCount=FL8_BadTotalsCount+1
                badThisLoad=badThisLoad+1
                if waiting~=nil then
                    pending[field]=nil
                    pendingChanged=true
                end
            elseif FL8_ValidateShortcut(saved) then
                if waiting~=nil then
                    pending[field]=nil
                    pendingChanged=true
                end
            else
                pending[field]=saved
                value[field]=false
                pendingChanged=true
                changed=true
            end
        end
    end
    if pendingChanged then FL8_Save(scope,"FL_PendingShortcuts",pending) end

    local removeIds={}
    for id,n in pairs(value) do
        if type(id)=="string" and #id==5 then
            local count=FL_ToNonNegativeInteger(n)
            if count~=nil and count>0 then
                if n~=count then changed=true end
                value[id]=count
            else
                table.insert(removeIds,id)
                changed=true
                if count==nil then
                    quarantine[id]=n
                    FL8_BadTotalsCount=FL8_BadTotalsCount+1
                    badThisLoad=badThisLoad+1
                end
            end
        end
    end
    for _,id in ipairs(removeIds) do value[id]=nil end

    if badThisLoad>0 then
        FL8_AppendQuarantine(scope,"FL_TotalsPreload_Quarantine",quarantine)
    end
    if changed then FL8_Save(scope,"FL_Totals",value) end
    return value
end

local function FL8_SanitizeLocs(scope,value)
    if value==nil then return nil end
    if type(value)~="table" then
        FL8_BadLocCount=FL8_BadLocCount+1
        FL8_AppendQuarantine(
            scope,"FL_LocsPreload_Quarantine",
            {{key="__root",data=value}})
        FL8_Save(scope,"FL_Locs",{})
        return {}
    end

    local bad,badCounters,remove={},{},{}
    local changed=false

    for loc,t in pairs(value) do
        local valid=type(loc)=="string" and type(t)=="table"
        local r,y,x
        if valid then
            r,y,x=FL_ToNonNegativeInteger(t.r),FL_ToNumber(t.y),FL_ToNumber(t.x)
            valid=r~=nil and r>=1 and r<=5 and y~=nil and x~=nil
        end

        if valid then
            local keyRegion,display=loc:match("^(%d+);(.+)$")
            local kr=FL_ToNonNegativeInteger(keyRegion)
            if kr and kr>=1 and kr<=5 then
                if r~=kr then r=kr changed=true end
                local ky,kx=FL8_ParseDisplayCoords(display)
                if ky~=nil and kx~=nil then
                    if y~=ky or x~=kx then changed=true end
                    y,x=ky,kx
                end
            end

            if t.r~=r or t.y~=y or t.x~=x then changed=true end
            t.r,t.y,t.x=r,y,x
            local area=tostring(t.a or "")
            if t.a~=area then changed=true end
            t.a=area

            local total=0
            local removeIds={}
            for id,n in pairs(t) do
                if type(id)=="string" and #id==5 then
                    local count=FL_ToNonNegativeInteger(n)
                    if count~=nil and count>0 then
                        if n~=count then changed=true end
                        t[id]=count
                        total=total+count
                    else
                        table.insert(removeIds,id)
                        changed=true
                        if count==nil then
                            table.insert(badCounters,{
                                location=tostring(loc),id=id,data=n})
                            FL8_BadLocCounterCount=FL8_BadLocCounterCount+1
                        end
                    end
                end
            end
            for _,id in ipairs(removeIds) do t[id]=nil end
            if t.n~=total then changed=true end
            t.n=total
        else
            table.insert(remove,loc)
            table.insert(bad,{key=tostring(loc),data=t})
            FL8_BadLocCount=FL8_BadLocCount+1
            changed=true
        end
    end

    for _,loc in ipairs(remove) do value[loc]=nil end
    if #bad>0 then
        FL8_AppendQuarantine(scope,"FL_LocsPreload_Quarantine",bad)
    end
    if #badCounters>0 then
        FL8_AppendQuarantine(
            scope,"FL_LocsCounterPreload_Quarantine",badCounters)
    end
    if changed then FL8_Save(scope,"FL_Locs",value) end
    return value
end

local function FL8_SanitizeProfs(scope,value)
    if value==nil then return nil end
    if type(value)~="table" then
        FL8_AppendQuarantine(scope,"FL_ProfsPreload_Quarantine",value)
        FL8_Save(scope,"FL_Profs",{})
        return {}
    end

    local changed=false
    local bad={}
    local remove={}
    for name,v in pairs(value) do
        local fp=FL_ToFishingLevel(v)
        if type(name)=="string" and name~="" and fp~=nil then
            if v~=fp then changed=true end
            value[name]=fp
        else
            bad[type(name)..":"..tostring(name)]=v
            table.insert(remove,name)
            changed=true
        end
    end
    for _,name in ipairs(remove) do value[name]=nil end
    if next(bad) then FL8_AppendQuarantine(scope,"FL_ProfsPreload_Quarantine",bad) end
    if changed then FL8_Save(scope,"FL_Profs",value) end
    return value
end

local function FL8_SanitizeLoaded(scope,key,value)
    if key=="FL_Options" then return FL8_SanitizeOptions(scope,value) end
    if key=="FL_Totals" then return FL8_SanitizeTotals(scope,value) end
    if key=="FL_Locs" then return FL8_SanitizeLocs(scope,value) end
    if key=="FL_Profs" then return FL8_SanitizeProfs(scope,value) end
    return value
end

local FL8_QuarantineKeys={
    FL_Locs_Quarantine=true,
    FL_LocsCounter_Quarantine=true,
    FL_TotalsCounter_Quarantine=true,
    FL_Profs_Quarantine=true
}

local FL8_RawEII=Dusk and Dusk.Common and Dusk.Common.EII_ID
local FL8_SafeEII
if type(FL8_RawEII)=="function" then
    FL8_SafeEII=function(str)
        if not FL8_Active then return FL8_RawEII(str) end
        local ok,a,b,c=pcall(FL8_RawEII,str)
        if ok then return a,b,c end
        return nil
    end
    Dusk.Common.EII_ID=FL8_SafeEII
end

function FL_PluginDataSave(scope,key,value,callback)
    local actualKey=(key=="FL_Names") and FL8_NamesKey or key
    if FL8_QuarantineKeys[key] then
        return FL8_AppendQuarantine(scope,key,value,callback)
    end
    return FL8_Save(scope,actualKey,value,callback)
end

function FL_PluginDataLoad(scope,key,callback)
    local actualKey=(key=="FL_Names") and FL8_NamesKey or key
    local wrappedCallback
    if callback then
        wrappedCallback=function(data)
            callback(FL8_SanitizeLoaded(scope,key,data))
        end
    end
    local value=FL8_Load(scope,actualKey,wrappedCallback)
    if value==nil and callback then return nil end
    return FL8_SanitizeLoaded(scope,key,value)
end

FL_SaveOptions=function()
    if type(FL_Options)~="table" then return false end
    return FL_PluginDataSave(Turbine.DataScope.Server,"FL_Options",FL_Options)
end

local FL8_OK,FL8_Error=pcall(function()
    import "Dusk.FishingLog.FL_Loader"
end)

if not FL8_OK then
    FL8_Active=false
    FL_PluginDataLoad=nil
    FL_PluginDataSave=nil
    FL_SaveOptions=nil
    if FL8_SafeEII and Dusk.Common.EII_ID==FL8_SafeEII then
        Dusk.Common.EII_ID=FL8_RawEII
    end
    error(FL8_Error)
end

if FL_Lang~="FR" and FL_Guide and FL_Guide.Groups and ID then
    for _,group in pairs(FL_Guide.Groups) do
        for _,fish in ipairs(group.fish or {}) do
            local data=ID[fish.id]
            fish.nameFR=(data and (data.ln or data.n)) or fish.id
        end
    end
end

if type(Totals)=="table" then
    FL8_Save(Turbine.DataScope.Character,"FL_Totals",Totals)
end

if FL8_Lang=="FR" and FL_Options and
   (FL81_NamesReset or FL_Options.fr8ProbeVersion~=1) and
   type(FL_AutoLocalize)=="function" then
    FL_Options.frProbeVersion=nil
    local ok=pcall(FL_AutoLocalize,FL81_NamesReset and true or false)
    if ok then
        local frames=0
        FL8_ProbeWatcher=Turbine.UI.Control()
        FL8_ProbeWatcher:SetWantsUpdates(true)
        FL8_ProbeWatcher.Update=function(sender,args)
            frames=frames+1
            if FL_Options and FL_Options.frProbeVersion==3 then
                sender:SetWantsUpdates(false)
                FL8_ProbeWatcher=nil
                FL_Options.fr8ProbeVersion=1
                FL8_Save(Turbine.DataScope.Server,"FL_Options",FL_Options)
            elseif frames>=3600 then
                sender:SetWantsUpdates(false)
                FL8_ProbeWatcher=nil
            end
        end
    end
end

local FL8_OldUnload=Plugins.FishingLog.Unload
Plugins.FishingLog.Unload=function(sender,args)
    if FL8_ProbeWatcher then
        FL8_ProbeWatcher:SetWantsUpdates(false)
        FL8_ProbeWatcher=nil
    end

    local ok,result=pcall(FL8_OldUnload,sender,args)
    FL8_Active=false

    if FL8_SafeEII and Dusk.Common.EII_ID==FL8_SafeEII then
        Dusk.Common.EII_ID=FL8_RawEII
    end
    FL_PluginDataLoad=nil
    FL_PluginDataSave=nil
    FL_SaveOptions=nil

    if not ok then error(result) end
    return result
end

if FL8_BadTotalsCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and
        "Donnée(s) critique(s) de FL_Totals isolée(s) avant chargement : " or
        "Critical FL_Totals value(s) isolated before load: ")..
        FL8_BadTotalsCount)
end
if FL8_BadLocCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and
        "Lieu(x) invalide(s) retiré(s) et sauvegardé(s) avant chargement : " or
        "Invalid location(s) removed and saved before load: ")..
        FL8_BadLocCount)
end
if FL8_BadLocCounterCount>0 and FL_PrintE then
    FL_PrintE((FL_Lang=="FR" and
        "Compteur(s) de lieu invalide(s) retiré(s) avant chargement : " or
        "Invalid location counter(s) removed before load: ")..
        FL8_BadLocCounterCount)
end
if FL8_RestoredShortcutCount>0 and FL_Print then
    FL_Print((FL_Lang=="FR" and
        "Raccourci(s) d’équipement en attente restauré(s) : " or
        "Pending equipment shortcut(s) restored: ")..
        FL8_RestoredShortcutCount)
end
