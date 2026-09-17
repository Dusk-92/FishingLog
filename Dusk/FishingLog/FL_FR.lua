-- Fishing Log - French localisation overlay
-- Added by Dusk FR patch.

Cat = { C="Cuisine", G="Général", J="Camelote", Q="Quête", T="Trophée" }
Tier = { "Apprenti", "Compagnon", "Expert", "Artisan", "Maître",
    "Suprême", "Ouestfolde", "Estemnet", "Ouestemnet", "Anórien",
    "Folde du Destin", "Crevasse de fer", "Minas Ithil", "Gundabad", "Umbar" }
Prof = {"Apprenti","Compagnon","Expert","Maître"}

-- FR6: 156/159 noms officiels préchargés depuis les tables FR du client LOTRO.
-- Les 3 anciennes entrées absentes des tables actuelles restent gérées par AUTOFR.
local NamesFR = {
    ["0B0D8"] = "Mathom", -- Mathom
    ["0B0D9"] = "Mathom entretenu", -- Well-kept Mathom
    ["0EAAC"] = "Poisson huileux", -- Oily Fish
    ["0EE77"] = "Vairon", -- Minnow
    ["0EF58"] = "Cyprin", -- Goldfish
    ["0EF59"] = "Epinoche à trois épines", -- Three-spined Stickleback
    ["0EF5A"] = "Rotengle", -- Rudd
    ["0EF5B"] = "Omble", -- Charr
    ["0EF5C"] = "Bar", -- Largemouth Bass
    ["0EF5D"] = "Carpe", -- Carp
    ["0EF5E"] = "Barbeau", -- Barbel
    ["0EF5F"] = "Brochet", -- Pike
    ["0EF60"] = "Perche", -- Perch
    ["0EF61"] = "Flet", -- Flounder
    ["0EF62"] = "Epinoche", -- Nine-spined Stickleback
    ["0EF63"] = "Ombre", -- Grayling
    ["0EF64"] = "Mulet", -- Golden Mullet
    ["0EF65"] = "Corégone", -- Houting
    ["0EF66"] = "Chabot", -- Bullhead
    ["0EF67"] = "Vandoise", -- Dace
    ["0EF68"] = "Bouvière", -- Bitterling
    ["0EF69"] = "Eperlan", -- Smelt
    ["0EF6A"] = "Poisson-chat", -- Catfish
    ["0EF8A"] = "Saumon de la Baie de Forochel", -- Ice Bay Salmon
    ["0EFCD"] = "Truite à gorge coupée", -- Cutthroat Trout
    ["0EFCE"] = "Truite de lac", -- Lake Trout
    ["0EFCF"] = "Truite brune", -- Brown Trout
    ["0EFD0"] = "Truite dorée", -- Golden Trout
    ["0EFD1"] = "Truite rouge", -- Redband Trout
    ["0EFD2"] = "Truite fardée", -- Red-spotted Trout
    ["0EFD3"] = "Truite mouchetée", -- Speckled Trout
    ["0EFD4"] = "Truite arc-en-ciel", -- Rainbow Trout
    ["0EFD6"] = "Truite taureau", -- Bull Trout
    ["0EFF1"] = "Marteau rouillé", -- Rusty Hammer
    ["0EFF2"] = "Bois flottant", -- Drift-wood
    ["0EFF3"] = "Hache rouillée", -- Rusty Axe
    ["0EFF4"] = "Epée rouillée", -- Rusty Sword
    ["0EFF5"] = "Vieille botte", -- Old Boot
    ["0EFF6"] = "Dague rouillée", -- Rusty Dagger
    ["0EFF7"] = "Crâne sale", -- Dirty Skull
    ["0EFF8"] = "Boule de déchets", -- Ball of Gunk
    ["0EFF9"] = "Mauvaises herbes", -- Weeds
    ["0EFFA"] = "Masse rouillée", -- Rusty Mace
    ["0F11E"] = "Dard à nageoire verte", -- Greenfin Darter
    ["0F11F"] = "Esturgeon pâle", -- Pallid Sturgeon
    ["0F120"] = "Esturgeon à nez pelle", -- Shovelnose Sturgeon
    ["0F124"] = "Dard à nageoire rouge", -- Redfin Darter
    ["0F126"] = "Esturgeon étoilé", -- Starry Sturgeon
    ["0F127"] = "Esturgeon nain", -- Dwarf Sturgeon
    ["0F128"] = "Dard à nageoire orange", -- Orangefin Darter
    ["0F12B"] = "Dard à longue nageoire", -- Longfin Darter
    ["0F130"] = "Esturgeon de lac", -- Lake Sturgeon
    ["0F132"] = "Esturgeon vert", -- Green Sturgeon
    ["0F133"] = "Dard à nageoire écarlate", -- Bloodfin Darter
    ["0F136"] = "Esturgeon à museau court", -- Shortnose Sturgeon
    ["0F137"] = "Dard à ventre doré", -- Firebelly Darter
    ["0F139"] = "Splendide dard", -- Splendid Darter
    ["0F13A"] = "Dard rayé", -- Bandfin Darter
    ["0F13E"] = "Esturgeon blanc", -- White Sturgeon
    ["0F141"] = "Dard à nageoire noire", -- Blackfin Darter
    ["0F142"] = "Esturgeon barbu", -- Fringbarbel Sturgeon
    ["0F16F"] = "Adroit poisson-chat", -- Cunning Catfish
    ["0F170"] = "Succulent éperlan", -- Superb Smelt
    ["0F172"] = "Puissant bar", -- Big Mouth Bass
    ["0F173"] = "Beau barbeau", -- Barbarous Barbel
    ["0F174"] = "Frétillant flet", -- Fantastic Flounder
    ["0F175"] = "Prompt ombre", -- Gleaming Grayling
    ["0F176"] = "Coriace corégone", -- Huge Houting
    ["0F177"] = "Elégante épinoche", -- Nasty Nine-spined Stickleback
    ["0F178"] = "Sombre omble", -- Colourful Charr
    ["0F179"] = "Gros chabot", -- Brawny Bullhead
    ["0F17A"] = "Fin cyprin", -- Giant Goldfish
    ["0F17B"] = "Vive vandoise", -- Delightful Dace
    ["0F17C"] = "Rapide rouget", -- Great Golden Mullet
    ["0F17D"] = "Petite perche", -- Perfect Perch
    ["0F17E"] = "Long vairon", -- Magnificent Minnow
    ["0F17F"] = "Méchante épinoche à trois épines", -- Tricky Three-spined Stickleback
    ["0F180"] = "Rapide rotengle", -- Ruthless Rudd
    ["0F181"] = "Belliqueux brochet", -- Perfect Pike
    ["0F182"] = "Fière bouvière", -- Bright Bitterling
    ["0F183"] = "Courageuse carpe", -- Courageous Carp
    ["0F226"] = "Saumon de 3 kilos", -- 6-pound Salmon
    ["0F227"] = "Saumon de 15 kilos", -- 30-pound Salmon
    ["0F228"] = "Saumon de 10 kilos", -- 20-pound Salmon
    ["0F229"] = "Saumon de 2 kilos", -- 4-pound Salmon
    ["0F22A"] = "Saumon de 5 kilos", -- 10-pound Salmon
    ["0F22B"] = "Saumon de 7,5 kilos", -- 15-pound Salmon
    ["0F22C"] = "Saumon de 25 kilos", -- 50-pound Salmon
    ["0F22D"] = "Saumon de 20 kilos", -- 40-pound Salmon
    ["0F22E"] = "Saumon de 1 kilo", -- 2-pound Salmon
    ["1079A"] = "Sérioles", -- Amberjack
    ["1079B"] = "Luillim", -- Luillim
    ["1079C"] = "Malachigan", -- Drum
    ["1079E"] = "Celebhal", -- Celebhal
    ["10890"] = "Poisson de taille moyenne", -- Medium Fish
    ["10893"] = "Grand poisson", -- Large Fish
    ["10894"] = "Flets étoilés", -- Starry Flounder
    ["10895"] = "Haddock argenté", -- Silver Haddock
    ["10897"] = "Petit poisson", -- Small Fish
    ["10899"] = "Poissons rouges", -- Golden Redfish
    ["26AD3"] = "Mauvais poisson", -- Bad Fish
    ["26AD4"] = "Gros poisson", -- Big Fish
    ["26AD5"] = "Petit poisson", -- Puny Fish
    ["26B10"] = "Poisson facile", -- Easy Fish
    ["26B11"] = "Poisson simple", -- Simple Fish
    ["26B12"] = "Poisson intermédiaire", -- Possible Fish
    ["26B13"] = "Poisson difficile", -- Tricky Fish
    ["26B14"] = "Poisson rare", -- Unlikely Fish
    ["26B52"] = "Poisson pour le dîner", -- Dinner Fish
    ["29B24"] = "Relique du temps usée", -- Worn Relic of Time
    ["29B25"] = "Queue d'avanc", -- Avanc-tail
    ["2AAAA"] = "Chaise", -- Chair
    ["2AAAB"] = "Lunettes", -- Spectacles
    ["2AAAC"] = "Tasse", -- Tea-cup
    ["2AAAD"] = "Chapeau", -- Hat
    ["2AAAE"] = "Liste de biens perdus", -- List of Lost Goods
    ["2FD33"] = "Énorme poisson", -- Huge Fish
    ["2FD36"] = "Grand poisson", -- Large Fish
    ["2FD37"] = "Poisson de taille moyenne", -- Medium Fish
    ["2FD3A"] = "Poisson sanglant", -- Blood-fish
    ["2FD3B"] = "Guppy de Garsfeld", -- Garsfeld Guppy
    ["2FD79"] = "Avanc", -- Avanc
    ["3975F"] = "Vieux Roi de la rivière", -- Old River-king
    ["3F9E4"] = "Carpe de Calembel", -- Calembel Carp
    ["3F9E5"] = "Tortue du Lamedon", -- Lamedon Turtle
    ["3F9E6"] = "Saumon du Lamedon", -- Lamedon Salmon
    ["3F9E7"] = "Appât", -- Bait Fish
    ["40B63"] = "Flet", -- Flounder
    ["46C5E"] = "Cabillaud argenté", -- Silvery Pout
    ["4D546"] = "Loche", -- Loach
    ["4D547"] = "Saumon du Long Lac", -- Long Lake Salmon
    ["4D548"] = "Chevesne", -- Chub
    ["4D549"] = "Lamproie", -- Lamprey
    ["4D54A"] = "Corégone", -- Powan
    ["4D54B"] = "Sprat", -- Sprat
    ["4D54C"] = "Tonneau cassé", -- Broken Barrel
    ["4D54D"] = "Lavaret", -- Vendace
    ["4D54E"] = "Orfe", -- Orfe
    ["4D54F"] = "Loche", -- Roach
    ["4D550"] = "Chope rouillée", -- Rusty Tankard
    ["4D551"] = "Crapet-soleil", -- Pumpkinseed
    ["4D552"] = "Vieux gant", -- Old Glove
    ["4D553"] = "Grémille", -- Ruffe
    ["4D554"] = "Ablette", -- Bleak
    ["4D555"] = "Pollan", -- Pollan
    ["4D556"] = "Goujon", -- Gudgeon
    ["4D557"] = "Brème", -- Bream
    ["4D558"] = "Able", -- Sunbleak
    ["4D559"] = "Sandre", -- Zander
    ["4D55A"] = "Lotte", -- Burbot
    ["4D55B"] = "Tilapia", -- Tilapia
    ["4D55D"] = "Tanche", -- Tench
    ["59716"] = "Vairon des bois sauvages", -- Wildwood Minnow
    ["69DE3"] = "Poisson frais", -- Fresh Fish
    ["6B1E0"] = "Poisson des tréfonds", -- Deep Fish
    ["6EB9D"] = "Poisson scintillant", -- Glittering Fish
}
for id,name in pairs(NamesFR) do
    if ID[id] then ID[id].ln = name end
end

function FL_Name(id)
    local t = ID[id]
    if not t then return "?" end
    return t.ln or t.n
end


-- FR4 : données de quêtes/localités. Les 29 traductions de titres disponibles
-- proviennent du RESULTAT_A_MENVOYER extrait des fichiers FR de LOTRO.
FL_QuestFR = {
    ["Baiting the Hook"] = "Un appât sur l'hameçon",
    ["Barrel of fish"] = "Tonneau de poissons",
    ["Big Fish, Little Fish"] = "Petits poissons, gros poissons",
    ["Bounty of the Sea"] = "Les richesses de la mer",
    ["Cuts of Fish"] = "Tranches de poisson",
    ["Distaste for Vegetables"] = "Dégoût pour les légumes",
    ["Empty Larder"] = "Le garde-manger vide",
    ["Fish of the Wildwood"] = "Pêche dans les Bois sauvages",
    ["Fish-tales"] = "Histoires de pêche",
    ["Fishing for Advice"] = "Pêche aux conseils",
    ["Fishing on the Wharf"] = "Pêche sur les Quais",
    ["Fishing the Day Away"] = "Une journée à pêcher",
    ["Fishy. Very Fishy."] = "Poissons poissards.",
    ["Glinting in Forgotten Pools"] = "Ce qui brille dans les étangs oubliés",
    ["Hired Hook"] = "Hameçon à gage",
    ["Hook, Line, and Sinker"] = "Un poisson bien ferré",
    ["One Fish, Two Fish"] = "Quand mon petit poisson fait des jolis ronds",
    ["Pond, or Thief?"] = "Etang ou voleur ?",
    ["Rhosgobel: Cleaning the Anduin"] = "Rhosgobel : Nettoyer l'Anduin",
    ["Rhosgobel: Cleaning the Tributaries"] = "Rhosgobel : Nettoyer les affluents",
    ["Stocking the Pond"] = "Un étang à remplir",
    ["Teach a Man to Fish"] = "L'enseignement de la pêche",
    ["Terror of the Deep"] = "Terreur des profondeurs",
    ["The Bait Ball"] = "La boule de poissons",
    ["The Blood-fish"] = "Le poisson sanglant",
    ["The Fishing-hole"] = "Coin de pêche",
    ["The Garsfeld Guppy"] = "Le guppy de Garsfeld",
    ["The Great Mathom Fishing Swap"] = "La grande pêche d'échange de mathoms",
    ["The Last Cast"] = "Le dernier lancer",
    ["The Old River King"] = "Le vieux roi de la rivière",
    ["The Salmon Run"] = "La rivière aux saumons",
    ["Turtles in the Depths"] = "Les tortues des profondeurs",
}

FL_PlaceFR = {
    ["Bree"] = "Bree",
    ["Bywater"] = "Lèzeau",
    ["Cathlond"] = "Cathlond",
    ["Docks of Dol Amroth"] = "Quais de Dol Amroth",
    ["Dol Amroth"] = "Dol Amroth",
    ["Edoras"] = "Edoras",
    ["Galtrev"] = "Galtrev",
    ["Last Homely House"] = "Dernière Maison Simple",
    ["Michel Delving"] = "Grand'Cave",
    ["Radagast's Cottage"] = "Chaumière de Radagast",
    ["Snowbourn"] = "Neigebronne",
    ["Sûri-kylä"] = "Sûri-kylä",
    ["Tham Lumren"] = "Tham Lumren",
    ["Thorin's Hall"] = "Palais de Thorin",
    ["Trestlebridge"] = "Pont-à-Tréteaux",
}

FL_QuestRegionFR = {
    ["Bree-land"] = "Pays de Bree",
    ["Cape of Belfalas Homesteads"] = "Résidences du Cap du Belfalas",
    ["Dunland"] = "Pays de Dun",
    ["East Rohan"] = "Rohan Est",
    ["Ered Luin"] = "Ered Luin",
    ["Forochel"] = "Forochel",
    ["North Downs"] = "Hauts du Nord",
    ["Rivendell"] = "Fondcombe",
    ["The Shire"] = "Comté",
    ["Trollshaws"] = "Trouée des Trolls",
    ["Vales of Anduin"] = "Val d'Anduin",
    ["West Gondor"] = "Gondor Ouest",
    ["West Rohan"] = "Rohan Ouest",
}

FL_NoteFR = {
    ["Not available after Edoras evacuation."] = "Indisponible après l’évacuation d’Edoras.",
    ["Requires Aiding the Eastemnet (in Hytbold)"] = "Nécessite « Aider l’Estemnet » (à Hytbold).",
    ["Requires Farmers Faire Festival in progress"] = "Nécessite que la Foire des fermiers soit en cours.",
    ["Requires Gauredain defeated at Hylje-leiri"] = "Nécessite d’avoir vaincu les Gauredain à Hylje-leiri.",
    ["Requires Hard Tack Event in progress"] = "Nécessite que l’événement Rations de voyage soit en cours.",
    ["Requires Midsummer Festival in progress"] = "Nécessite que le Festival du Solstice d’été soit en cours.",
    ["Requires quest accepted, A Roadside Respite"] = "Nécessite d’avoir accepté la quête « Une halte au bord de la route ».",
    ["Requires quest, A Message from Rhosgobel"] = "Nécessite la quête « Un message de Rhosgobel ».",
    ["Requires quest, Dol Amroth - Joining the City Guard"] = "Nécessite la quête « Dol Amroth — Rejoindre la garde de la cité ».",
    ["Switch back to weapons after a catch."] = "Rééquipe les armes après une prise.",
    ["Trains fishing & free rod"] = "Enseigne la pêche et fournit une canne gratuite.",
}

function FL_QuestTitle(t) return (t and FL_QuestFR[t.t]) or (t and t.t) or "?" end
function FL_QuestPlace(t) return (t and FL_PlaceFR[t.s]) or (t and t.s) or "?" end
function FL_QuestRegion(t) return (t and FL_QuestRegionFR[t.rn]) or (t and t.rn) or "?" end
function FL_QuestNote(t) return (t and t.nt and (FL_NoteFR[t.nt] or t.nt)) or nil end
