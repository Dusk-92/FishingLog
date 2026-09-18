-- Static release invariants that do not require the LOTRO runtime.
local function read(path)
    local f=assert(io.open(path,"rb"),"cannot open "..path)
    local s=f:read("*a")
    f:close()
    return s
end

local descriptor=read("Dusk/FishingLog.plugin")
assert(descriptor:find("<Version>1.3-FR9.0</Version>",1,true),"descriptor version mismatch")
assert(descriptor:find('Apartment="FishingLog"',1,true),"FishingLog must use an isolated Apartment")

local preflight=read("Dusk/FishingLog/FL_Preflight.lua")
assert(preflight:find("FishingLog FR9.0 release preflight",1,true),"preflight release marker mismatch")
assert(not preflight:find("expectedCategory",1,true),"numeric equipment category validation returned")
assert(preflight:find('version="FR9.0"',1,true),"quarantine version marker mismatch")
assert(preflight:find("FL8_LoadFailures",1,true),"local persistence failure guard missing")

local window=read("Dusk/FishingLog/FL_Window.lua")
assert(not window:find("IsShiftKeyDown",1,true),"obsolete Shift rod bypass returned")
assert(window:find("FL_RestoreSavedShortcut",1,true),"safe shortcut restore missing")
assert(window:find("FL_ToFishingLevel(level)",1,true),"window fishing-level guard missing")

local main=read("Dusk/FishingLog/FL_Main.lua")
assert(main:find("FL_ToFishingLevel",1,true),"main fishing-level guard missing")
assert(main:find("args.ChatType==Turbine.ChatType.Advancement",1,true),"Advancement guard missing")
assert(main:find("FL_PluginDataLoad",1,true),"plugin-local persistence helper missing")

print("FishingLog release invariant tests: OK")
