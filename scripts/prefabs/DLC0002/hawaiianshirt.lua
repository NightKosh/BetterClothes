local assets=
{
	Asset("ANIM", "anim/torso_hawaiian.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_hawaiian", "swap_body")

    if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
            GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        init(inst)
    end

    if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
            GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
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

    if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
            GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        generic_onunequip(inst)
        inst.components.fueled:StopConsuming()
    end
end

local function onperish(inst)
    if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:Remove()
    else
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onunequip(inst, owner)
    end
end

local function create()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("hawaiian_shirt")
    inst.AnimState:SetBuild("torso_hawaiian")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
        init(inst)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.HAWAIIANSHIRT_PERISHTIME)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(onperish)
    elseif GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.HAWAIIANSHIRT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end
    inst:AddComponent("repairable")--TODO Don't work
    inst.components.repairable.repairmaterial = "cactus_flower"
    inst.components.repairable.announcecanfix = false

    inst:AddTag("show_spoilage")
    
	return inst
end

return Prefab( "common/inventory/hawaiianshirt", create, assets)
		
