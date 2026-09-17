-- Fishing Log by David Down
-- coding: utf-8 '�

import "Turbine.Gameplay"
import "Turbine.UI.Lotro"
import "Dusk.Common.EII_ID"
import "Dusk.FishingLog.FL_Data"
import "Dusk.FishingLog.FL_Number"

-- Detect localized clients. Item IDs are language-independent, so the same
-- fishing database can be used on French/English clients.
if Turbine.Shell.IsCommand("aide") then
    FL_Lang = "FR"
    import "Dusk.FishingLog.FL_FR"
elseif Turbine.Shell.IsCommand("zusatzmodule") then
    FL_Lang = "DE"
else
    FL_Lang = "EN"
end

import "Dusk.FishingLog.FL_Guide"

-- Prefix the public output helpers so FishingLog can safely share the Dusk
-- apartment with BirdingLog and other Dusk plugins. Keep short aliases local
-- to this file so the legacy code below does not leak generic globals.
function FL_Print(text) Turbine.Shell.WriteLine("<rgb=#00FFFF>FL:</rgb> "..tostring(text)) end
function FL_PrintH(text) FL_Print("<rgb=#00FF00>"..text.."</rgb>") end
function FL_PrintE(text) FL_Print("<rgb=#FF6040>"..(FL_Lang=="FR" and "Erreur : " or "Error: ")..text.."</rgb>") end
local print,printh,printe = FL_Print,FL_PrintH,FL_PrintE
local help

import "Dusk.Common.Help"

local locPat = "You are on %a* server %d* at r(%d) lx(%d+) ly(%d+) ox(.-%d+%.?%d*) oy(.-%d+%.?%d*) oz(.-%d+%.?%d*)"
local liPat = "You are on %a* server %d* at r(%d) lx(%d+) ly(%d+) i%d* ox(.-%d+%.?%d*) oy(.-%d+%.?%d*) oz(.-%d+%.?%d*)"
local iPat = "You are on %a* server %d* at r(%d) lx(%d+) ly(%d+) cInside ox(.-%d+%.?%d*) oy(.-%d+%.?%d*) oz(.-%d+%.?%d*)"
local xlink = "<Examine:IIDDID:0x0000000000000000:0x700%s>[%s]<\\Examine>"
local xpat = "<Examine:IIDDID:0x0%x+:0x700(%x+)>%[(.-)%]<\\Examine>"
local fpPat = "Your proficiency in Fishing has increased to (%d+)."
local Zloc = "^%s*(.-)%s*:%s*(.-)%s*:%s*([%d%.,]+%s*[NS])%s*,%s*([%d%.,]+%s*[EWO])%s*$"
local x0,y0 = 1468,1244
local locStr,locTbl
local FL_LastRawCoords
FL_CurrentArea = nil
FL_CurrentRegionName = nil
FL_CurrentLocationText = nil
local FL_NoLocationWarned = false
FL_TrackUnknown = false
FL_TrackHover = false
-- You have acquired: [Minnow].
-- Your proficiency in Fishing has increased to 9.

local function FL_DisplayLocKey(key)
    key=tostring(key or "")
    return key:match("^%d+;(.+)$") or key
end

FL_Options = Turbine.PluginData.Load(Turbine.DataScope.Server,"FL_Options")
if not FL_Options then FL_Options = {} end

-- Cache localized catch names learned directly from LOTRO loot links.
FL_Names = Turbine.PluginData.Load(Turbine.DataScope.Server,"FL_Names")
if type(FL_Names) ~= "table" then FL_Names = {} end
for id,name in pairs(FL_Names) do
    if ID[id] and (not ID[id].ln or ID[id].ln=="") and type(name)=="string" and name~="" then ID[id].ln = name end
end


-- Ask the LOTRO client itself for localized item names from the known item IDs.
-- Processing is spread over several frames to keep loading smooth.
local FL_AutoFRRunner = nil
local FL_AutoFRProbe = nil
local FL_AutoFRBusy = false

local function FL_ProbeLocalizedName(id)
    local ok,name = pcall(function()
        if not FL_AutoFRProbe then
            FL_AutoFRProbe = Turbine.UI.Lotro.Quickslot()
            FL_AutoFRProbe:SetSize(1,1)
            FL_AutoFRProbe:SetVisible(false)
        end
        local data = "0x0000000000000000,0x700"..id
        local shortcut = Turbine.UI.Lotro.Shortcut(Turbine.UI.Lotro.ShortcutType.Item,data)
        FL_AutoFRProbe:SetShortcut(shortcut)
        local resolved = FL_AutoFRProbe:GetShortcut()
        if not resolved then return nil end
        local item = resolved:GetItem()
        if not item then return nil end
        return item:GetName()
    end)
    if ok and type(name)=="string" and name~="" and name~="?" then return name end
    return nil
end

function FL_AutoLocalize(force)
    if FL_Lang~="FR" or FL_AutoFRBusy then return end
    if not force and FL_Options.frProbeVersion==3 then return end

    local queue = {}
    for id,t in pairs(ID) do
        if not t.ln or t.ln=="" then table.insert(queue,id) end
    end
    table.sort(queue)

    local ix,found = 1,0
    FL_AutoFRBusy = true
    FL_AutoFRRunner = Turbine.UI.Control()
    FL_AutoFRRunner:SetWantsUpdates(true)
    FL_AutoFRRunner.Update = function(sender,args)
        for n=1,8 do
            local id = queue[ix]
            if not id then
                sender:SetWantsUpdates(false)
                FL_AutoFRBusy = false
                FL_Options.frProbeVersion = 3
                Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Names",FL_Names)
                Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Options",FL_Options)
                local localized,total = 0,0
                for _,entry in pairs(ID) do
                    total = total + 1
                    if entry.ln and entry.ln ~= "" then localized = localized + 1 end
                end
                if found>0 then
                    print("Localisation FR automatique : "..found.." nouveau(x) nom(s) récupéré(s) depuis LOTRO.")
                end
                print("Base française : "..localized.."/"..total.." prise(s) disposent maintenant d’un nom FR.")
                if localized < total then
                    print((total-localized).." nom(s) restent en anglais ; utilise /fl fr pour retenter le scan.")
                end
                return
            end
            ix = ix+1
            local t = ID[id]
            local name = FL_ProbeLocalizedName(id)
            if name and t and name~=t.n then
                if FL_Names[id]~=name then found=found+1 end
                t.ln = name
                FL_Names[id] = name
            end
        end
    end
end

local FLv = "Fishing Log "..Plugins["FishingLog"]:GetVersion()

Locs = Turbine.PluginData.Load(Turbine.DataScope.Server,"FL_Locs")
if type(Locs) ~= "table" then Locs = {} end
Profs = Turbine.PluginData.Load(Turbine.DataScope.Server,"FL_Profs")
if type(Profs) ~= "table" then Profs = {} end
Totals = Turbine.PluginData.Load(Turbine.DataScope.Character,"FL_Totals")
if type(Totals) ~= "table" then 
	Totals = {} 
	print(FL_Lang=="FR" and "Nouveau carnet de pêche créé." or "Created new fishing record")
end

import "Dusk.FishingLog.FL_Window"
import "Dusk.FishingLog.FL_Icon"

-- First-run FR database enrichment. Use /fl fr to run it again manually.
FL_AutoLocalize(false)

local function pos(n0,ls,os)
    local ln,on = FL_ToNumber(ls),FL_ToNumber(os)
    if not ln or not on then return nil end
	return (ln + math.fmod(on,20)/20 - n0)/10
end

-- Save player name for later use
local player = Turbine.Gameplay.LocalPlayer.GetInstance()
local pname = player:GetName()

local Chat = Turbine.Chat.Received
Turbine.Chat.Received = function (sender,args)
	if Chat then Chat(sender,args) end
	local msg = args.Message
	if not msg then return end

	-- English has a fixed message; localized clients use translated hobby text.
	local fp = msg:match(fpPat)
	if not fp and args.ChatType==Turbine.ChatType.Advancement then
		local low = string.lower(msg)
		if low:find("fishing",1,true) or low:find("pêche",1,true) or
		   low:find("peche",1,true) or low:find("angeln",1,true) then
			fp = msg:match("(%d+)")
		end
	end
	if fp then
		fp = FL_ToNonNegativeInteger(fp) or fp
		Totals.fp = fp
		Profs[pname] = fp
		if FL_window and FL_window.SetFishingLevel then FL_window:SetFishingLevel(fp) end
		return
	end

	if args.ChatType==Turbine.ChatType.SelfLoot then
		-- Do not depend on localized loot prefixes ("You have acquired", etc.).
		-- Examine item IDs stay the same on EN/FR/DE clients.
		local id,name = msg:match(xpat)
		if not id then id,name = Dusk.Common.EII_ID(msg) end
		if not id then return end
		name = name or "?"
		if ID[id] then
			-- Keep the localized item name seen in chat for future displays.
			if name ~= "?" and (not ID[id].ln or ID[id].ln=="") then
                    ID[id].ln = name
                    FL_Names[id] = name
                end
			if not Totals[id] then
				Totals[id] = 0
				print(FL_Lang=="FR" and "Nouveau type de prise trouvé." or "New type of fish found.")
			end
			Totals[id] = Totals[id]+1
			local fishName = ID[id].ln or ID[id].n
			if FL_Lang=="FR" then
				print("Prise : "..fishName..", total="..Totals[id])
			else
				print("Caught a "..fishName..", count="..Totals[id])
			end
			if not locTbl and not FL_NoLocationWarned then
				FL_NoLocationWarned = true
				printe(FL_Lang=="FR" and "Aucun lieu de pêche n’est défini : la prise est enregistrée dans ton total personnel, mais pas pour un lieu. Utilise « Définir lieu »." or "No fishing location is set: the catch was added to your personal total, but not to a location. Use Set Location.")
			end
			if locTbl then
				if not locTbl[id] then locTbl[id] = 0 end
				locTbl[id] = locTbl[id]+1
				locTbl.n = (locTbl.n or 0)+1
			end
		elseif (FL_TrackUnknown or FL_TrackHover) then
			printe((FL_Lang=="FR" and "Inconnu : " or "Unknown: ")..name..", id="..tostring(id))
		end
		return
	end
	if args.ChatType~=Turbine.ChatType.Standard then return end
	local r,lx,ly,ox,oy,oz = msg:match(locPat)
	if not r then r,lx,ly,ox,oy,oz = msg:match(liPat) end
	if not r then r,lx,ly,ox,oy,oz = msg:match(iPat) end
	if not r then return end
	local ew,ns = pos(x0,lx,ox), pos(y0,ly,oy)
	-- Keep raw /loc coordinates separate from FishingLog's selected fishing spot.
	-- The previous code overwrote locStr here, which could desynchronise /fll last.
    if ew and ns then FL_LastRawCoords = string.format("%.1f,%.1f",ns,ew) end
end

local function distance(dy,dx) return math.sqrt(dy*dy+dx*dx) end

local function locV(str,neg)
    local clean = str:gsub("%s","")
    local dir = clean:sub(-1)
    local nbr = FL_ToNumber(clean:sub(1,-2))
    if not nbr then return nil end
    if dir==neg or (neg=="W" and dir=="O") then nbr = -nbr end
    return nbr
end

local function print_list(list)
	local nr,t = 0,{}
	for id,n in pairs(list) do
		if #id==5 then
			table.insert(t,id)
		end
	end
	table.sort(t, function(a,b) return (ID[a].ln or ID[a].n)<(ID[b].ln or ID[b].n) end )
	for i,id in ipairs(t) do
		local t,n = ID[id],list[id]
		local s = string.format(xlink,id,t.ln or t.n)
		print(s..': '..n)
		nr = nr + n
	end
	print((FL_Lang=="FR" and "Nombre total de prises : " or "Total catch count: ")..nr)
	return
end


local function FL_ItemLink(id,label)
    local t = ID[id]
    label = label or (t and (t.ln or t.n)) or id
    return string.format(xlink,id,label)
end

local function FL_CurrentAreaName()
    if FL_CurrentArea and FL_CurrentArea~="" then return FL_CurrentArea end
    if locTbl and locTbl.a then return locTbl.a end
    return nil
end

local function FL_PrintRegionGuide()
    local area = FL_CurrentAreaName()
    if not area then
        printe(FL_Lang=="FR" and "Définis d’abord ton lieu de pêche." or "Set your fishing location first.")
        return
    end
    local key,g = FL_Guide.MatchArea(area)
    printh((FL_Lang=="FR" and "Guide de pêche — " or "Fishing guide — ")..area)
    if not g then
        print(FL_Lang=="FR" and "Aucun groupe de poissons de prouesse spécifique n’est référencé pour cette zone dans le guide intégré." or "No specific deed-fish group is referenced for this area in the integrated guide.")
        print(FL_Lang=="FR" and "Les prises ordinaires ne sont pas limitées à une coordonnée précise." or "Ordinary catches are not tied to one exact coordinate.")
        return
    end
    print((FL_Lang=="FR" and "Groupe : " or "Group: ")..(FL_Lang=="FR" and g.titleFR or g.titleEN))
    local fp = FL_ToNumber(Totals.fp)
    local caught = 0
    for _,f in ipairs(g.fish) do
        local n = FL_ToNumber(Totals[f.id] or 0) or 0
        if n>0 then caught=caught+1 end
        local status = n>0 and "[OK] " or "[  ] "
        local req = ""
        if f.level then
            req = (FL_Lang=="FR" and " — pêche " or " — fishing ")..f.level
            if fp then req = req..(fp>=f.level and (FL_Lang=="FR" and " (niveau OK)" or " (level OK)") or (FL_Lang=="FR" and " (niveau insuffisant)" or " (level too low)")) end
        end
        local count = n>0 and ((FL_Lang=="FR" and " — pris x" or " — caught x")..n) or ""
        print(status..FL_ItemLink(f.id,f.nameFR)..req..count)
    end
    print((FL_Lang=="FR" and "Suivi FishingLog : " or "FishingLog tracking: ")..caught.."/"..#g.fish)
    if g.lakeMaster then
        print(FL_Lang=="FR" and "Maître du lac demande aussi de visiter la Ville du Lac ; cette visite n’est pas détectable par FishingLog." or "Lake-master also requires visiting Lake-town; FishingLog cannot detect that visit.")
    end
end

local function FL_PrintDeedSummary()
    printh(FL_Lang=="FR" and "Prouesses de pêche — suivi FishingLog" or "Fishing deeds — FishingLog tracking")
    for _,d in ipairs(FL_Guide.Deeds) do
        local n = FL_Guide.CountCaught(d.ids,Totals)
        local extra = d.key=="lake" and (FL_Lang=="FR" and " + visite Ville du Lac" or " + visit Lake-town") or ""
        print(d.fr.." : "..n.."/"..#d.ids..extra)
    end
    local fp = FL_ToNumber(Totals.fp)
    if fp then
        print((FL_Lang=="FR" and "Maîtrise enregistrée : " or "Recorded proficiency: ")..fp.."/200")
        local nextTitle=nil
        for _,m in ipairs(FL_Guide.SkillMilestones) do if fp<m[1] then nextTitle=m break end end
        if nextTitle then
            print((FL_Lang=="FR" and "Prochain titre : " or "Next title: ")..nextTitle[2].." ("..nextTitle[1]..")")
        end
    end
    print(FL_Lang=="FR" and "Note : ce suivi compte uniquement les prises enregistrées par FishingLog ; il ne lit pas directement l’état des prouesses du jeu." or "Note: this uses catches recorded by FishingLog; it cannot read the game's deed state directly.")
end

local function FL_PrintDeedDetails(key)
    local d = FL_Guide.GetDeed(key)
    if not d then printe(FL_Lang=="FR" and "Prouesse inconnue. Utilise dard, esturgeon, truite, lac ou saumon." or "Unknown deed. Use darter, sturgeon, trout, lake or salmon.") return end
    printh(d.fr)
    for _,id in ipairs(d.ids) do
        local n = FL_ToNumber(Totals[id] or 0) or 0
        local label = FL_Guide.GetFishLabel(id) or (ID[id] and (ID[id].ln or ID[id].n)) or id
        print((n>0 and "[OK] " or "[  ] ")..FL_ItemLink(id,label)..(n>0 and ((FL_Lang=="FR" and " — pris x" or " — caught x")..n) or ""))
    end
end

FL_Command = Turbine.ShellCommand()
function FL_Command:GetShortHelp() return Dusk.Common.Help(help,"??") end
function FL_Command:GetHelp() return Dusk.Common.Help(help,"help") end

printh(FLv..(FL_Lang=="FR" and ", données chargées." or ", data loaded."))

if Totals.fp then
	if not Profs[pname] then Profs[pname] = Totals.fp end
	print((FL_Lang=="FR" and "Dernière maîtrise de pêche enregistrée : " or "Last saved fishing proficiency is ")..Totals.fp)
end

function FL_Command:Execute( cmd,args )
	if Dusk.Common.HelpCmd(cmd,args,help) then return end
    if cmd=="fll" then
		if args=="list" then
			printh(FL_Lang=="FR" and "Lieux de pêche enregistrés :" or "Recorded fishing locations:")
			for loc,t in pairs(Locs) do
				print(RegN[t.r]..'('..t.a..'): '..FL_DisplayLocKey(loc)..' = '..t.n)
			end
			return
		end
		if args=="last" then
			if locStr and locTbl then
				printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..FL_DisplayLocKey(locStr))
				print_list(locTbl)
			else printe(FL_Lang=="FR" and "Aucun lieu sélectionné." or "No location selected yet") end
			return
		end
		local tbl = Locs[args]
		if tbl then
			printh((FL_Lang=="FR" and "Prises à " or "Fish caught at ")..FL_DisplayLocKey(args))
			print_list(tbl)
			return
		end
		local reg,a,y,x = args:match(Zloc)
		if y then
			local r = Region[reg]
			if not r then printe((FL_Lang=="FR" and "Région inconnue : " or "Unknown region: ")..reg) return end
			local y1,x1 = locV(y,'S'), locV(x,'W')
            if not y1 or not x1 then printe(FL_Lang=="FR" and "Coordonnées invalides." or "Invalid coordinates.") return end
			locStr = nil
			for loc,t in pairs(Locs) do
				if t.r==r then
                    local ty,tx=FL_ToNumber(t.y),FL_ToNumber(t.x)
					if ty and tx and distance(y1-ty,x1-tx)<1 then locStr = loc break end
				end
			end
			local isNew = false
			if not locStr then
				locStr = y..' '..x
				Locs[locStr] = {r=r,a=a,y=y1,x=x1,n=0}
				isNew = true
			end
			locTbl = Locs[locStr]
			-- Refresh area name too: old saved spots may have been created before this guide.
			locTbl.r, locTbl.a, locTbl.y, locTbl.x = r, a, y1, x1
			FL_CurrentArea = a
			FL_CurrentRegionName = reg
			FL_CurrentLocationText = locStr
			if FL_window and FL_window.SetCurrentLocation then FL_window:SetCurrentLocation(a,FL_DisplayLocKey(locStr)) end
			local prefix = isNew and (FL_Lang=="FR" and "Nouveau lieu : " or "New location: ") or (FL_Lang=="FR" and "Lieu actif : " or "Active location: ")
			print(prefix..a.." — "..FL_DisplayLocKey(locStr))
			FL_NoLocationWarned = false
		else printe(FL_Lang=="FR" and "Lieu invalide." or "Invalid location.") end
		return
	end
    if cmd=="flq" then
		if args=="" then
			printh(FL_Lang=="FR" and "Quêtes de pêche :" or "fishing quests:")
			for ix,t in ipairs(Quest) do
				print('#'..ix..(FL_Lang=="FR" and ', niv.=' or ', lvl=')..t.l..': '..(FL_Lang=="FR" and FL_QuestTitle(t) or t.t))
			end
			return
		end
		local ix = tonumber(args)
		if not ix then printe((FL_Lang=="FR" and "Numéro de quête invalide : " or "Invalid quest #, ")..args) return end
		local t = Quest[ix]
		if not t then printe((FL_Lang=="FR" and "Quête introuvable : " or "No such quest #, ")..args) return end
		local s = t.c and string.format(FL_Lang=="FR" and ", récompense : %.2f pièces d’argent" or ", Reward: %.2fs",t.c/100) or ''
		print((FL_Lang=="FR" and "Quête n°" or "Quest #")..args..(FL_Lang=="FR" and " niv.=" or " Lvl=")..t.l..(FL_Lang=="FR" and ", titre : " or ", Title: ")..(FL_Lang=="FR" and FL_QuestTitle(t) or t.t)..s)
		print(FL_Lang=="FR" and ("Départ : "..t.n.." @"..t.loc.." près de "..FL_QuestPlace(t).." dans "..FL_QuestRegion(t)) or ("Start with "..t.n..' @'..t.loc.." near "..t.s.." in "..t.rn))
		if t.nt then print((FL_Lang=="FR" and "Note : " or "Note: ")..(FL_Lang=="FR" and FL_QuestNote(t) or t.nt)) end
		if t.d then print(FL_Lang=="FR" and "Cette quête peut être répétée chaque jour." or "This quest can be repeated daily.") end
		return
	end
    if args=="fr" and FL_Lang=="FR" then
        print("Nouvelle analyse des noms français depuis les données LOTRO…")
        FL_AutoLocalize(true)
        return
    end
	if args=="show" or cmd=="flw" then
		FL_window:SetVisible( true )
		return
	end
    if args=="" then
		local fp = Totals.fp
		if fp then 
			local s,fp = '', FL_ToNumber(fp)
            if not fp then print(FL_Lang=="FR" and "Maîtrise de pêche invalide." or "Invalid fishing proficiency.") return end
			if fp>9 then
				local p = math.floor(fp/50)+1
				if p<5 then s = FL_Lang=="FR" and (", Pêcheur "..Prof[p]) or (", "..Prof[p].." Angler")
				else s = FL_Lang=="FR" and ", Seigneur des rivières" or ", Lord of Streams" end
			end
			print((FL_Lang=="FR" and "Maîtrise de pêche : " or "Fishing proficiency is ")..fp..s)
		else print(FL_Lang=="FR" and "Maîtrise de pêche inconnue." or "Unknown fishing proficiency.") end
		return
	end
    if args=="zone" or args=="region" then
        FL_PrintRegionGuide()
        return
    end
    if args=="deeds" or args=="prouesses" then
        FL_PrintDeedSummary()
        return
    end
    local deedKey = args:match("^deed%s+(.+)$") or args:match("^prouesse%s+(.+)$")
    if deedKey then
        FL_PrintDeedDetails(deedKey)
        return
    end
    if args=="catch" then
		printh(FL_Lang=="FR" and "Historique des prises :" or "Fishing catch record:")
		print_list(Totals)
		return
	end
    if args=="cook" then
		printh(FL_Lang=="FR" and "Poissons pouvant être cuisinés :" or "Fish that can be cooked:")
		local t = {}
		for id,tb in pairs(ID) do
			if tb.c=='C' then
				table.insert(t,id)
			end
		end
		table.sort(t, function(a,b) return (ID[a].ln or ID[a].n)<(ID[b].ln or ID[b].n) end )
		for i,id in ipairs(t) do
			local t = ID[id]
			local s = string.format(xlink,id,t.ln or t.n)
			print(s..': '..Tier[t.t])
		end
		return
	end
	if args=="profs" then
		printh(FL_Lang=="FR" and "Maîtrises de pêche enregistrées :" or "Recorded fishing proficiencies:")
		for pn,v in pairs(Profs) do
			print(pn..'='..v)
		end
		return
	end
    if args=="quest" then
		printh(FL_Lang=="FR" and "Poissons liés à une quête :" or "Fish that are part of a quest:")
		local t = {}
		for id,tb in pairs(ID) do
			if tb.c:find('Q') then
				table.insert(t,id)
			end
		end
		table.sort(t, function(a,b) return (ID[a].ln or ID[a].n)<(ID[b].ln or ID[b].n) end )
		for i,id in ipairs(t) do
			local t = ID[id]
			local s = string.format(xlink,id,t.ln or t.n)
			print(s)
		end
		return
	end
    if args=="track" then
		FL_TrackUnknown = not FL_TrackUnknown
		print(FL_Lang=="FR" and (FL_TrackUnknown and "Suivi activé." or "Suivi désactivé.") or ((FL_TrackUnknown and "En" or "Dis").."abled Tracking."))
		return
	end
    if args=="trophy" then
		printh(FL_Lang=="FR" and "Poissons trophées :" or "Fish that are trophies:")
		local t = {}
		for id,tb in pairs(ID) do
			if tb.c=='T' then
				table.insert(t,id)
			end
		end
		table.sort(t, function(a,b) return (ID[a].ln or ID[a].n)<(ID[b].ln or ID[b].n) end )
		for i,id in ipairs(t) do
			local t = ID[id]
			local s = string.format(xlink,id,t.ln or t.n)
			print(s)
		end
		return
	end
    local id,name = args:match(xpat)
	if not id then id,name = Dusk.Common.EII_ID(args) end
	if id then
		local t = ID[id]
		if t then
			local s = string.format(xlink,id,t.ln or t.n)
			local c = Cat[t.c:sub(1,1)]
			if t.t then c = Tier[t.t]..' '..c end
			local v = ''
			if t.v then v = FL_Lang=="FR" and (", valeur : "..t.v.." cuivre") or (" worth "..t.v.." copper") end
			print(FL_Lang=="FR" and (s.." — "..c..v) or (s.." is a "..c.." item"..v))
			local n = Totals[id]
			if n then print((FL_Lang=="FR" and "Prises enregistrées : " or "Recorded catches: ")..n) end
		else print((FL_Lang=="FR" and "Objet inconnu : " or "Unknown item: ")..args..", id="..id) end
		return
	end
    printe((FL_Lang=="FR" and "Commande inconnue : " or "Unknown command, ")..args)
end

Turbine.Shell.AddCommand( "fl;fll;flq;flw;fl?", FL_Command )

Plugins.FishingLog.Open = function(sender,args)
	FL_window:SetVisible( true )
	FL_window:SetZOrder( 2 )
end

Plugins.FishingLog.Unload = function(sender,args)
    if FL_SaveIconPosition then FL_SaveIconPosition() end
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Options",FL_Options)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Locs",Locs)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Profs",Profs)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Names",FL_Names)
    Turbine.PluginData.Save(Turbine.DataScope.Character,"FL_Totals",Totals)
    print(FL_Lang=="FR" and "Carnet de pêche enregistré." or "Fishing record saved.")
end

--~ if Event[-1] then FR_Command:Execute("fr","") end

-- Options panel
import "Dusk.Common.Options"
if not FL_Options.scale then FL_Options.scale = 1 end
local OP = Dusk.Common.Options_Init(print,FL_Options,FL_window,"FL_Options")

-- Help text
help = {
	pre = "fl",
	arg = {
		[""] = "Display fishing details.",
		[" "] = "Display fishing proficiency.",
		["<link>"] = "Display item details.",
		catch = "List fishing catch records.",
        zone = "List known deed fish for the current fishing area.",
        deeds = "Show FishingLog fishing-deed progress.",
        ["deed <name>"] = "Show details for a fishing deed.",
		cook = "List fish that can be cooked.",
		profs = "List fishing proficiencies.",
		quest = "List fish that are part of a quest.",
		track = "Toggle unknown fish tracking.",
		fr = "Relancer la localisation automatique française.",
		trophy = "List fish that are trophies.",
	},
	cmd = {
		fll = {
			[" "] = "Fishing location commands.",
			[";loc"] = "Set the current fishing location.",
			["<loc>"] = "List catches at <loc> fishing location.",
			last = "List catches at last fishing location.",
			list = "List catch count by fishing location.",
		},
		flq = {
			[" "] = "List fishing quests.",
			["<#>"] = "List fishing quest # details.",
		},
		flw = "Open Fishing Log window.",
	},
}

-- French help override
if FL_Lang=="FR" then
    help = {
        pre = "fl",
        arg = {
            [""] = "Afficher les informations de pêche.",
            [" "] = "Afficher la maîtrise de pêche.",
            ["<lien>"] = "Afficher les détails d’un objet.",
            catch = "Afficher l’historique des prises.",
            zone = "Lister les poissons de prouesse connus pour la zone actuelle.",
            deeds = "Afficher la progression des prouesses suivie par FishingLog.",
            ["deed <nom>"] = "Afficher le détail d’une prouesse (dard, esturgeon, truite, lac, saumon).",
            cook = "Lister les poissons pouvant être cuisinés.",
            profs = "Afficher les maîtrises de pêche enregistrées.",
            quest = "Lister les poissons liés aux quêtes.",
            track = "Activer/désactiver le suivi des prises inconnues.",
            fr = "Relancer la localisation automatique française.",
            trophy = "Lister les poissons trophées.",
        },
        cmd = {
            fll = {
                [" "] = "Commandes liées aux lieux de pêche.",
                [";loc"] = "Définir le lieu de pêche actuel.",
                ["<lieu>"] = "Lister les prises du lieu indiqué.",
                last = "Lister les prises du dernier lieu.",
                list = "Lister les lieux de pêche enregistrés.",
            },
            flq = {
                [" "] = "Lister les quêtes de pêche.",
                ["<#>"] = "Afficher les détails de la quête n° #.",
            },
            flw = "Ouvrir le Carnet de pêche.",
        },
    }
end
