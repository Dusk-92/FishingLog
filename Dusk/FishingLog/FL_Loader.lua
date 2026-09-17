-- FishingLog FR7.10 runtime hardening layer.
-- Keeps FL_Main intact while fixing reload safety and old-save edge cases.

import "Dusk.Common"

-- Validate FL_Options before FL_Main reads it. Keep the automatic FR probe
-- disabled at startup; /fl fr still forces a manual retry when wanted.
local FL710_RawLoad = Turbine.PluginData.Load
Turbine.PluginData.Load = function(scope,key,callback)
    local value = FL710_RawLoad(scope,key,callback)
    if key=="FL_Options" then
        if type(value)~="table" then value={} end
        value.frProbeVersion = 3
    end
    return value
end

-- Capture the chain that existed before FishingLog. FL_Main installs its normal
-- handler on top of this chain. Always restore PluginData.Load after the import.
local FL710_PreviousChat = Turbine.Chat.Received
local FL710_LoadOK,FL710_LoadError = pcall(function()
    import "Dusk.FishingLog.FL_Main"
end)
Turbine.PluginData.Load = FL710_RawLoad
if not FL710_LoadOK then error(FL710_LoadError) end

local FL710_MainChat = Turbine.Chat.Received

-- Generation gate: an old FishingLog wrapper may remain buried under another
-- plugin after an unload/reload. A stale generation forwards directly to the
-- pre-Fishing chain, bypassing its old FishingLog handler, so catches cannot be
-- counted twice and other plugins underneath still receive the event.
FL_ChatGeneration = (FL_ChatGeneration or 0)+1
local FL710_Generation = FL_ChatGeneration

local function FL710_ChatHandler(sender,args)
    if FL710_Generation~=FL_ChatGeneration then
        if FL710_PreviousChat then return FL710_PreviousChat(sender,args) end
        return
    end
    if FL710_MainChat then return FL710_MainChat(sender,args) end
end

FL_PreviousChatHandler = FL710_PreviousChat
FL_ChatHandler = FL710_ChatHandler
Turbine.Chat.Received = FL710_ChatHandler

-- Normalize the structural fields of saved locations so old/corrupt entries
-- cannot crash /fll list or the nearest-location search. Unusable records are
-- quarantined in a separate PluginData key instead of being silently lost.
local function FL710_ToNumber(v)
    if type(v)=="number" then return v end
    if type(v)=="string" then
        return tonumber((v:gsub(",",".")))
    end
    return nil
end

local FL710_BadLocs = {}
local FL710_BadLocCount = 0
if type(Locs)~="table" then Locs={} end
for loc,t in pairs(Locs) do
    local valid = type(loc)=="string" and type(t)=="table"
    local r,y,x
    if valid then
        r,y,x = FL710_ToNumber(t.r),FL710_ToNumber(t.y),FL710_ToNumber(t.x)
        valid = r~=nil and y~=nil and x~=nil
    end
    if valid then
        t.r,t.y,t.x = r,y,x
        t.a = tostring(t.a or "")
        if FL710_ToNumber(t.n) then
            t.n = FL710_ToNumber(t.n)
        else
            local total=0
            for id,n in pairs(t) do
                if type(id)=="string" and #id==5 and ID[id] then
                    total = total + (FL710_ToNumber(n) or 0)
                end
            end
            t.n = total
        end
    else
        FL710_BadLocs[loc] = t
        FL710_BadLocCount = FL710_BadLocCount+1
    end
end
for loc in pairs(FL710_BadLocs) do Locs[loc]=nil end
if FL710_BadLocCount>0 then
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs_Quarantine",FL710_BadLocs)
    printe((FL_Lang=="FR" and "Ancien(s) lieu(x) invalide(s) ignoré(s) : " or "Invalid old fishing location(s) ignored: ")..FL710_BadLocCount)
end

-- Revalidate a rod restored from an old save. Do not clear it if LOTRO cannot
-- resolve the item yet; only reject a resolved item whose category is wrong.
if Totals and Totals.rod and FL_window and FL_window.rod then
    local shortcut = FL_window.rod:GetShortcut()
    local item = shortcut and shortcut:GetItem()
    local info = item and item:GetItemInfo()
    if info and info:GetCategory()~=FishingPole then
        Totals.rod = nil
        FL_window.rod:SetShortcut(Turbine.UI.Lotro.Shortcut())
        FL_window.rod:SetBackground("Dusk/FishingLog/Rod.tga")
        printe(FL_Lang=="FR" and "L’ancienne canne enregistrée n’était pas valide et a été retirée." or "The saved fishing rod was invalid and has been cleared.")
    end
end

-- Safe list printer: stale five-character IDs from old saves are displayed as
-- plain IDs instead of dereferencing ID[id] and throwing an error.
local FL710_xlink = "<Examine:IIDDID:0x0000000000000000:0x700%s>[%s]<\\Examine>"
local function FL710_PrintList(list)
    if type(list)~="table" then list={} end
    local entries,total = {},0
    for id,n in pairs(list) do
        local count = FL710_ToNumber(n)
        if type(id)=="string" and #id==5 and count then
            local data = ID[id]
            local label = data and (data.ln or data.n) or id
            table.insert(entries,{id=id,n=count,label=label,known=data~=nil})
        end
    end
    table.sort(entries,function(a,b)
        if a.label==b.label then return a.id<b.id end
        return a.label<b.label
    end)
    for _,e in ipairs(entries) do
        if e.known then
            print(string.format(FL710_xlink,e.id,e.label)..": "..e.n)
        else
            print((FL_Lang=="FR" and "ID inconnu " or "Unknown ID ")..e.id..": "..e.n)
        end
        total=total+e.n
    end
    print((FL_Lang=="FR" and "Nombre total de prises : " or "Total catch count: ")..total)
end

-- Intercept only the list commands that used the unsafe legacy print_list().
-- All location creation/detection logic remains in FL_Main unchanged.
local FL710_OldExecute = FL_Command.Execute
function FL_Command:Execute(cmd,args)
    args = args or ""
    if cmd=="fll" and args=="list" then
        printh(FL_Lang=="FR" and "Lieux de pêche enregistrés :" or "Recorded fishing locations:")
        local names={}
        for loc,t in pairs(Locs) do
            if type(loc)=="string" and type(t)=="table" then table.insert(names,loc) end
        end
        table.sort(names)
        for _,loc in ipairs(names) do
            local t=Locs[loc]
            local region = RegN[tonumber(t.r)] or tostring(t.r or "?")
            print(region.."("..tostring(t.a or "").."): "..loc.." = "..tostring(FL710_ToNumber(t.n) or 0))
        end
        return
    end
    if cmd=="fll" and args=="last" then
        local key=FL_CurrentLocationText
        local t=key and Locs[key]
        if t then
            printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..key)
            FL710_PrintList(t)
        else
            printe(FL_Lang=="FR" and "Aucun lieu sélectionné." or "No location selected yet")
        end
        return
    end
    if cmd=="fll" and Locs[args] then
        printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..args)
        FL710_PrintList(Locs[args])
        return
    end
    if args=="catch" then
        printh(FL_Lang=="FR" and "Historique des prises :" or "Fishing catch record:")
        FL710_PrintList(Totals)
        return
    end
    return FL710_OldExecute(self,cmd,args)
end

-- Invalidate this generation even if another plugin currently wraps us. Save
-- the current main-window position before FL_Main persists FL_Options.
local FL710_OldUnload = Plugins.FishingLog.Unload
Plugins.FishingLog.Unload = function(sender,args)
    if FL710_Generation==FL_ChatGeneration then
        FL_ChatGeneration = FL_ChatGeneration+1
    end
    if Turbine.Chat.Received==FL710_ChatHandler then
        Turbine.Chat.Received = FL710_PreviousChat
    end
    if FL_window and FL_Options then
        local x,y = FL_window:GetPosition()
        FL_Options.pos1 = {x=math.floor(x+0.5),y=math.floor(y+0.5)}
    end
    return FL710_OldUnload(sender,args)
end
