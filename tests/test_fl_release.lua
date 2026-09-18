-- Static release invariants that do not require the LOTRO runtime.
local function read(path)
    local f=assert(io.open(path,"rb"),"cannot open "..path)
    local s=f:read("*a")
    f:close()
    return s
end

local descriptor=read("Dusk/FishingLog.plugin")
assert(descriptor:find("<Version>1.3-FR10.2</Version>",1,true),"descriptor version mismatch")
assert(descriptor:find('Apartment="FishingLog"',1,true),"FishingLog must use an isolated Apartment")

local preflight=read("Dusk/FishingLog/FL_Preflight.lua")
assert(preflight:find("FishingLog FR10.2 release preflight",1,true),"preflight release marker mismatch")
assert(not preflight:find("expectedCategory",1,true),"numeric equipment category validation returned")
assert(preflight:find('version="FR10.2"',1,true),"quarantine version marker mismatch")
assert(preflight:find("FL8_LoadFailures",1,true),"local persistence failure guard missing")
assert(preflight:find("math.floor(360*scale+0.5)",1,true),"preflight width is stale")
assert(preflight:find("math.floor(315*scale+0.5)",1,true),"preflight height is stale")

local window=read("Dusk/FishingLog/FL_Window.lua")
assert(not window:find("IsShiftKeyDown",1,true),"obsolete Shift rod bypass returned")
assert(window:find("FL_RestoreSavedShortcut",1,true),"safe shortcut restore missing")
assert(window:find("FL_ToFishingLevel(level)",1,true),"window fishing-level guard missing")
assert(window:find("FL_OpenDeeds",1,true),"graphical deeds button missing")

local loader=read("Dusk/FishingLog/FL_Loader.lua")
assert(not loader:find("Turbine.PluginData.Load =",1,true),"temporary PluginData.Load monkeypatch returned")
assert(loader:find("FL_ParseFishingAdvancement",1,true),"loader parser guard missing")

local parser=read("Dusk/FishingLog/FL_Parse.lua")
assert(parser:find("FL_ParseFishingAdvancement",1,true),"advancement parser missing")
assert(parser:find("FL_ExtractIIDDID",1,true),"item-link parser missing")

local icon=read("Dusk/FishingLog/FL_Icon.lua")
assert(icon:find("FL_ToNumber(FL_IconState.x)",1,true),"icon coordinate hardening missing")

local main=read("Dusk/FishingLog/FL_Main.lua")
assert(main:find("FL_ToFishingLevel",1,true),"main fishing-level guard missing")
assert(main:find("args.ChatType==Turbine.ChatType.Advancement",1,true),"Advancement guard missing")
assert(main:find("FL_PluginDataLoad",1,true),"plugin-local persistence helper missing")
assert(main:find("math.max(totalsFp,profFp)",1,true),"max proficiency reconciliation missing")
assert(main:find("FL_ParseFishingAdvancement",1,true),"central advancement parser missing")
assert(main:find("FL_Guide.GetSkillTitle",1,true),"shared fishing title source missing")
assert(main:find('import "Dusk.FishingLog.FL_Helper"',1,true),"integrated guide import missing")
assert(main:find('import "Dusk.FishingLog.FL_Deeds"',1,true),"graphical deeds import missing")

local helper=read("Dusk/FishingLog/FL_Helper.lua")
assert(helper:find('import "Dusk.FishingLog.FL_HelperMap"',1,true),"canonical helper bridge import missing")
assert(helper:find("ID[id].ln or ID[id].n",1,true),"canonical FishingLog names are not used by helper")
assert(helper:find("FL_Options and FL_Options.esc",1,true),"helper Escape option inheritance missing")
assert(helper:find("window:SetScale(scale)",1,true),"helper scale inheritance missing")

local deeds=read("Dusk/FishingLog/FL_Deeds.lua")
assert(deeds:find("FL_Guide.CountCaught",1,true),"graphical deeds progress missing")
assert(deeds:find("FL_Options and FL_Options.esc",1,true),"deeds Escape option inheritance missing")


print("FishingLog release invariant tests: OK")
