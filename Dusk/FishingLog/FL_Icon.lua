-- FishingLog floating desktop icon
-- Left click: show/hide FishingLog window
-- Left drag: move the icon; position is saved in FL_Options

FL_IconWindow = Turbine.UI.Window()
FL_IconWindow:SetSize(32,32)
FL_IconWindow:SetZOrder(1000)

local sw, sh = Turbine.UI.Display.GetWidth(), Turbine.UI.Display.GetHeight()
local defaultX = math.max(0, sw - 52)
local defaultY = math.max(0, math.floor(sh * 0.45))

-- FR7.1: store coordinates as flat scalar values. LOTRO PluginData is more
-- reliable with these than with a nested {x=...,y=...} table.
local savedX = tonumber(FL_Options.iconX)
local savedY = tonumber(FL_Options.iconY)

-- One-time migration from the old FR6/FR7 iconPos table.
if (not savedX or not savedY) and type(FL_Options.iconPos) == "table" then
    savedX = tonumber(FL_Options.iconPos.x)
    savedY = tonumber(FL_Options.iconPos.y)
end

local px = math.max(0, math.min(savedX or defaultX, sw - 32))
local py = math.max(0, math.min(savedY or defaultY, sh - 32))
FL_IconWindow:SetPosition(px,py)

FL_Options.iconX = px
FL_Options.iconY = py
FL_Options.iconPos = nil

function FL_SaveIconPosition()
    if not FL_IconWindow or not FL_Options then return end
    local x,y = FL_IconWindow:GetPosition()
    FL_Options.iconX = math.floor(x + 0.5)
    FL_Options.iconY = math.floor(y + 0.5)
    FL_Options.iconPos = nil
    Turbine.PluginData.Save(Turbine.DataScope.Server,"FL_Options",FL_Options)
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

icon.MouseUp = function(sender,args)
    if args.Button ~= Turbine.UI.MouseButton.Left then return end
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

FL_IconWindow:SetVisible(true)
