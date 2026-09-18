-- FishingLog FR10.2 - regional fishing/deed guide
-- coding: utf-8
--
-- This file intentionally contains only reliable fishing-deed data. FishingLog
-- remains a catch/spot journal; this guide supplements it instead of pretending
-- that every possible catch is tied to one exact coordinate.

import "Dusk.FishingLog.FL_Number"

FL_Guide = {}

local function norm(s)
    s = tostring(s or ""):lower()
    s = s:gsub("^%s+",""):gsub("%s+$","")
    s = s:gsub("é","e"):gsub("è","e"):gsub("ê","e"):gsub("ë","e")
    s = s:gsub("à","a"):gsub("â","a"):gsub("ä","a")
    s = s:gsub("î","i"):gsub("ï","i")
    s = s:gsub("ô","o"):gsub("ö","o")
    s = s:gsub("ù","u"):gsub("û","u"):gsub("ü","u")
    s = s:gsub("ç","c"):gsub("œ","oe")
    s = s:gsub("’","'")
    return s
end

local function L(fr,en)
    return FL_Lang=="FR" and fr or en
end

FL_Guide.Groups = {
    starter = {
        titleFR = "Ered Luin / Comté / Pays de Bree",
        titleEN = "Ered Luin / Shire / Bree-land",
        fish = {
            {id="0F124", nameFR="Dard à nageoire rouge", level=60, deed="darter"},
            {id="0F13A", nameFR="Dard rayé", level=85, deed="darter"},
            {id="0EFCF", nameFR="Truite brune", level=60, deed="trout"},
            {id="0EFD3", nameFR="Truite mouchetée", level=85, deed="trout"},
            {id="0EFCE", nameFR="Truite de lac", level=100, deed="trout"},
            {id="0F127", nameFR="Esturgeon nain", level=60, deed="sturgeon"},
            {id="0F120", nameFR="Esturgeon à nez pelle", level=80, deed="sturgeon"},
        },
    },
    lone = {
        titleFR = "Terres Solitaires / Hauts du Nord",
        titleEN = "Lone-lands / North Downs",
        fish = {
            {id="0F141", nameFR="Dard à nageoire noire", level=85, deed="darter"},
            {id="0F11E", nameFR="Dard à nageoire verte", level=85, deed="darter"},
            {id="0F139", nameFR="Splendide dard", level=100, deed="darter"},
            {id="0EFD6", nameFR="Truite taureau", level=80, deed="trout"},
            {id="0EFD2", nameFR="Truite fardée", level=80, deed="trout"},
            {id="0F136", nameFR="Esturgeon à museau court", level=75, deed="sturgeon"},
            {id="0F11F", nameFR="Esturgeon pâle", level=80, deed="sturgeon"},
        },
    },
    evendim = {
        titleFR = "Evendim / Trouée des Trolls",
        titleEN = "Evendim / Trollshaws",
        fish = {
            {id="0F12B", nameFR="Dard à longue nageoire", level=85, deed="darter"},
            {id="0F133", nameFR="Dard à nageoire écarlate", level=90, deed="darter"},
            {id="0EFCD", nameFR="Truite à gorge coupée", level=75, deed="trout"},
            {id="0EFD4", nameFR="Truite arc-en-ciel", level=90, deed="trout"},
            {id="0F132", nameFR="Esturgeon vert", level=75, deed="sturgeon"},
            {id="0F130", nameFR="Esturgeon de lac", level=90, deed="sturgeon"},
        },
    },
    north = {
        titleFR = "Forochel / Angmar",
        titleEN = "Forochel / Angmar",
        fish = {
            {id="0F128", nameFR="Dard à nageoire orange", level=70, deed="darter"},
            {id="0F137", nameFR="Dard à ventre doré", level=90, deed="darter"},
            {id="0EFD1", nameFR="Truite rouge", level=70, deed="trout"},
            {id="0EFD0", nameFR="Truite dorée", level=90, deed="trout"},
            {id="0F142", nameFR="Esturgeon barbu", level=70, deed="sturgeon"},
            {id="0F126", nameFR="Esturgeon étoilé", level=90, deed="sturgeon"},
            {id="0F13E", nameFR="Esturgeon blanc", level=100, deed="sturgeon"},
        },
    },
    lake = {
        titleFR = "Eryn Lasgalen / Terres de Dale / Ville du Lac",
        titleEN = "Eryn Lasgalen / Dale-lands / Lake-town",
        lakeMaster = true,
        fish = {
            {id="4D554", nameFR="Ablette", deed="lake"},
            {id="4D557", nameFR="Brème", deed="lake"},
            {id="4D55A", nameFR="Lotte", deed="lake"},
            {id="4D548", nameFR="Chevesne", deed="lake"},
            {id="4D556", nameFR="Goujon", deed="lake"},
            {id="4D549", nameFR="Lamproie", deed="lake"},
            {id="4D546", nameFR="Loche", deed="lake"},
            {id="4D547", nameFR="Saumon du Long Lac", deed="lake"},
            {id="4D54E", nameFR="Orfe", deed="lake"},
            {id="4D555", nameFR="Pollan", deed="lake"},
            {id="4D54A", nameFR="Corégone", deed="lake"},
            {id="4D551", nameFR="Crapet-soleil", deed="lake"},
            -- The French client database currently labels the Roach item as
            -- "Loche" too. Use the deed/wiki label here while keeping the real ID.
            {id="4D54F", nameFR="Gardon", deed="lake"},
            {id="4D553", nameFR="Grémille", deed="lake"},
            {id="4D54B", nameFR="Sprat", deed="lake"},
            {id="4D558", nameFR="Able", deed="lake"},
            {id="4D55D", nameFR="Tanche", deed="lake"},
            {id="4D55B", nameFR="Tilapia", deed="lake"},
            {id="4D54D", nameFR="Lavaret", deed="lake"},
            {id="4D559", nameFR="Sandre", deed="lake"},
        },
    },
}

-- Area matching accepts both FR and EN client spellings and a few common aliases.
local aliases = {
    {"pays de bree", "starter"}, {"bree%-land", "starter"}, {"bree land", "starter"},
    {"bree", "starter"}, {"ered luin", "starter"}, {"la comte", "starter"},
    {"the shire", "starter"}, {"shire", "starter"},

    {"terres solitaires", "lone"}, {"lone%-lands", "lone"}, {"lone lands", "lone"},
    {"hauts du nord", "lone"}, {"north downs", "lone"},

    {"evendim", "evendim"}, {"trouee des trolls", "evendim"}, {"trollshaws", "evendim"},

    {"forochel", "north"}, {"angmar", "north"},

    {"eryn lasgalen", "lake"}, {"foret noire", "lake"}, {"mirkwood", "lake"},
    {"terres de dale", "lake"}, {"dale%-lands", "lake"}, {"dale lands", "lake"},
    {"ville du lac", "lake"}, {"lake%-town", "lake"}, {"lake town", "lake"},
}

function FL_Guide.MatchArea(area)
    local a = norm(area)
    for _,v in ipairs(aliases) do
        if a:find(v[1]) then return v[2], FL_Guide.Groups[v[2]] end
    end
    return nil,nil
end

-- FL_Main historically reads d.fr directly. Keep that field, but make it
-- language-safe so EN/DE clients never receive a French-only deed label.
FL_Guide.Deeds = {
    {key="darter", fr=L("Maître de la pêche au dard","Darter fishing deed"), ids={"0F124","0F11E","0F12B","0F128","0F13A","0F141","0F133","0F137","0F139"}},
    {key="sturgeon", fr=L("Maître de la pêche à l’esturgeon","Sturgeon fishing deed"), ids={"0F127","0F136","0F132","0F142","0F120","0F11F","0F130","0F126","0F13E"}},
    {key="trout", fr=L("Maître de la pêche à la truite","Trout fishing deed"), ids={"0EFCF","0EFD6","0EFCD","0EFD1","0EFD3","0EFD2","0EFD4","0EFD0","0EFCE"}},
    {key="lake", fr=L("Maître du lac","Lake fishing deed"), ids={"4D554","4D557","4D55A","4D548","4D556","4D549","4D546","4D547","4D54E","4D555","4D54A","4D551","4D54F","4D553","4D54B","4D558","4D55D","4D55B","4D54D","4D559"}},
    {key="salmon", fr=L("Un saumon de 25 kilos","50-pound salmon deed"), ids={"0F22C"}},
}

function FL_Guide.GetDeed(key)
    key = norm(key)
    local map = {
        dard="darter", darter="darter",
        esturgeon="sturgeon", sturgeon="sturgeon",
        truite="trout", trout="trout",
        lac="lake", lake="lake",
        saumon="salmon", salmon="salmon",
    }
    key = map[key] or key
    for _,d in ipairs(FL_Guide.Deeds) do if d.key==key then return d end end
    return nil
end

function FL_Guide.GetFishInfo(id)
    for _,g in pairs(FL_Guide.Groups) do
        for _,f in ipairs(g.fish) do
            if f.id==id then return f end
        end
    end
    if id=="0F22C" then
        return {id=id,nameFR="Saumon de 25 kilos",deed="salmon"}
    end
    return nil
end

function FL_Guide.GetFishLabel(id)
    if FL_Lang~="FR" then return nil end
    local info=FL_Guide.GetFishInfo(id)
    return info and info.nameFR or nil
end

function FL_Guide.CountCaught(ids, totals)
    local n=0
    totals = type(totals)=="table" and totals or {}
    for _,id in ipairs(ids or {}) do
        if (FL_ToNumber(totals[id]) or 0)>0 then n=n+1 end
    end
    return n
end

FL_Guide.SkillMilestones = {
    {10,L("Apprenti pêcheur à la ligne","Apprentice Angler")},
    {50,L("Compagnon pêcheur à la ligne","Journeyman Angler")},
    {100,L("Expert pêcheur à la ligne","Expert Angler")},
    {150,L("Maître pêcheur à la ligne","Master Angler")},
    {200,L("Seigneur des Ruisseaux","Lord of Streams")},
}

function FL_Guide.GetSkillTitle(level)
    local fp=FL_ToFishingLevel(level)
    if fp==nil then return nil end
    local title=nil
    for _,m in ipairs(FL_Guide.SkillMilestones) do
        if fp>=m[1] then title=m[2] else break end
    end
    return title
end
