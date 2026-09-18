dofile("Dusk/FishingLog/FL_Number.lua")
dofile("Dusk/FishingLog/FL_Parse.lua")

local function expect(actual,expected,label)
    if actual~=expected then
        error((label or "value")..": expected "..tostring(expected)..", got "..tostring(actual))
    end
end

expect(FL_ParseFishingAdvancement(
    "Your proficiency in Fishing has increased to 28.","EN"),28,"EN exact")
expect(FL_ParseFishingAdvancement(
    "Your proficiency in Fishing has increased to 200","EN"),200,"EN no period")
expect(FL_ParseFishingAdvancement(
    "X Your proficiency in Fishing has increased to 28.","EN"),nil,"EN prefix rejected")
expect(FL_ParseFishingAdvancement(
    "Your proficiency in Fishing has increased to 201.","EN"),nil,"EN cap")
expect(FL_ParseFishingAdvancement(
    "Votre maîtrise de pêche a augmenté à 28.","FR"),28,"FR single number")
expect(FL_ParseFishingAdvancement(
    "Pêche : progression 28 sur 200.","FR"),nil,"FR multiple numbers rejected")
expect(FL_ParseFishingAdvancement(
    "Angeln Fertigkeit erhöht auf 77.","DE"),77,"DE single number")
expect(FL_ParseFishingAdvancement(
    "Une compétence a augmenté à 28.","FR"),nil,"FR fishing keyword required")

local normal="<Examine:IIDDID:0x0000000000000000:0x7000F124>[Redfin Darter]<\\Examine>"
local id,name=FL_ExtractIIDDID("You have acquired: "..normal..".")
expect(id,"0F124","normal loot ID")
expect(name,"Redfin Darter","normal loot name")

local carry="Gathered "..normal.." into the Fish Carry-all."
id,name=FL_ExtractIIDDID(carry)
expect(id,"0F124","Carry-all Gathered ID")
expect(name,"Redfin Darter","Carry-all Gathered name")

print("FishingLog parsing tests: OK")
