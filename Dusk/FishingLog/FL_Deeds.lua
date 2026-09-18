-- FishingLog FR10.2 - graphical fishing deed tracker.
-- This is a FishingLog view: progress is based on catches recorded by the plugin,
-- because the LOTRO Lua API cannot read the player's deed journal directly.

import "Turbine.UI"
import "Turbine.UI.Lotro"

local UI = {
    title="Fishing Deeds", close="Close", tracked="FishingLog tracking",
    note="Only catches recorded by FishingLog are counted.",
    lake="Lake-master also requires visiting Lake-town; check that step in the game deed journal.",
    caught="caught", missing="missing", level="lvl."
}
if FL_Lang=="FR" then
    UI = {
        title="Prouesses de pêche", close="Fermer", tracked="Suivi FishingLog",
        note="Seules les prises enregistrées par FishingLog sont comptées.",
        lake="Maître du lac demande aussi de visiter la Ville du Lac : vérifie cette étape dans le journal des prouesses du jeu.",
        caught="pris", missing="manquant", level="niv."
    }
end

local gold = Turbine.UI.Color(0.90,0.74,0.22)
local white = Turbine.UI.Color(1,1,1)
local muted = Turbine.UI.Color(0.72,0.72,0.72)
local green = Turbine.UI.Color(0.35,0.95,0.35)
local dark = Turbine.UI.Color(0.06,0.06,0.06)

local shortLabels = {
    darter = FL_Lang=="FR" and "Dards" or "Darters",
    sturgeon = FL_Lang=="FR" and "Esturgeons" or "Sturgeon",
    trout = FL_Lang=="FR" and "Truites" or "Trout",
    lake = FL_Lang=="FR" and "Lac" or "Lake",
    salmon = FL_Lang=="FR" and "Saumon" or "Salmon"
}

local function centerAndScale(window)
    local scale = FL_ToNumber(FL_Options and FL_Options.scale) or 1
    scale = math.max(0.5,math.min(2,scale))
    window:SetScale(scale)
    local sw,sh = Turbine.UI.Display.GetWidth(),Turbine.UI.Display.GetHeight()
    local ww,wh = window:GetWidth()*scale,window:GetHeight()*scale
    window:SetPosition(
        math.max(0,math.floor((sw-ww)/2)),
        math.max(0,math.floor((sh-wh)/2))
    )
end

FL_DeedsWindow = class(Turbine.UI.Lotro.GoldWindow)

function FL_DeedsWindow:Constructor()
    Turbine.UI.Lotro.GoldWindow.Constructor(self)
    self:SetSize(550,500)
    self:SetText(UI.title)
    self:SetVisible(false)
    self:SetWantsKeyEvents(false)
    self.currentKey="darter"

    self.buttons={}
    local order={"darter","sturgeon","trout","lake","salmon"}
    for i,key in ipairs(order) do
        local b=Turbine.UI.Lotro.GoldButton()
        b:SetParent(self)
        b:SetPosition(18+(i-1)*103,42)
        b:SetSize(98,24)
        b:SetText(shortLabels[key])
        local deedKey=key
        b.Click=function() self:ShowDeed(deedKey) end
        self.buttons[key]=b
    end

    self.header=Turbine.UI.Label()
    self.header:SetParent(self)
    self.header:SetPosition(20,78)
    self.header:SetSize(510,24)
    self.header:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold18)
    self.header:SetForeColor(gold)
    self.header:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

    self.note=Turbine.UI.Label()
    self.note:SetParent(self)
    self.note:SetPosition(20,103)
    self.note:SetSize(510,36)
    self.note:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    self.note:SetForeColor(muted)
    self.note:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.note:SetMultiline(true)

    self.closeButton=Turbine.UI.Lotro.GoldButton()
    self.closeButton:SetParent(self)
    self.closeButton:SetPosition(200,455)
    self.closeButton:SetSize(150,25)
    self.closeButton:SetText(UI.close)
    self.closeButton.Click=function() self:SetVisible(false) end

    self:ShowDeed(self.currentKey)
end

function FL_DeedsWindow:ClearList()
    if self.listBox then
        self.listBox:SetParent(nil)
        self.listBox=nil
    end
    if self.scrollBar then
        self.scrollBar:SetParent(nil)
        self.scrollBar=nil
    end
end

function FL_DeedsWindow:ShowDeed(key)
    local deed=FL_Guide.GetDeed(key)
    if not deed then return end
    self.currentKey=deed.key
    self:ClearList()

    local done=FL_Guide.CountCaught(deed.ids,Totals)
    self.header:SetText(deed.fr.."  —  "..done.."/"..#deed.ids)
    self.note:SetText((deed.key=="lake" and UI.lake or UI.note))

    self.listBox=Turbine.UI.ListBox()
    self.listBox:SetParent(self)
    self.listBox:SetPosition(20,145)
    self.listBox:SetSize(495,295)

    for index,id in ipairs(deed.ids) do
        local count=FL_ToNonNegativeInteger(Totals and Totals[id]) or 0
        local info=FL_Guide.GetFishInfo and FL_Guide.GetFishInfo(id) or nil
        local label=FL_Guide.GetFishLabel(id) or (ID[id] and (ID[id].ln or ID[id].n)) or id

        local item=Turbine.UI.Control()
        item:SetSize(475,42)
        if index%2==0 then item:SetBackColor(dark) end

        local status=Turbine.UI.Label()
        status:SetParent(item)
        status:SetPosition(8,5)
        status:SetSize(48,30)
        status:SetFont(Turbine.UI.Lotro.Font.Verdana14)
        status:SetForeColor(count>0 and green or muted)
        status:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
        status:SetText(count>0 and "[OK]" or "[ ]")

        local name=Turbine.UI.Label()
        name:SetParent(item)
        name:SetPosition(60,3)
        name:SetSize(315,22)
        name:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold18)
        name:SetForeColor(count>0 and white or muted)
        name:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        name:SetText(label)

        local detail=Turbine.UI.Label()
        detail:SetParent(item)
        detail:SetPosition(60,23)
        detail:SetSize(315,16)
        detail:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        detail:SetForeColor(muted)
        local text=count>0 and (UI.caught.." x"..count) or UI.missing
        if info and info.level then text=text.."  •  "..UI.level.." "..info.level end
        detail:SetText(text)

        local total=Turbine.UI.Label()
        total:SetParent(item)
        total:SetPosition(380,5)
        total:SetSize(80,30)
        total:SetFont(Turbine.UI.Lotro.Font.Verdana14)
        total:SetForeColor(count>0 and green or muted)
        total:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
        total:SetText(count>0 and ("x"..count) or "—")

        self.listBox:AddItem(item)
    end

    self.scrollBar=Turbine.UI.Lotro.ScrollBar()
    self.scrollBar:SetParent(self)
    self.scrollBar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollBar:SetPosition(520,145)
    self.scrollBar:SetSize(10,295)
    self.listBox:SetVerticalScrollBar(self.scrollBar)
end

function FL_DeedsWindow:Refresh()
    self:ShowDeed(self.currentKey or "darter")
end

FL_DeedsWindow.VisibleChanged=function(sender,args)
    sender:SetWantsKeyEvents(sender:IsVisible())
end

FL_DeedsWindow.KeyDown=function(sender,args)
    if args.Action==Turbine.UI.Lotro.Action.Escape and not (FL_Options and FL_Options.esc) then
        sender:SetVisible(false)
    end
end

function FL_OpenDeeds(key)
    if not FL_deedsWindow then FL_deedsWindow=FL_DeedsWindow() end
    if key then FL_deedsWindow:ShowDeed(key) else FL_deedsWindow:Refresh() end
    centerAndScale(FL_deedsWindow)
    FL_deedsWindow:SetVisible(true)
    FL_deedsWindow:SetZOrder(3)
end
