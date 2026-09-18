-- Regression tests for the integrated FishingHelper data bridge.
dofile("Dusk/FishingLog/FL_Data.lua")
dofile("Dusk/FishingLog/FL_FR.lua")
dofile("Dusk/FishingLog/FL_HelperMap.lua")

local function count(t)
    local n=0
    for _ in ipairs(t or {}) do n=n+1 end
    return n
end

local function snapshotVendor(path)
    dofile(path)
    return {
        normal=count(datasNormalFishNames),
        rare=count(datasRareFishNames),
        wall=count(datasMountableWallFishNames),
        garbage=count(datasGarbageFishNames),
        rods=count(DatasFishingRodName),
        masters=count(DatasMasterNPC),
        quests=count(DatasFishingQuests)
    }
end

local en=snapshotVendor("Dusk/FishingLog/FH_DATA_EN.lua")
local fr=snapshotVendor("Dusk/FishingLog/FH_DATA_FR.lua")
local de=snapshotVendor("Dusk/FishingLog/FH_DATA_DE.lua")

for key,n in pairs(en) do
    assert(fr[key]==n,"FR FishingHelper length mismatch for "..key)
    assert(de[key]==n,"DE FishingHelper length mismatch for "..key)
end

assert(count(FL_HelperMap.ids.normal)==en.normal,"normal ID bridge length mismatch")
assert(count(FL_HelperMap.ids.rare)==en.rare,"rare ID bridge length mismatch")
assert(count(FL_HelperMap.ids.wall)==en.wall,"wall ID bridge length mismatch")
assert(count(FL_HelperMap.ids.garbage)==en.garbage,"garbage ID bridge length mismatch")
assert(count(FL_HelperMap.quests)==en.quests,"quest bridge length mismatch")

local mapped,total=0,0
for _,group in pairs(FL_HelperMap.ids) do
    for _,id in ipairs(group) do
        total=total+1
        if id then
            mapped=mapped+1
            assert(ID[id],"FishingHelper bridge references unknown item ID "..tostring(id))
            assert(ID[id].ln and ID[id].ln~="","mapped FR item has no canonical FishingLog name: "..id)
        end
    end
end
assert(total==87,"unexpected FishingHelper fish/junk bridge size")
assert(mapped==86,"unexpected FishingHelper mapped item count")

local questTitles={}
for _,q in ipairs(Quest or {}) do questTitles[q.t]=true end
for _,title in ipairs(FL_HelperMap.quests) do
    assert(questTitles[title],"FishingHelper quest bridge references unknown quest: "..tostring(title))
    assert(FL_QuestFR[title],"FishingHelper quest has no canonical FR title: "..tostring(title))
end

local function read(path)
    local f=assert(io.open(path,"rb"))
    local s=f:read("*a")
    f:close()
    return s
end
for _,lang in ipairs({"FR","EN","DE"}) do
    local src=read("Dusk/FishingLog/FH_DATA_"..lang..".lua")
    assert(not src:find("DatasMasterNPCCoord",1,true),"unused master map coordinates returned in "..lang)
    assert(not src:find("DatasFishingQuestsCoord",1,true),"unused quest map coordinates returned in "..lang)
end

print("FishingLog integrated helper tests: OK")
