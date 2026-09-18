import=function() end
FL_Lang="FR"
dofile("Dusk/FishingLog/FL_Number.lua")
dofile("Dusk/FishingLog/FL_Guide.lua")

local function expect(actual,expected,label)
    if actual~=expected then
        error((label or "value")..": expected "..tostring(expected)..", got "..tostring(actual))
    end
end

expect(FL_Guide.GetSkillTitle(0),nil,"no title at 0")
expect(FL_Guide.GetSkillTitle(9),nil,"no title before 10")
expect(FL_Guide.GetSkillTitle(10),"Apprenti pêcheur à la ligne","title 10")
expect(FL_Guide.GetSkillTitle(50),"Compagnon pêcheur à la ligne","title 50")
expect(FL_Guide.GetSkillTitle(100),"Expert pêcheur à la ligne","title 100")
expect(FL_Guide.GetSkillTitle(150),"Maître pêcheur à la ligne","title 150")
expect(FL_Guide.GetSkillTitle(200),"Seigneur des Ruisseaux","title 200")
expect(FL_Guide.GetSkillTitle(201),nil,"title above cap")

print("FishingLog guide tests: OK")
