-- Fishing Log window handler
-- coding: utf-8 '�

import "Turbine.UI.Lotro"
import "Dusk.Common"

-- FL_Main exposes prefixed output helpers inside FishingLog's dedicated Apartment.
local print,printe = FL_Print,FL_PrintE

local labelFont = Turbine.UI.Lotro.Font.Verdana14
local foreColor = Turbine.UI.Color( 0.9, 0.9, 0 )
local whiteColor = Turbine.UI.Color( 1.0, 1.0, 1.0 )
local backColor = Turbine.UI.Color( 0.0, 0.0, 0.0 )
local greyColor = Turbine.UI.Color( 0.1, 0.1, 0.1 )
local Button = Turbine.UI.Lotro.Button
local Label = Turbine.UI.Label
local TextBox = Turbine.UI.TextBox
local Item = Turbine.UI.Lotro.ShortcutType.Item
local Hobby = Turbine.UI.Lotro.ShortcutType.Hobby
local Alias = Turbine.UI.Lotro.ShortcutType.Alias
local Shortcut = Turbine.UI.Lotro.Shortcut
local Quickslot = Turbine.UI.Lotro.Quickslot
local Qsize = 34
local Blank

local UI = {
    title="Fishing Log", rod="Fishing rod:", fish="Fish:", weapon="Weapon:", second="2nd slot:",
    setloc="Set Location", listloc="List Locations", loccatch="Caught Here", personal="Personal Totals",
    area="Area: none", level="Fishing: level ", regionfish="Area Fish", deeds="Fishing Deeds", helper="Fishing Guide"
}
if FL_Lang=="FR" then
    UI = {
        title="Carnet de pêche", rod="Canne à pêche :", fish="Pêcher :", weapon="Arme :", second="2e slot :",
        setloc="Définir lieu", listloc="Liste des lieux", loccatch="Prises ici", personal="Totaux perso",
        area="Zone : aucune", level="Pêche : niveau ", regionfish="Poissons zone", deeds="Prouesses", helper="Guide pêche"
    }
end

FL_Window = class( Turbine.UI.Lotro.Window )

function FL_Window:AddField(control, text, pos, size)
	local field = control()
	field:SetParent( self )
	if text then field:SetText( text ) end
	field:SetPosition( pos.x,pos.y )
	field:SetSize( size.x,size.y )
	if control==Button or not text then return field end
	field:SetFont( labelFont )
	field:SetForeColor( text=="" and whiteColor or foreColor )
	local grey = control==TextBox or control==Quickslot
	field:SetBackColor( grey and greyColor or backColor )
	field:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft )
	return field
end

function FL_Shortcut(sender,name)
    local shortcut = sender:GetShortcut()
    local itemType = shortcut:GetType()
    if itemType==0 then return end
    local itemData = shortcut:GetData()
    if sender:IsAltKeyDown() then
        print("Type="..tostring(itemType)..", "..(FL_Lang=="FR" and "Données=" or "Data=")..tostring(itemData))
    end
    if itemType~=Item then
        sender:SetShortcut(Blank)
        print(FL_Lang=="FR" and (name.." réinitialisé.") or (name.." reset."))
        return
    end
    if type(itemData)~="string" or itemData=="" then
        printe(FL_Lang=="FR" and "Raccourci d’objet invalide." or "Invalid item shortcut.")
        return
    end

    -- GetItem() may temporarily be nil while LOTRO is resolving the object.
    -- Preserve the stable shortcut payload instead of erasing a valid drop.
    local item = shortcut:GetItem()
    if item then
        print(FL_Lang=="FR" and (name.." défini sur "..item:GetName()) or
              (name.." set to "..item:GetName()))
    else
        print(FL_Lang=="FR" and (name.." enregistré ; objet en cours de résolution.") or
              (name.." saved; item is still resolving."))
    end
    return itemData
end

local function FL_RestoreSavedShortcut(control,data,background)
    local restored=false
    if type(data)=="string" and data~="" then
        restored=pcall(function()
            control:SetShortcut(Shortcut(Item,data))
            local shortcut=control:GetShortcut()
            if not shortcut or shortcut:GetType()~=Item or shortcut:GetData()~=data then
                error("saved shortcut did not restore")
            end
        end)
    end
    if not restored and background then control:SetBackground(background) end
    return restored
end

function FL_Window:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self )

	-- Position the window near the top center of the screen.
	self:SetSize( 360,315 )
--	self:SetBackColor( Turbine.UI.Color() )
	local pos = FL_Options.pos1 or 
		{ x=(Turbine.UI.Display.GetWidth() - self:GetWidth())/3, 
		y=(Turbine.UI.Display:GetHeight() - self:GetHeight())*.6 }
	self:SetPosition( pos.x, pos.y )
	self:SetText( UI.title )
	self:SetVisible( false )

	-- Match BirdingLog: proficiency line directly below the title.
	self.fishingLevelLabel = self:AddField(Label, "", {x=30,y=27}, {x=300,y=16} )
	self.fishingLevelLabel:SetForeColor( whiteColor )
	self.fishingLevelLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter )
	self:SetFishingLevel(Totals and Totals.fp or nil)

-- Hobby:Fishing action is Type=Hobby(9), Data=0x7000EE1E

	-- Create a Name field
	self.name = self:AddField(Label, UI.rod, {x=42,y=57}, {x=80,y=16} )
	self.name:SetFont(Turbine.UI.Lotro.Font.TrajanPro18)

	-- Create an rod field
	self.rod = self:AddField(Quickslot, nil, {x=125,y=50}, {x=Qsize,y=Qsize} )
	Blank = self.rod:GetShortcut()
	FL_RestoreSavedShortcut(self.rod,Totals.rod,"Dusk/FishingLog/Rod.tga")
	self.rod.ShortcutChanged = function( sender, args )
		Totals.rod = FL_Shortcut(sender,FL_Lang=="FR" and "Canne à pêche" or "Fishing rod")
	end

	-- Create a fishing label
	self:AddField(Label, UI.fish, {x=205,y=55}, {x=75,y=16} )

	-- Create an fishing field
	self.fish = self:AddField(Quickslot, nil, {x=285,y=50}, {x=Qsize,y=Qsize} )
	self.fish:SetShortcut( Shortcut(Hobby,"0x7000EE1E") )
    self.fish:SetAllowDrop( false )
	self.fish.MouseEnter = function( sender, args ) FL_TrackHover = true end
	self.fish.MouseLeave = function( sender, args ) FL_TrackHover = false end

	-- Create a weapon label
	self:AddField(Label, UI.weapon, {x=50,y=107}, {x=70,y=16} )

	-- Create a weapon field
	self.weapon = self:AddField(Quickslot, nil, {x=125,y=100}, {x=Qsize,y=Qsize} )
	FL_RestoreSavedShortcut(self.weapon,Totals.wpn,"Dusk/FishingLog/Sword.tga")
	self.weapon.ShortcutChanged = function( sender, args )
		Totals.wpn = FL_Shortcut(sender,FL_Lang=="FR" and "Arme" or "Weapon")
	end

	-- Create a Shield label
	self:AddField(Label, UI.second, {x=210,y=107}, {x=70,y=16} )

	-- Create an shield field, shield slot=17
	self.shield = self:AddField(Quickslot, nil, {x=285,y=100}, {x=Qsize,y=Qsize} )
	FL_RestoreSavedShortcut(self.shield,Totals.shl,"Dusk/FishingLog/Shield.tga")
	self.shield.ShortcutChanged = function( sender, args )
		Totals.shl = FL_Shortcut(sender,FL_Lang=="FR" and "2e emplacement" or "2nd")
	end


	-- Location button: keep the proven working LOTRO Quickslot Alias overlay.
	-- The Quickslot covers the whole button and receives the real player click.
	self.locButton = self:AddField(Button, UI.setloc, {x=30,y=150}, {x=135,y=20} )

	local slot = Turbine.UI.Lotro.Quickslot()
	slot:SetParent( self.locButton )
    slot:SetPosition( 0,0 )
    slot:SetSize( self.locButton:GetWidth(), self.locButton:GetHeight() )
    slot:SetOpacity( 0 )
    slot:SetShortcut(Turbine.UI.Lotro.Shortcut( Alias,"/fll ;loc" ))
    slot:SetAllowDrop( false )
    slot:SetUseOnRightClick( false )

    -- LOTRO can still draw a few Alias pixels outside an otherwise transparent
    -- Quickslot. Hide only that bleed in the empty gap below the button.
    local aliasBleedMask = Turbine.UI.Control()
    aliasBleedMask:SetParent( self )
    aliasBleedMask:SetPosition( 28,170 )
    aliasBleedMask:SetSize( 140,8 )
    aliasBleedMask:SetBackColor( backColor )
    aliasBleedMask:SetMouseVisible( false )
    aliasBleedMask:SetZOrder( 100 )
	-- Create a Inventory listing button
	self.listButton = self:AddField(Button, UI.listloc, {x=195,y=150}, {x=135,y=20} )
	self.listButton.Click = function( sender,args )
        FL_Command:Execute("fll","list")
	end

	-- Create a catch listing button
	self.locationCatchButton = self:AddField(Button, UI.loccatch, {x=30,y=210}, {x=135,y=20} )
	self.locationCatchButton.Click = function( sender,args )
        FL_Command:Execute("fll","last")
	end

	-- Create a catch listing button
	self.personalCatchButton = self:AddField(Button, UI.personal, {x=195,y=210}, {x=135,y=20} )
	self.personalCatchButton.Click = function( sender,args )
        FL_Command:Execute("fl","catch")
	end

    -- Keep the selected fishing spot visible without breaking the shared grid.
    self.areaLabel = self:AddField(Label, UI.area, {x=30,y=240}, {x=300,y=18} )
    self.areaLabel:SetForeColor( whiteColor )
    self.areaLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter )

    self.regionFishButton = self:AddField(Button, UI.regionfish, {x=30,y=180}, {x=135,y=20} )
    self.regionFishButton.Click = function( sender,args )
        FL_Command:Execute("fl","zone")
    end

    self.deedsButton = self:AddField(Button, UI.deeds, {x=195,y=180}, {x=135,y=20} )
    self.deedsButton.Click = function( sender,args )
        if type(FL_OpenDeeds)=="function" then
            FL_OpenDeeds()
        else
            FL_Command:Execute("fl","deeds")
        end
    end

    self.helperButton = self:AddField(Button, UI.helper, {x=35,y=270}, {x=290,y=20} )
    self.helperButton.Click = function( sender,args )
        FL_HelperOpen()
    end

end

function FL_Window:SetCurrentLocation(area,coords)
    if not self.areaLabel then return end
    area = tostring(area or "")
    coords = tostring(coords or "")
    local prefix = FL_Lang=="FR" and "Zone : " or "Area: "
    local text = prefix..area
    if coords~="" then text = text.." — "..coords end
    self.areaLabel:SetText(text)
end

function FL_Window:SetFishingLevel(level)
    if not self.fishingLevelLabel then return end
    local fp = FL_ToFishingLevel(level)
    if fp==nil then
        self.fishingLevelLabel:SetText(FL_Lang=="FR" and "Pêche : niveau inconnu" or "Fishing: unknown level")
        return
    end
    local text = UI.level..tostring(fp)
    local title = FL_Guide and FL_Guide.GetSkillTitle and FL_Guide.GetSkillTitle(fp) or nil
    if type(title)=="string" and title~="" then text = text.." — "..title end
    self.fishingLevelLabel:SetText(text)
end

FL_window = FL_Window()

-- Match BirdingLog: only listen for keys while the window is visible.
FL_window:SetWantsKeyEvents(false)
FL_window.VisibleChanged = function(sender,args)
    sender:SetWantsKeyEvents(sender:IsVisible())
end
FL_window.KeyDown = function(sender,args)
    if args.Action == Turbine.UI.Lotro.Action.Escape and not FL_Options.esc then
        FL_window:SetVisible(false)
    end
end
