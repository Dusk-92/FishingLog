-- FishingLog FR7.12 runtime hardening layer.
-- Keeps FL_Main intact while fixing reload safety, old-save edge cases,
-- location-key collisions, deterministic spot selection and crash-loss risk.

import "Dusk.Common"

-- Validate FL_Options before FL_Main reads it. Keep the automatic FR probe
-- disabled at startup; /fl fr still forces a manual retry when wanted.
local FL711_RawLoad = Turbine.PluginData.Load
Turbine.PluginData.Load = function(scope,key,callback)
    local value = FL711_RawLoad(scope,key,callback)
    if key=="FL_Options" then
        if type(value)~="table" then value={} end
        value.frProbeVersion = 3
        if value.pos1~=nil then
            if type(value.pos1)=="table" then
                local x,y = tonumber(value.pos1.x),tonumber(value.pos1.y)
                if x and y then value.pos1={x=x,y=y} else value.pos1=nil end
            else
                value.pos1=nil
            end
        end
    end
    return value
end

-- Capture the chain that existed before FishingLog. FL_Main installs its normal
-- handler on top of this chain. Always restore PluginData.Load after the import.
local FL711_PreviousChat = Turbine.Chat.Received
local FL711_LoadOK,FL711_LoadError = pcall(function()
    import "Dusk.FishingLog.FL_Main"
end)
Turbine.PluginData.Load = FL711_RawLoad
if not FL711_LoadOK then error(FL711_LoadError) end

-- FL_Main keeps short local aliases for compatibility but exposes only prefixed
-- output helpers to the shared Dusk apartment.
local print,printh,printe = FL_Print,FL_PrintH,FL_PrintE
local FL711_MainChat = Turbine.Chat.Received

-- Keep a restored window on-screen after resolution / monitor-layout changes.
local function FL711_ClampMainWindow()
    if not FL_window then return end
    local sw,sh = Turbine.UI.Display.GetWidth(),Turbine.UI.Display.GetHeight()
    local ww,wh = FL_window:GetWidth(),FL_window:GetHeight()
    local x,y = FL_window:GetPosition()
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    local nx = math.max(0,math.min(x,math.max(0,sw-ww)))
    local ny = math.max(0,math.min(y,math.max(0,sh-wh)))
    if nx~=x or ny~=y then FL_window:SetPosition(nx,ny) end
    if FL_Options then FL_Options.pos1={x=math.floor(nx+0.5),y=math.floor(ny+0.5)} end
end
FL711_ClampMainWindow()

local function FL711_ToNumber(v)
    if type(v)=="number" then return v end
    if type(v)=="string" then return tonumber((v:gsub(",","."))) end
    return nil
end

local function FL711_DisplayLocKey(key)
    key=tostring(key or "")
    return key:match("^%d+;(.+)$") or key
end

local function FL711_StorageLocKey(r,display)
    return tostring(r)..";"..tostring(display or "")
end

local function FL711_Distance(dy,dx)
    return math.sqrt(dy*dy+dx*dx)
end

local function FL711_LocValue(str,neg)
    if type(str)~="string" then return nil end
    local clean=str:gsub("%s",""):gsub(",",".")
    local dir=clean:sub(-1)
    local nbr=tonumber(clean:sub(1,-2))
    if not nbr then return nil end
    if dir==neg or (neg=="W" and dir=="O") then nbr=-nbr end
    return nbr
end

-- Normalize the structural fields of saved locations so old/corrupt entries
-- cannot crash list/search operations. Unusable records are quarantined.
local FL711_BadLocs = {}
local FL711_BadLocCount = 0
if type(Locs)~="table" then Locs={} end
for loc,t in pairs(Locs) do
    local valid = type(loc)=="string" and type(t)=="table"
    local r,y,x
    if valid then
        r,y,x = FL711_ToNumber(t.r),FL711_ToNumber(t.y),FL711_ToNumber(t.x)
        valid = r~=nil and y~=nil and x~=nil
    end
    if valid then
        t.r,t.y,t.x = r,y,x
        t.a = tostring(t.a or "")
        if FL711_ToNumber(t.n) then
            t.n = FL711_ToNumber(t.n)
        else
            local total=0
            for id,n in pairs(t) do
                if type(id)=="string" and #id==5 and ID[id] then
                    total = total + (FL711_ToNumber(n) or 0)
                end
            end
            t.n = total
        end
    else
        FL711_BadLocs[loc] = t
        FL711_BadLocCount = FL711_BadLocCount+1
    end
end
for loc in pairs(FL711_BadLocs) do Locs[loc]=nil end
if FL711_BadLocCount>0 then
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs_Quarantine",FL711_BadLocs)
    printe((FL_Lang=="FR" and "Ancien(s) lieu(x) invalide(s) ignoré(s) : " or "Invalid old fishing location(s) ignored: ")..FL711_BadLocCount)
end

-- Migrate legacy coordinate-only keys to region-qualified internal keys.
-- Display remains unchanged; this prevents identical coordinates in two regions
-- from overwriting one another.
local FL711_Migrations={}
for loc,t in pairs(Locs) do
    if type(loc)=="string" and type(t)=="table" and not loc:match("^%d+;") then
        local newKey=FL711_StorageLocKey(t.r,loc)
        table.insert(FL711_Migrations,{old=loc,new=newKey,data=t})
    end
end
local FL711_MigratedCount=0
for _,m in ipairs(FL711_Migrations) do
    if Locs[m.old]==m.data then
        if not Locs[m.new] then
            Locs[m.new]=m.data
        else
            local dst=Locs[m.new]
            for id,n in pairs(m.data) do
                if type(id)=="string" and #id==5 then
                    dst[id]=(FL711_ToNumber(dst[id]) or 0)+(FL711_ToNumber(n) or 0)
                end
            end
            dst.n=(FL711_ToNumber(dst.n) or 0)+(FL711_ToNumber(m.data.n) or 0)
        end
        Locs[m.old]=nil
        FL711_MigratedCount=FL711_MigratedCount+1
    end
end
if FL711_MigratedCount>0 then
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs",Locs)
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

local function FL711_SaveRuntimeData()
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs",Locs)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Profs",Profs)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Names",FL_Names)
    Turbine.PluginData.Save(Turbine.DataScope.Character,"FL_Totals",Totals)
end

-- Generation gate: an old FishingLog wrapper may remain buried under another
-- plugin after an unload/reload. A stale generation forwards directly to the
-- pre-Fishing chain, bypassing its old FishingLog handler.
FL_ChatGeneration = (FL_ChatGeneration or 0)+1
local FL711_Generation = FL_ChatGeneration
local FL711_CatchesSinceSave=0
local FL711_XPat = "<Examine:IIDDID:0x0%x+:0x700(%x+)>%[(.-)%]<\\Examine>"

local function FL711_ChatHandler(sender,args)
    if FL711_Generation~=FL_ChatGeneration then
        if FL711_PreviousChat then return FL711_PreviousChat(sender,args) end
        return
    end

    local result
    if FL711_MainChat then result=FL711_MainChat(sender,args) end

    -- Save every 10 recognised catches. This keeps disk writes light while
    -- limiting loss if LOTRO crashes before the plugin unloads normally.
    if args and args.ChatType==Turbine.ChatType.SelfLoot and type(args.Message)=="string" then
        local id=args.Message:match(FL711_XPat)
        if not id and Dusk and Dusk.Common and Dusk.Common.EII_ID then
            id=Dusk.Common.EII_ID(args.Message)
        end
        if id and ID[id] then
            FL711_CatchesSinceSave=FL711_CatchesSinceSave+1
            if FL711_CatchesSinceSave>=10 then
                FL711_SaveRuntimeData()
                FL711_CatchesSinceSave=0
            end
        end
    end

    -- Proficiency changes are rare and important enough to persist immediately.
    -- FL_Main has already updated Totals.fp and Profs before control returns here.
    if args and args.ChatType==Turbine.ChatType.Advancement and type(args.Message)=="string" then
        local low=string.lower(args.Message)
        if (low:find("fishing",1,true) or low:find("pêche",1,true) or
            low:find("peche",1,true) or low:find("angeln",1,true)) and
            args.Message:match("(%d+)") then
            FL711_SaveRuntimeData()
        end
    end
    return result
end

FL_PreviousChatHandler = FL711_PreviousChat
FL_ChatHandler = FL711_ChatHandler
Turbine.Chat.Received = FL711_ChatHandler

-- Safe list printer: stale five-character IDs from old saves are displayed as
-- plain IDs instead of dereferencing ID[id] and throwing an error.
local FL711_xlink = "<Examine:IIDDID:0x0000000000000000:0x700%s>[%s]<\\Examine>"
local function FL711_PrintList(list)
    if type(list)~="table" then list={} end
    local entries,total = {},0
    for id,n in pairs(list) do
        local count = FL711_ToNumber(n)
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
            print(string.format(FL711_xlink,e.id,e.label)..": "..e.n)
        else
            print((FL_Lang=="FR" and "ID inconnu " or "Unknown ID ")..e.id..": "..e.n)
        end
        total=total+e.n
    end
    print((FL_Lang=="FR" and "Nombre total de prises : " or "Total catch count: ")..total)
end

local function FL711_FindLocation(arg)
    if Locs[arg] then return arg,Locs[arg] end
    local requestedRegion,requestedDisplay=arg:match("^%s*([^:]+)%s*:%s*(.+)%s*$")
    local requestedR=requestedRegion and Region[requestedRegion]
    local matches={}
    for key,t in pairs(Locs) do
        if type(key)=="string" and type(t)=="table" then
            local display=FL711_DisplayLocKey(key)
            if display==arg or (requestedR and t.r==requestedR and display==requestedDisplay) then
                table.insert(matches,{key=key,data=t})
            end
        end
    end
    if #matches==1 then return matches[1].key,matches[1].data end
    if #matches>1 then
        printe(FL_Lang=="FR" and "Plusieurs lieux portent ces coordonnées ; utilise « Région: coordonnées »." or "Several locations use these coordinates; use 'Region: coordinates'.")
    end
    return nil,nil
end

local FL711_Zloc = "^%s*(.-)%s*:%s*(.-)%s*:%s*([%d%.,]+%s*[NS])%s*,%s*([%d%.,]+%s*[EWO])%s*$"
local FL711_OldExecute = FL_Command.Execute
function FL_Command:Execute(cmd,args)
    args = args or ""

    -- Deterministic location selection + collision-proof internal key.
    if cmd=="fll" then
        local reg,a,y,x=args:match(FL711_Zloc)
        if y then
            local r=Region[reg]
            local y1,x1=FL711_LocValue(y,"S"),FL711_LocValue(x,"W")
            if r and y1 and x1 then
                local bestKey,bestDist=nil,nil
                for key,t in pairs(Locs) do
                    if type(t)=="table" and FL711_ToNumber(t.r)==r then
                        local ty,tx=FL711_ToNumber(t.y),FL711_ToNumber(t.x)
                        if ty and tx then
                            local d=FL711_Distance(y1-ty,x1-tx)
                            if d<1 and (not bestDist or d<bestDist) then bestKey,bestDist=key,d end
                        end
                    end
                end

                -- FL_Main stops at the first location inside radius 1. Hide any
                -- competing candidates for this call so it necessarily picks
                -- the true nearest one.
                local hidden={}
                local originalY,originalX
                if bestKey then
                    originalY=FL711_ToNumber(Locs[bestKey] and Locs[bestKey].y)
                    originalX=FL711_ToNumber(Locs[bestKey] and Locs[bestKey].x)
                    for key,t in pairs(Locs) do
                        if key~=bestKey and type(t)=="table" and FL711_ToNumber(t.r)==r then
                            local ty,tx=FL711_ToNumber(t.y),FL711_ToNumber(t.x)
                            if ty and tx and FL711_Distance(y1-ty,x1-tx)<1 then
                                hidden[key]=t
                            end
                        end
                    end
                    for key in pairs(hidden) do Locs[key]=nil end
                end

                local ok,res=pcall(FL711_OldExecute,self,cmd,args)
                for key,t in pairs(hidden) do Locs[key]=t end
                if not ok then error(res) end

                -- FL_Main refreshes y/x to the player's current click position.
                -- Keep an existing spot anchored to the coordinates it was created at.
                if bestKey and Locs[bestKey] then
                    if originalY then Locs[bestKey].y=originalY end
                    if originalX then Locs[bestKey].x=originalX end
                end

                local selectedKey=bestKey
                if not selectedKey then
                    local display=y.." "..x
                    local raw=Locs[display]
                    if raw then
                        selectedKey=FL711_StorageLocKey(r,display)
                        if not Locs[selectedKey] then Locs[selectedKey]=raw end
                        Locs[display]=nil
                    end
                end
                if selectedKey and Locs[selectedKey] then
                    FL_CurrentLocationText=selectedKey
                    if FL_window and FL_window.SetCurrentLocation then
                        FL_window:SetCurrentLocation(a,FL711_DisplayLocKey(selectedKey))
                    end
                    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs",Locs)
                end
                return res
            end
        end
    end

    -- Intercept list commands that used unsafe legacy print_list() and hide
    -- internal region prefixes from the player.
    if cmd=="fll" and args=="list" then
        printh(FL_Lang=="FR" and "Lieux de pêche enregistrés :" or "Recorded fishing locations:")
        local entries={}
        for key,t in pairs(Locs) do
            if type(key)=="string" and type(t)=="table" then
                table.insert(entries,{key=key,data=t,display=FL711_DisplayLocKey(key)})
            end
        end
        table.sort(entries,function(a,b)
            local ar,br=FL711_ToNumber(a.data.r) or 999,FL711_ToNumber(b.data.r) or 999
            if ar~=br then return ar<br end
            if a.display~=b.display then return a.display<b.display end
            return a.key<b.key
        end)
        for _,e in ipairs(entries) do
            local t=e.data
            local region=RegN[FL711_ToNumber(t.r)] or tostring(t.r or "?")
            print(region.."("..tostring(t.a or "").."): "..e.display.." = "..tostring(FL711_ToNumber(t.n) or 0))
        end
        return
    end
    if cmd=="fll" and args=="last" then
        local key=FL_CurrentLocationText
        local t=key and Locs[key]
        if t then
            printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..FL711_DisplayLocKey(key))
            FL711_PrintList(t)
        else
            printe(FL_Lang=="FR" and "Aucun lieu sélectionné." or "No location selected yet")
        end
        return
    end
    if cmd=="fll" and args~="" then
        local key,t=FL711_FindLocation(args)
        if t then
            printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..FL711_DisplayLocKey(key))
            FL711_PrintList(t)
            return
        end
    end
    if args=="catch" then
        printh(FL_Lang=="FR" and "Historique des prises :" or "Fishing catch record:")
        FL711_PrintList(Totals)
        return
    end
    return FL711_OldExecute(self,cmd,args)
end

-- Invalidate this generation even if another plugin currently wraps us. Save
-- the current main-window position before FL_Main persists FL_Options.
local FL711_OldUnload = Plugins.FishingLog.Unload
Plugins.FishingLog.Unload = function(sender,args)
    if FL711_Generation==FL_ChatGeneration then
        FL_ChatGeneration = FL_ChatGeneration+1
    end
    if Turbine.Chat.Received==FL711_ChatHandler then
        Turbine.Chat.Received = FL711_PreviousChat
    end
    if FL_window and FL_Options then
        FL711_ClampMainWindow()
        local x,y = FL_window:GetPosition()
        FL_Options.pos1 = {x=math.floor(x+0.5),y=math.floor(y+0.5)}
    end
    FL711_SaveRuntimeData()
    return FL711_OldUnload(sender,args)
end
