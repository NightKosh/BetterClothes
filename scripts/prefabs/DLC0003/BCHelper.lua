
local BCHelper = {}

function BCHelper:generic_onunequip(inst)
    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
        inst.components.equippable.walkspeedmult = 1
        inst.components.equippable.dapperness = 0
        inst.components.equippable.equippedmoisture = 0
        inst:RemoveComponent("insulator")
        inst:RemoveComponent("heater")
        inst:RemoveComponent("waterproofer")
        inst:RemoveComponent("windproofer")

        inst.components.equippable.insulated = false
    end
end

function BCHelper:generic_onunequip_perished(inst)
    if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
        BCHelper.generic_onunequip(inst)
    end
end

function BCHelper:stop_fuel_consuming(inst)
    if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
        inst.components.fueled:StopConsuming()
    end
end

return BCHelper
