name = "Better Clothes"
description = "Clothes do not need repair!"
author = "NightKosh"
version = "4.1.0"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 6

-- Specify compatibility with the game!
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

-- Can specify a custom icon for this mod!
icon_atlas = "BetterClothes.xml"
icon = "BetterClothes.tex"

--configs
configuration_options =
{
    {
        name = "perished_closes",
        label = "Can perishable clothes perish",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = false,
    },
    {
        name = "closes_need_repair",
        label = "Clothes need repair",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = false,
    },
    {
        name = "light_closes_perish",
        label = "Light clothes need fuel",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = true,
    },
    {
        name = "custom_hats_for_everyone",
        label = "Custom hats for everyone",
        options =
        {
            { description = "Yes", data = true },
            { description = "No", data = false },
        },
        default = true,
    },
}

return "Better Clothes"