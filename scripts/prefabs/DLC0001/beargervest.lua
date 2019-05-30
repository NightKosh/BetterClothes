local assets =
{
    Asset("ANIM", "anim/torso_bearger.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED_LARGE

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_bearger", "swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = TUNING.ARMORBEARGER_SLOW_HUNGER
    end

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

    inst.components.equippable.insulated = false
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = 1
    end

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("torso_bearger")
    inst.AnimState:SetBuild("torso_bearger")
    inst.AnimState:PlayAnimation("anim")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.BEARGERVEST_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end

    -- Do something with fueled/ armor usage?
    -- inst:AddComponent("armor")
    -- inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
    -- inst.components.armor:SetTags({"bee"})

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("common/inventory/beargervest", fn, assets)
