if GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
    PrefabFiles = {
        "DLC0003/hats",
        "DLC0003/sweatervest",
        "DLC0003/trunkvest",
        "DLC0003/tarsuit",
        "DLC0003/beargervest",
        "DLC0003/blubbersuit",
        "DLC0003/raincoat",
        "DLC0003/reflectivevest",
        "DLC0003/snakeskin_jacket",
        "DLC0003/hawaiianshirt",
        "DLC0003/armor_slurper",
        "DLC0003/armor_windbreaker"
    }
elseif GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
    PrefabFiles = {
        "DLC0002/hats",
        "DLC0002/snakeskin_jacket",
        "DLC0002/blubbersuit",
        "DLC0002/sweatervest",
        "DLC0002/trunkvest",
        "DLC0002/reflectivevest",
        "DLC0002/hawaiianshirt",
        "DLC0002/armor_windbreaker"
    }
else
    PrefabFiles = {
        "DLC0001/hats",
        "DLC0001/sweatervest",
        "DLC0001/trunkvest",
        "DLC0001/beargervest",
        "DLC0001/raincoat",
        "DLC0001/reflectivevest",
        "DLC0001/hawaiianshirt",
        "DLC0001/armor_slurper"
    }
end


RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
RECIPE_GAME_TYPE = GLOBAL.RECIPE_GAME_TYPE

local function AddWoodlegsHat(inst)
    Recipe("woodlegshat", { Ingredient("fabric", 3), Ingredient("boneshard", 4), Ingredient("dubloon", 10) }, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
end

local function AddWathgrithrHat(inst)
    if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) or GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
        Recipe("wathgrithrhat", { Ingredient("goldnugget", 2), Ingredient("rocks", 2) }, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON)
    else
        Recipe("wathgrithrhat", { Ingredient("goldnugget", 2), Ingredient("rocks", 2) }, RECIPETABS.WAR, { SCIENCE = 2, MAGIC = 0, ANCIENT = 0 }, nil, nil, nil, nil, true)
    end
end

local function AddAllHats(inst)
    if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) or GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
        AddWoodlegsHat(inst)
    end
    AddWathgrithrHat(inst)
end

if GetModConfigData("custom_hats_for_everyone") then
    AddPrefabPostInit("wilson", AddAllHats)
    AddPrefabPostInit("waxwell", AddAllHats)
    AddPrefabPostInit("wendy", AddAllHats)
    AddPrefabPostInit("wes", AddAllHats)
    AddPrefabPostInit("willow", AddAllHats)
    AddPrefabPostInit("wolfgang", AddAllHats)
    AddPrefabPostInit("woodie", AddAllHats)
    AddPrefabPostInit("wx78", AddAllHats)
    AddPrefabPostInit("webber", AddAllHats)
    AddPrefabPostInit("wagstaff", AddAllHats)


    if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
        AddPrefabPostInit("wathgrithr", AddWoodlegsHat)

        AddPrefabPostInit("walani", AddAllHats)
        AddPrefabPostInit("warly", AddAllHats)
        AddPrefabPostInit("wilbur", AddAllHats)
        AddPrefabPostInit("woodlegs", AddWathgrithrHat)
    end

    if GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
        AddPrefabPostInit("wormwood", AddAllHats)
        AddPrefabPostInit("wilba", AddAllHats)
        AddPrefabPostInit("wheeler", AddAllHats)
    end
end


--alternative bush hat recipe
Recipe("bushhat", { Ingredient("strawhat", 1), Ingredient("rope", 1), Ingredient("dug_berrybush2", 1) }, RECIPETABS.DRESS, TECH.SCIENCE_TWO)