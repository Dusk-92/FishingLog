-- FishingLog FR10.2 - bridge between FishingHelper list order and FishingLog item IDs.
-- The vendor data does not expose item IDs, so this stable bridge lets FishingLog
-- use its own canonical localized names while retaining FishingHelper locations/levels.

FL_HelperMap = {
    ids = {
        normal = {
            "0EF58","0EE77","0EF68","0EF5B","0EF67","0EF5E","0EF69","0EF6A","0EF5A","0EF66",
            "0EF63","0EF65","0EF60","0EF59","0EF62","0EF64","0EF61","0EF5D","0EF5F","0EF5C"
        },
        rare = {
            "0F13A","0F141","0F133","0F137","0F11E","0F12B","0F128","0F124","0F139","0F127",
            "0F142","0F132","0F130","0F11F","0F136","0F120","0F126","0F13E","0EFCF","0EFD6",
            "0EFCD","0EFD0","0EFCE","0EFD4","0EFD2","0EFD1","0EFD3"
        },
        wall = {
            "0F22E","0F229","0F226","0F22A","0F22B","0F228","0F227","0F22D","0F22C","0F173",
            "0F172","0F179","0F182","0F178","0F183","0F16F","0F17B","0F174","0F17A","0F175",
            "0F17C","0F176","0F17E","0F177","0F17D","0F181","0F180","0F170","0F17F"
        },
        garbage = {
            "0EFF3","0EFF7","0EFF4","0EFF2","0EFFA","0EFF5","0EFF1","0EFF8","0EFF6","0EFF9",
            false -- Spear head: no stable FishingLog item ID is currently known.
        }
    },

    -- Canonical English quest keys used by FL_QuestFR. FishingHelper keeps the
    -- displayed level and location; FishingLog supplies the canonical FR title.
    quests = {
        "One Fish, Two Fish",
        "Teach a Man to Fish",
        "Fish-tales",
        "Hook, Line, and Sinker",
        "Fish of the Wildwood",
        "Fish of the Wildwood",
        "Empty Larder",
        "Glinting in Forgotten Pools",
        "Cuts of Fish",
        "Terror of the Deep",
        "The Blood-fish",
        "The Garsfeld Guppy",
        "The Last Cast",
        "The Old River King",
        "Fishing on the Wharf",
        "Rhosgobel: Cleaning the Anduin",
        "Rhosgobel: Cleaning the Tributaries"
    }
}
