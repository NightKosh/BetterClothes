
local BCHelper = require("prefabs/DLC0003/BCHelper")

local assets=
{
	Asset("ANIM", "anim/armor_windbreaker.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst:AddComponent("windproofer")
    inst.components.windproofer:SetEffectiveness(TUNING.WINDPROOFNESS_ABSOLUTE)
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_windbreaker", "swap_body")

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        init(inst)
    end

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    BCHelper.generic_onunequip(inst)
    BCHelper.stop_fuel_consuming(inst)
end

local function onperish(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    onunequip(inst, owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("armor_windbreaker")
    inst.AnimState:SetBuild("armor_windbreaker")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/windbreaker"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WINDBREAKER_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end
    
	return inst
end

return Prefab( "common/inventory/armor_windbreaker", fn, assets)
