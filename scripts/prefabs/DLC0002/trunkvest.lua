local assets=
{
	Asset("ANIM", "anim/armor_trunkvest_summer.zip"),
	Asset("ANIM", "anim/armor_trunkvest_winter.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("insulator")
end

local function init_summer(inst)
    init(inst)

    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
end

local function init_winter(inst)
    init(inst)

    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
end

local function onequip_summer(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_trunkvest_summer", "swap_body")

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        init_summer(inst)
    end
    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled:StartConsuming()
    end
end

local function onequip_winter(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_trunkvest_winter", "swap_body")

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        init_winter(inst)
    end
    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled:StartConsuming()
    end
end

local function generic_onunequip(inst)
    inst.components.equippable.walkspeedmult = 1
    inst.components.equippable.dapperness = 0
    inst.components.equippable.equippedmoisture = 0
    inst:RemoveComponent("insulator")
    inst:RemoveComponent("heater")
    inst:RemoveComponent("waterproofer")
    inst:RemoveComponent("windproofer")

    inst.components.equippable.insulated = false
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        generic_onunequip(inst)
    end
    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled:StopConsuming()
    end
end

local function onperish(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    onunequip(inst, owner)
end

local function create_common(inst)
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/trunksuit"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.TRUNKVEST_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
    end
    
    return inst
end

local function create_summer()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("armor_trunkvest_summer")
    inst.AnimState:SetBuild("armor_trunkvest_summer")

    create_common(inst)

    inst.components.equippable:SetOnEquip( onequip_summer )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled.ontakefuelfn = init_summer
    else
        init_summer(inst)
    end
    
	return inst
end

local function create_winter()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("armor_trunkvest_winter")
    inst.AnimState:SetBuild("armor_trunkvest_winter")

    create_common(inst)

    inst.components.equippable:SetOnEquip( onequip_winter )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled.ontakefuelfn = init_winter
    else
        init_winter(inst)
    end
    
	return inst
end

return Prefab( "common/inventory/trunkvest_summer", create_summer, assets),
		Prefab( "common/inventory/trunkvest_winter", create_winter, assets) 
