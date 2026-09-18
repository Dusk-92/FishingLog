-- Static release invariants that do not require the LOTRO runtime.
local function read(path)
    local f=assert(io.open(path,"rb"),"cannot open "..path)
    local s=f:read("*a")
    f:close()
    return s
end

local descriptor=read("Dusk/FishingLog.plugin")
assert(descriptor:find("<Version>1.3-FR10.1</Version>",1,true),"descriptor version mismatch")
assert(descriptor:find('Apartment="FishingLog"',1,true),"FishingLog must use an isolated Apartment")

local preflight=read("Dusk/FishingLog/FL_Preflight.lua")
assert(preflight:find("FishingLog FR9.1 release preflight",1,true),"preflight release marker mismatch")
assert(not preflight:find("expectedCategory",1,true),"numeric equipment category validation returned")
assert(preflight:find('version="FR9.1"',1,true),"quarantine version marker mismatch")
assert(preflight:find("FL8_LoadFailures",1,true),"local persistence failure guard missing")

local window=read("Dusk/FishingLog/FL_Window.lua")
assert(not window:find("IsShiftKeyDown",1,true),"obsolete Shift rod bypass returned")
assert(window:find("FL_RestoreSavedShortcut",1,true),"safe shortcut restore missing")
assert(window:find("FL_ToFishingLevel(level)",1,true),"window fishing-level guard missing")

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

print("FishingLog release invariant tests: OK")
