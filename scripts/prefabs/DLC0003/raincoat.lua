
local BCHelper = require("prefabs/DLC0003/BCHelper")

local assets=
{
	Asset("ANIM", "anim/torso_rain.zip"),
}

local function init(inst)
    inst.components.equippable.insulated = true
    inst:AddComponent("waterproofer")

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_rain", "swap_body")

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

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("torso_rain")
    inst.AnimState:SetBuild("torso_rain")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.RAINCOAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end
    
    return inst
end

return Prefab( "common/inventory/raincoat", fn, assets) 
