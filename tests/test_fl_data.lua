-- Regression tests for release-critical FishingLog data.
dofile("Dusk/FishingLog/FL_Data.lua")

local byTitle={}
for _,q in ipairs(Quest or {}) do byTitle[q.t]=q end

local advice=assert(byTitle["Fishing for Advice"],"Fishing for Advice missing")
assert(advice.n=="Merkhâma","Fishing for Advice NPC regression")
assert(advice.loc=="3.8s,119.0w","Fishing for Advice coordinates regression")
assert(advice.s=="Furtherholm","Fishing for Advice place regression")
assert(advice.r==5 and advice.rn=="Zír Aktar","Fishing for Advice region regression")
assert(advice.d==true,"Fishing for Advice should be daily")

local hole=assert(byTitle["The Fishing-hole"],"The Fishing-hole missing")
assert(hole.n=="Neddie Grubb","The Fishing-hole NPC regression")
assert(hole.loc=="31.2s,70.0w","The Fishing-hole coordinates regression")
assert(hole.s=="Bywater","The Fishing-hole place regression")
assert(hole.r==1 and hole.rn=="The Shire","The Fishing-hole region regression")
assert(hole.d==true,"The Fishing-hole should be daily")

print("FishingLog data tests: OK")
