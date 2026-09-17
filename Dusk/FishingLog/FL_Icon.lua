-- FishingLog floating desktop icon
-- Left click: show/hide FishingLog window
-- Left drag: move the icon; position is saved independently from FL_Options

-- Important on FR/DE clients: make sure the PluginData Load/Save wrappers are
-- installed BEFORE loading the dedicated icon state.
import "Dusk.Common"

-- FR7.5: suppress the automatic FR-name scan at login. The manual /fl fr
-- command still works because it calls FL_AutoLocalize(true).
if FL_Options then FL_Options.frProbeVersion = 3 end

FL_IconWindow = Turbine.UI.Window()
FL_IconWindow:SetSize(32,32)
-- Same launcher layer as TravelRef / LOTRO Events: native LOTRO panels such as
-- the world map can cover the icon instead of the icon staying always on top.
FL_IconWindow:SetZOrder(0)

local sw, sh = Turbine.UI.Display.GetWidth(), Turbine.UI.Display.GetHeight()
local defaultX = math.max(0, sw - 52)
local defaultY = math.max(0, math.floor(sh * 0.45))

-- FR7.4: keep the desktop icon position in its own PluginData key.
-- Store the coordinates as integer strings to avoid any locale/decimal issue.
local FL_IconState = Turbine.PluginData.Load(Turbine.DataScope.Server,"FL_IconState")
if type(FL_IconState) ~= "table" then FL_IconState = {} end

local savedX = tonumber(FL_IconState.x)
local savedY = tonumber(FL_IconState.y)

-- Migrate older FR6/FR7 saves once.
if not savedX then savedX = tonumber(FL_Options and FL_Options.iconX) end
if not savedY then savedY = tonumber(FL_Options and FL_Options.iconY) end
if (not savedX or not savedY) and FL_Options and type(FL_Options.iconPos) == "table" then
    savedX = savedX or tonumber(FL_Options.iconPos.x)
    savedY = savedY or tonumber(FL_Options.iconPos.y)
end

local px = math.max(0, math.min(savedX or defaultX, sw - 32))
local py = math.max(0, math.min(savedY or defaultY, sh - 32))
FL_IconWindow:SetPosition(px,py)

function FL_SaveIconPosition()
    if not FL_IconWindow then return end
    local x,y = FL_IconWindow:GetPosition()
    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)

    FL_IconState.x = tostring(x)
    FL_IconState.y = tostring(y)
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_IconState",FL_IconState)

    -- Keep the old fields updated only for backwards compatibility.
    if FL_Options then
        FL_Options.iconX = x
        FL_Options.iconY = y
        FL_Options.iconPos = nil
    end
end

-- If we migrated an old position, immediately create the dedicated save.
if not tonumber(FL_IconState.x) or not tonumber(FL_IconState.y) then
    FL_SaveIconPosition()
end

local icon = Turbine.UI.Control()
icon:SetParent(FL_IconWindow)
icon:SetPosition(0,0)
icon:SetSize(32,32)
icon:SetBackground("Dusk/FishingLog/Fish.tga")

local dragging = false
local moved = false
local startMouseX, startMouseY = 0,0
local startX, startY = 0,0

icon.MouseDown = function(sender,args)
    if args.Button ~= Turbine.UI.MouseButton.Left then return end
    dragging = true
    moved = false
    startMouseX, startMouseY = Turbine.UI.Display.GetMouseX(), Turbine.UI.Display.GetMouseY()
    startX, startY = FL_IconWindow:GetPosition()
end

icon.MouseMove = function(sender,args)
    if not dragging then return end
    local mx,my = Turbine.UI.Display.GetMouseX(), Turbine.UI.Display.GetMouseY()
    local dx,dy = mx-startMouseX, my-startMouseY
    if math.abs(dx)>2 or math.abs(dy)>2 then moved = true end
    if moved then
        local x = math.max(0, math.min(startX+dx, Turbine.UI.Display.GetWidth()-32))
        local y = math.max(0, math.min(startY+dy, Turbine.UI.Display.GetHeight()-32))
        FL_IconWindow:SetPosition(x,y)
    end
end

local function finishDrag(sender,args)
    if args and args.Button and args.Button ~= Turbine.UI.MouseButton.Left then return end
    if not dragging then return end
    dragging = false
    if moved then
        FL_SaveIconPosition()
    else
        local visible = not FL_window:IsVisible()
        FL_window:SetVisible(visible)
        if visible then FL_window:SetZOrder(2) end
    end
end

-- Listen on both the child icon and its window. This makes the save reliable
-- even when the release lands on the edge/outside of the 32x32 child control.
icon.MouseUp = finishDrag
FL_IconWindow.MouseUp = finishDrag

FL_IconWindow:SetVisible(true)
