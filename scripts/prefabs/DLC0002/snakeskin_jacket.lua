local assets=
{
	Asset("ANIM", "anim/armor_snakeskin.zip"),
}

local function init(inst)
    inst.components.equippable.insulated = true

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = TUNING.WATERPROOFNESS_LARGE

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_snakeskin", "swap_body")

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

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_snakeskin")
    inst.AnimState:SetBuild("armor_snakeskin")
    inst.AnimState:PlayAnimation("anim")
    
    MakeInventoryFloatable(inst, "idle_water", "anim")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/snakeskin_jacket"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.ARMOR_SNAKESKIN_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end
    
    return inst
end

return Prefab( "common/inventory/armor_snakeskin", fn, assets) 
