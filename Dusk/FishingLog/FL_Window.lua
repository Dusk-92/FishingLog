-- Fishing Log window handler
-- coding: utf-8 '�

import "Turbine.UI.Lotro"
import "Dusk.Common"

-- FL_Main exposes only prefixed output helpers in the shared Dusk apartment.
local print,printe = FL_Print,FL_PrintE

local labelFont = Turbine.UI.Lotro.Font.Verdana14
local foreColor = Turbine.UI.Color( 0.9, 0.9, 0 )
local whiteColor = Turbine.UI.Color( 1.0, 1.0, 1.0 )
local backColor = Turbine.UI.Color( 0.0, 0.0, 0.0 )
local greyColor = Turbine.UI.Color( 0.1, 0.1, 0.1 )
local Button = Turbine.UI.Lotro.Button
local Label = Turbine.UI.Label
local TextBox = Turbine.UI.TextBox
local CheckBox = Turbine.UI.Lotro.CheckBox
local Item = Turbine.UI.Lotro.ShortcutType.Item
local Hobby = Turbine.UI.Lotro.ShortcutType.Hobby
local Alias = Turbine.UI.Lotro.ShortcutType.Alias
local Shortcut = Turbine.UI.Lotro.Shortcut
local Quickslot = Turbine.UI.Lotro.Quickslot
local Qsize = 34
local Blank

local UI = {
    title="Fishing Log", rod="Fishing rod:", fish="Fish:", weapon="Weapon:", second="2nd:",
    setloc="Set Location", listloc="List Locations", loccatch="Loc. Catches", personal="Personal Catches",
    area="Area: none", regionfish="Area Fish", deeds="Fishing Deeds"
}
if FL_Lang=="FR" then
    UI = {
        title="Carnet de pêche", rod="Canne à pêche :", fish="Pêcher :", weapon="Arme :", second="2e :",
        setloc="Définir lieu", listloc="Liste des lieux", loccatch="Prises du lieu", personal="Mes prises",
        area="Zone : aucune", regionfish="Poissons région", deeds="Prouesses"
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

function FL_Shortcut(sender,name,iname,icat)
	local shortcut = sender:GetShortcut()
	local itemType = shortcut:GetType()
	if itemType==0 then return end
	local itemData = shortcut:GetData()
	if sender:IsAltKeyDown() then print((FL_Lang=="FR" and "Type=" or "Type=")..itemType..(FL_Lang=="FR" and ", Données=" or ", Data=")..itemData) end
	if itemType~=Item then 
		sender:SetShortcut(Blank) 
		print(FL_Lang=="FR" and (name.." réinitialisé.") or (name.." reset."))
		return 
	end
	local Item = shortcut:GetItem()
	if not Item then printe(FL_Lang=="FR" and "Objet introuvable." or "Item is null.") return end
	if sender:IsShiftKeyDown() then iname = nil; icat = nil end
	if icat then
		local info = Item:GetItemInfo()
		local category = info and info:GetCategory()
		if category ~= icat then
			printe(FL_Lang=="FR" and (Item:GetName().." n’est pas une canne à pêche valide.") or (Item:GetName().." is not a valid fishing rod."))
			sender:SetShortcut(Blank)
			return
		end
	end
	if iname and Item:GetName():sub(-#iname)~=iname then
		printe(FL_Lang=="FR" and (Item:GetName().." n’est pas un objet valide pour cet emplacement.") or (Item:GetName().." is not a "..iname))
		sender:SetShortcut(Blank)
		return
	end
	print(FL_Lang=="FR" and (name.." défini sur "..Item:GetName()) or (name.." set to "..Item:GetName()))
	return itemData
end

function FL_Window:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self )

	-- Position the window near the top center of the screen.
	self:SetSize( 340,285 )
--	self:SetBackColor( Turbine.UI.Color() )
	local pos = FL_Options.pos1 or 
		{ x=(Turbine.UI.Display.GetWidth() - self:GetWidth())/3, 
		y=(Turbine.UI.Display:GetHeight() - self:GetHeight())*.6 }
	self:SetPosition( pos.x, pos.y )
	self:SetText( UI.title )
	self:SetVisible( false )

-- Hobby:Fishing action is Type=Hobby(9), Data=0x7000EE1E

	-- Create a Name field
	self.name = self:AddField(Label, UI.rod, {x=25,y=47}, {x=90,y=16} )
	self.name:SetFont(Turbine.UI.Lotro.Font.TrajanPro18)

	-- Create an rod field
	self.rod = self:AddField(Quickslot, nil, {x=115,y=40}, {x=Qsize,y=Qsize} )
	Blank = self.rod:GetShortcut()
	if Totals.rod then self.rod:SetShortcut( Shortcut(Item,Totals.rod) ) 
	else self.rod:SetBackground("Dusk/FishingLog/Rod.tga") end
	self.rod.ShortcutChanged = function( sender, args )
		Totals.rod = FL_Shortcut(sender,FL_Lang=="FR" and "Canne à pêche" or "Fishing rod",nil,nil)
	end

	-- Create a fishing label
	self:AddField(Label, UI.fish, {x=190,y=45}, {x=45,y=16} )

	-- Create an fishing field
	self.fish = self:AddField(Quickslot, nil, {x=240,y=40}, {x=Qsize,y=Qsize} )
	self.fish:SetShortcut( Shortcut(Hobby,"0x7000EE1E") )
    self.fish:SetAllowDrop( false )
	self.fish.MouseEnter = function( sender, args ) FL_TrackHover = true end
	self.fish.MouseLeave = function( sender, args ) FL_TrackHover = false end

	-- Create a weapon label
	self:AddField(Label, UI.weapon, {x=45,y=95}, {x=70,y=16} )

	-- Create an weapon field, weapon slot=16, cat=104
	self.weapon = self:AddField(Quickslot, nil, {x=115,y=90}, {x=Qsize,y=Qsize} )
	if Totals.wpn then self.weapon:SetShortcut( Shortcut(Item,Totals.wpn) ) 
	else self.weapon:SetBackground("Dusk/FishingLog/Sword.tga") end
	self.weapon.ShortcutChanged = function( sender, args )
		Totals.wpn = FL_Shortcut(sender,FL_Lang=="FR" and "Arme" or "Weapon")
	end

	-- Create a Shield label
	self:AddField(Label, UI.second, {x=195,y=95}, {x=40,y=16} )

	-- Create an shield field, shield slot=17
	self.shield = self:AddField(Quickslot, nil, {x=240,y=90}, {x=Qsize,y=Qsize} )
	if Totals.shl then self.shield:SetShortcut( Shortcut(Item,Totals.shl) ) 
	else self.shield:SetBackground("Dusk/FishingLog/Shield.tga") end
	self.shield.ShortcutChanged = function( sender, args )
		Totals.shl = FL_Shortcut(sender,FL_Lang=="FR" and "2e emplacement" or "2nd")
	end


	-- Location button: keep the proven working LOTRO Quickslot Alias overlay.
	-- The Quickslot covers the whole button and receives the real player click.
	self.locButton = self:AddField(Button, UI.setloc, {x=30,y=140}, {x=125,y=20} )

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
    aliasBleedMask:SetPosition( 28,160 )
    aliasBleedMask:SetSize( 130,8 )
    aliasBleedMask:SetBackColor( backColor )
    aliasBleedMask:SetMouseVisible( false )
    aliasBleedMask:SetZOrder( 100 )
	-- Create a Inventory listing button
	self.listButton = self:AddField(Button, UI.listloc, {x=175,y=140}, {x=135,y=20} )
	self.listButton.Click = function( sender,args )
        FL_Command:Execute("fll","list")
	end

	-- Create a catch listing button
	self.locationCatchButton = self:AddField(Button, UI.loccatch, {x=30,y=170}, {x=125,y=20} )
	self.locationCatchButton.Click = function( sender,args )
        FL_Command:Execute("fll","last")
	end

	-- Create a catch listing button
	self.personalCatchButton = self:AddField(Button, UI.personal, {x=175,y=170}, {x=135,y=20} )
	self.personalCatchButton.Click = function( sender,args )
        FL_Command:Execute("fl","catch")
	end

    -- Fishing is not organised exactly like birding: keep spot tracking, but
    -- expose the current game area and reliable deed-fish information.
    self.areaLabel = self:AddField(Label, UI.area, {x=30,y=205}, {x=280,y=20} )
    self.areaLabel:SetForeColor( whiteColor )
    self.areaLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter )

    self.regionFishButton = self:AddField(Button, UI.regionfish, {x=30,y=235}, {x=125,y=20} )
    self.regionFishButton.Click = function( sender,args )
        FL_Command:Execute("fl","zone")
    end

    self.deedsButton = self:AddField(Button, UI.deeds, {x=175,y=235}, {x=135,y=20} )
    self.deedsButton.Click = function( sender,args )
        FL_Command:Execute("fl","deeds")
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

FL_window = FL_Window()

-- Set Escape action
FL_window:SetWantsKeyEvents( true )
FL_window.KeyDown = function(sender, args)
	if( args.Action == Turbine.UI.Lotro.Action.Escape and not FL_Options.esc ) then
		FL_window:SetVisible( false )
	-- elseif Track and args.Control then 
	-- 	FL_window.fish:MouseDown(sender, args)
	end
end
