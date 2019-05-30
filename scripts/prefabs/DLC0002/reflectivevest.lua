local assets=
{
	Asset("ANIM", "anim/torso_reflective.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
    inst.components.insulator:SetSummer()


    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_reflective", "swap_body")

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        init(inst)
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

local function create()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("reflective_vest")
    inst.AnimState:SetBuild("torso_reflective")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/trunksuit"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.REFLECTIVEVEST_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end
    
	return inst
end

return Prefab( "common/inventory/reflectivevest", create, assets)
		
