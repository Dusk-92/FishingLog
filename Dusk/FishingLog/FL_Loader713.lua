-- FishingLog FR7.13 compatibility patch.
-- Loaded after FR7.12 to keep numeric parsing locale-safe, hide internal
-- location keys in chat, and persist equipment shortcut changes immediately.

import "Dusk.FishingLog.FL_Loader"

local FL713_RawTonumber = tonumber

local function FL713_ToNumber(value,base)
    if type(value)=="number" then return value end
    if type(value)~="string" then return FL713_RawTonumber(value,base) end

    -- Bases other than 10 must keep Lua's normal behaviour.
    if base~=nil then return FL713_RawTonumber(value,base) end

    local n=FL713_RawTonumber(value)
    if n~=nil then return n end

    n=FL713_RawTonumber((value:gsub(",",".")))
    if n~=nil then return n end

    return FL713_RawTonumber((value:gsub("%.",",")))
end

local FL713_Zloc = "^%s*(.-)%s*:%s*(.-)%s*:%s*([%d%.,]+%s*[NS])%s*,%s*([%d%.,]+%s*[EWO])%s*$"
local FL713_PreviousExecute = FL_Command.Execute

function FL_Command:Execute(cmd,args)
    args=args or ""
    local isLocationSet = cmd=="fll" and args:match(FL713_Zloc)~=nil
    if not isLocationSet then return FL713_PreviousExecute(self,cmd,args) end

    -- FR7.12 and the legacy core both resolve tonumber dynamically. Override it
    -- only for this synchronous location command so both decimal separators work.
    local previousTonumber=tonumber
    local previousWriteLine=Turbine.Shell.WriteLine
    tonumber=FL713_ToNumber

    -- Internal location keys are "region;display coordinates". Keep that
    -- implementation detail out of the player's chat messages.
    Turbine.Shell.WriteLine=function(text)
        if type(text)=="string" then
            text=text:gsub("(%s—%s)%d+;","%1")
        end
        return previousWriteLine(text)
    end

    local ok,result=pcall(FL713_PreviousExecute,self,cmd,args)
    Turbine.Shell.WriteLine=previousWriteLine
    tonumber=previousTonumber

    if not ok then error(result) end
    return result
end

local function FL713_SaveTotals()
    if type(Totals)=="table" then
        Turbine.PluginData.Save(Turbine.DataScope.Character,"FL_Totals",Totals)
    end
end

local function FL713_WrapShortcut(control)
    if not control or type(control.ShortcutChanged)~="function" then return end
    local previous=control.ShortcutChanged
    control.ShortcutChanged=function(sender,args)
        local result=previous(sender,args)
        FL713_SaveTotals()
        return result
    end
end

if FL_window then
    FL713_WrapShortcut(FL_window.rod)
    FL713_WrapShortcut(FL_window.weapon)
    FL713_WrapShortcut(FL_window.shield)
end
