local assets =
{
    Asset("ANIM", "anim/armor_slurper.zip"),
}

local function init(inst)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_slurper", "swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = TUNING.ARMORSLURPER_SLOW_HUNGER
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

local function onRepaired(inst, owner)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        onequip(inst, owner)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_slurper")
    inst.AnimState:SetBuild("armor_slurper")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("fur")
    inst:AddTag("ruins")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/fur"


    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.HUNGERBELT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(onperish)
        inst.components.fueled.ontakefuelfn = init
    else
        init(inst)
    end

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("common/inventory/armorslurper", fn, assets)
