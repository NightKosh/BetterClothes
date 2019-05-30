function MakeHat(name)

    local fname = "hat_" .. name
    local symname = name .. "hat"
    local texture = symname .. ".tex"
    local prefabname = symname
    local assets =
    {
        Asset("ANIM", "anim/" .. fname .. ".zip"),
        --Asset("IMAGE", texture),
    }

    if name == "miner" then
        table.insert(assets, Asset("ANIM", "anim/hat_miner_off.zip"))
    end

    if name == "slurtle" then
        table.insert(assets, Asset("INV_IMAGE", "slurtlehat"))
    end

    -- if name == "eureka" then
    -- 	table.insert(assets, Asset("ANIM", "anim/hat_eureka_off.zip"))
    -- end

    if name == "mole" then
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_on_cc.tex"))
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_off_cc.tex"))
    end

    local function generic_perish(inst)
        generic_onunequip(inst)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and inst.components.fueled then
            inst.components.fueled:StopConsuming()
        end
    end

    local function onequip(inst, owner, fname_override)
        local build = fname_override or fname
        owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()
        end
    end


    local function generic_onunequip(inst)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            inst.components.equippable.walkspeedmult = 1
            inst.components.equippable.dapperness = 0
            inst.components.equippable.equippedmoisture = 0
            inst.durabilitymultiplier = 1
            inst:RemoveComponent("insulator")
            inst:RemoveComponent("heater")
            inst:RemoveComponent("waterproofer")
            inst:RemoveComponent("windproofer")

            inst.components.equippable.insulated = false
            inst.components.equippable.poisongasblocker = false
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()
        end
    end

    local function generic_perish(inst)
        generic_onunequip(inst)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and inst.components.fueled then
            inst.components.fueled:StopConsuming()
        end
    end

    local function perishable_onunequip(inst, owner)
        if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
                GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            generic_perish(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onunequip(inst, owner)
    end

    -- For flowers, melon, ice and some another
    local function perishable_perish(inst, owner)
        if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:Remove()
        end
    end

    local function other_perish(inst)
        inst:Remove()
    end

    local function generic_repaired(inst, owner)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            onequip(inst, owner)
        end
    end

    local function opentop_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")

        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end
    end


    local function simple(onequip_handler, onunequip_handler)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        if name ~= "double_umbrella" and name ~= "aerodynamic" then
            -- gas mask is different
            inst.AnimState:SetBank(symname)
            inst.AnimState:SetBuild(fname)
            inst.AnimState:PlayAnimation("anim")
        end

        MakeInventoryFloatable(inst, "idle_water", "anim")

        inst:AddTag("hat")

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

        if (onequip_handler) then
            inst.components.equippable:SetOnEquip(onequip_handler)
        else
            inst.components.equippable:SetOnEquip(onequip)
        end

        if (onunequip_handler) then
            inst.components.equippable:SetOnUnequip(onunequip_handler)
        else
            inst.components.equippable:SetOnUnequip(onunequip)
        end

        return inst
    end

    local function straw_init(inst)
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
    end

    local function straw_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            straw_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function straw()
        local inst = simple(straw_onequip, generic_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.STRAWHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = straw_init
        else
            straw_init(inst)
        end

        return inst
    end

    local function bee()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
        inst.components.armor:SetTags({ "bee" })
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
        return inst
    end

    local function earmuffs_init(inst)
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
        inst.components.equippable:SetOnEquip(opentop_onequip)
    end

    local function earmuffs_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            earmuffs_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function earmuffs()
        local inst = simple(earmuffs_onequip, generic_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = earmuffs_init
        else
            earmuffs_init(inst)
        end
        inst.AnimState:SetRayTestOnBB(true)
        return inst
    end

    local function winter_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
    end

    local function winter_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            winter_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function winter()
        local inst = simple(winter_onequip, generic_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.WINTERHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = winter_init
        else
            winter_init(inst)
        end

        return inst
    end

    local function football()
        local inst = simple()
        inst:AddComponent("armor")

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
        return inst
    end

    local function ruinshat_proc(inst, owner)
        inst:AddTag("forcefield")
        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        local fx = SpawnPrefab("forcefieldfx")
        fx.entity:SetParent(owner.entity)
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
        end
        fx:ListenForEvent("blocked", fx_hitanim, owner)

        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner then
                local sanity = owner.components.sanity
                if sanity then
                    local unsaneness = damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY
                    sanity:DoDelta(-unsaneness, false)
                end
            end
        end

        inst.active = true

        owner:DoTaskInTime(--[[Duration]] TUNING.ARMOR_RUINSHAT_DURATION, function()
            fx:RemoveEventCallback("blocked", fx_hitanim, owner)
            fx.kill_fx(fx)
            if inst:IsValid() then
                inst:RemoveTag("forcefield")
                inst.components.armor.ontakedamage = nil
                inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
                owner:DoTaskInTime(--[[Cooldown]] TUNING.ARMOR_RUINSHAT_COOLDOWN, function() inst.active = false end)
            end
        end)
    end

    local function tryproc(inst, owner)
        if not inst.active and math.random() < --[[ Chance to proc ]] TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
            ruinshat_proc(inst, owner)
        end
    end

    local function ruins_onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        owner:RemoveEventCallback("attacked", inst.procfn)
    end

    local function ruins_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")
        inst.procfn = function() tryproc(inst, owner) end
        owner:ListenForEvent("attacked", inst.procfn)
    end

    local function ruins()
        local inst = simple()
        inst:AddComponent("armor")
        inst:AddTag("metal")
        inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, TUNING.ARMOR_RUINSHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(ruins_onequip)
        inst.components.equippable:SetOnUnequip(ruins_onunequip)

        return inst
    end

    local function feather_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    end

    local function feather_equip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            feather_init(inst)
        end
        onequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY_FEATHERHAT)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX_FEATHERHAT)
        end
    end

    local function feather_unequip(inst, owner)
        generic_onunequip(inst)
        onunequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX)
        end
    end

    local function feather()
        local inst = simple()

        inst.components.equippable:SetOnEquip(feather_equip)
        inst.components.equippable:SetOnUnequip(feather_unequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.FEATHERHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = feather_init
        else
            feather_init(inst)
        end

        return inst
    end

    local function beefalo_init(inst)
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    end

    local function beefalo_equip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            beefalo_init(inst)
        end
        onequip(inst, owner)
        owner:AddTag("beefalo")
    end

    local function beefalo_unequip(inst, owner)
        generic_onunequip(inst)
        onunequip(inst, owner)
        owner:RemoveTag("beefalo")
    end

    local function beefalo()
        local inst = simple()
        inst.components.equippable:SetOnEquip(beefalo_equip)
        inst.components.equippable:SetOnUnequip(beefalo_unequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = beefalo_init
        else
            beefalo_init(inst)
        end

        return inst
    end

    local function walrus_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
    end

    local function walrus_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            walrus_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function walrus()
        local inst = simple(walrus_onequip, generic_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = walrus_init
        else
            walrus_init(inst)
        end

        return inst
    end

    local function miner_turnon(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) and inst.components.fueled:IsEmpty() then
            if owner then
                onequip(inst, owner, "hat_miner_off")
            end
        else
            if owner then
                onequip(inst, owner)
            end

            if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) then
                inst.components.fueled:StartConsuming()
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/minerhatAddFuel")
            inst.Light:Enable(true)
        end
    end

    local function miner_turnoff(inst, ranout)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            if owner then
                onequip(inst, owner, "hat_miner_off")
            end
        end

        if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) then
            inst.components.fueled:StopConsuming()
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/minerhatOut")

        inst.Light:Enable(false)
    end

    local function miner_equip(inst, owner)
        miner_turnon(inst)
    end

    local function miner_unequip(inst, owner)
        onunequip(inst, owner)
        miner_turnoff(inst)
    end

    local function miner_perish(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner then
            owner:PushEvent("torchranout", { torch = inst })
        end
        miner_turnoff(inst)
    end

    local function miner_drop(inst)
        miner_turnoff(inst)
    end

    local function miner_takefuel(inst)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            miner_turnon(inst)
        end
    end

    local function miner()
        local inst = simple()

        inst.entity:AddSoundEmitter()

        local light = inst.entity:AddLight()
        light:SetFalloff(0.4)
        light:SetIntensity(.7)
        light:SetRadius(2.5)
        light:SetColour(180 / 255, 195 / 255, 150 / 255)
        light:Enable(false)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.inventoryitem:SetOnDroppedFn(miner_drop)
        inst.components.equippable:SetOnEquip(miner_equip)
        inst.components.equippable:SetOnUnequip(miner_unequip)

        if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "CAVE"
            inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
            inst.components.fueled:SetDepletedFn(miner_perish)
            inst.components.fueled.ontakefuelfn = miner_takefuel
            inst.components.fueled.accepting = true
        end

        return inst
    end


    local function spider_disable(inst)
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then

            if not owner:HasTag("spiderwhisperer") then --Webber has to stay a monster.
            owner:RemoveTag("monster")

            for k, v in pairs(owner.components.leader.followers) do
                if k:HasTag("spider") and k.components.combat then
                    k.components.combat:SuggestTarget(owner)
                end
            end
            owner.components.leader:RemoveFollowersByTag("spider")
            else
                owner.components.leader:RemoveFollowersByTag("spider", function(follower)
                    if follower and follower.components.follower then
                        if follower.components.follower:GetLoyaltyPercent() > 0 then
                            return false
                        else
                            return true
                        end
                    end
                end)
            end
        end
    end

    local function spider_update(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            local x, y, z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, TUNING.SPIDERHAT_RANGE, { "spider" })
            for k, v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end

    local function spider_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            owner:AddTag("monster")
        end
        inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)
    end

    local function spider_init(inst)
        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    end

    local function spider_equip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            spider_init(inst)
        end
        onequip(inst, owner)
        spider_enable(inst)
    end

    local function spider_unequip(inst, owner)
        generic_onunequip(inst)
        if not owner then
            owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        end
        onunequip(inst, owner)
        spider_disable(inst)
    end

    local function spider_perish(inst, owner)
        spider_unequip(inst, owner)
    end

    local function spider()
        local inst = simple()

        inst.components.inventoryitem:SetOnDroppedFn(spider_disable)
        inst.components.equippable:SetOnEquip(spider_equip)
        inst.components.equippable:SetOnUnequip(spider_unequip)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(spider_perish)
            inst.components.fueled.ontakefuelfn = spider_init
        else
            spider_init(inst)
        end

        return inst
    end

    local function top_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    end

    local function top_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            top_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function top()
        local inst = simple(top_onequip, generic_onunequip)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = top_init
        else
            top_init(inst)
        end

        return inst
    end

    local function stopusingbush(inst, data)
        local hat = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and not (data.statename == "hide_idle" or data.statename == "hide") then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function onequipbush(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end

        inst:ListenForEvent("newstate", stopusingbush, owner)
    end

    local function onunequipbush(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()
        end

        inst:RemoveEventCallback("newstate", stopusingbush, owner)
    end

    local function onusebush(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.sg:GoToState("hide")
        end
    end

    local function bush()
        local inst = simple()

        inst:AddTag("hide")
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/bushhat"

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(onusebush)

        inst.components.equippable:SetOnEquip(onequipbush)
        inst.components.equippable:SetOnUnequip(onunequipbush)

        return inst
    end

    local function flower_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
    end

    local function flower_onequip(inst, owner)
        if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
                GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            flower_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        opentop_onequip(inst, owner)
    end

    local function flower()
        local inst = simple(flower_onequip, perishable_onunequip)

        inst:AddTag("show_spoilage")

        if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
            flower_init(inst)

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
            inst.components.perishable:StartPerishing()
            inst.components.perishable:SetOnPerishFn(perishable_perish)
        elseif GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.PERISH_FAST)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = flower_init
            --            inst:AddTag("no_sewing")--TODO
        else
            flower_init(inst)
        end
        inst:AddComponent("repairable") --TODO Don't work
        inst.components.repairable.repairmaterial = "petals"
        inst.components.repairable.announcecanfix = false
        return inst
    end

    local function slurtle()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMOR_SLURTLEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function wathgrithr()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        if not GetModConfigData("custom_hats_for_everyone", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("characterspecific")
            inst.components.characterspecific:SetOwner("wathgrithr")
        end

        return inst
    end

    local function ice_init(inst)
        inst:AddComponent("heater")
        inst.components.heater.iscooler = true
        inst.components.heater.equippedheat = TUNING.ICEHAT_COOLER

        inst.components.equippable.walkspeedmult = TUNING.ICE_HAT_SPEED_MULT
        inst.components.equippable.equippedmoisture = 1

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer.effectiveness = 0
    end

    local function ice_onequip(inst, owner)
        if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
                GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            ice_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function ice()
        local inst = simple(ice_onequip, perishable_onunequip)

        inst.components.equippable.maxequippedmoisture = 49 -- Meter reading rounds up, so set 1 below

        if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
            ice_init(inst)

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
            inst.components.perishable:StartPerishing()
            inst.components.perishable:SetOnPerishFn(function(inst, owner)
                local player = GetPlayer()
                if inst.components.inventoryitem and player and inst.components.inventoryitem:IsHeldBy(player) then
                    if player.components.moisture then
                        player.components.moisture:DoDelta(20)
                    end
                end
                perishable_perish(inst, owner)
            end)
        elseif GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.PERISH_FAST)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = ice_init
            --            inst:AddTag("no_sewing")--TODO
        else
            ice_init(inst)
        end
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = "ICE"
        inst.components.repairable.announcecanfix = false

        inst:AddTag("show_spoilage")
        inst:AddTag("frozen")

        return inst
    end

    local function mole_onequip(inst, owner)
        onequip(inst, owner)
        if owner ~= GetPlayer() then return end
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
        if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
            GetClock():SetNightVision(true)
            if GetClock():IsDay() and not GetWorld():IsCave() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_off_cc.tex", .25)
            else -- Dusk and Night
            GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", .25)
            end
        end
    end

    local function mole_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner ~= GetPlayer() then return end
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
        if GetClock() then
            GetClock():SetNightVision(false)
        end
        if GetWorld() and GetWorld().components.colourcubemanager then
            GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
        end
    end

    local function mole_perish(inst)
        if inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and inst.components.equippable and inst.components.equippable:IsEquipped() then
            if GetClock() then
                GetClock():SetNightVision(false)
            end
            if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
            end
        end
        if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) then
            other_perish(inst)
        else
            generic_perish(inst)
        end
    end

    local function mole()
        local inst = simple()
        inst.components.equippable:SetOnEquip(mole_onequip)
        inst.components.equippable:SetOnUnequip(mole_onunequip)

        if GetModConfigData("light_closes_perish", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "MOLEHAT"
            inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(mole_perish)
            inst.components.fueled.accepting = true
            inst:AddTag("no_sewing")
        end

        inst:ListenForEvent("daytime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and not GetWorld():IsCave() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_off_cc.tex", 2)
            end
        end, GetWorld())
        inst:ListenForEvent("dusktime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", 2)
            end
        end, GetWorld())
        inst:ListenForEvent("nighttime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", 2)
            end
        end, GetWorld())

        return inst
    end

    local function rain_init(inst)
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true
    end

    local function rain_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            rain_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function rain()
        local inst = simple(rain_onequip, generic_onunequip)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.RAINHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = rain_init
        else
            rain_init(inst)
        end

        return inst
    end

    local function snakeskin_init(inst)
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true
    end

    local function snakeskin_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            snakeskin_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function snakeskin()
        local inst = simple(rain_onequip, generic_onunequip)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.SNAKESKINHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = snakeskin_init
        else
            snakeskin_init(inst)
        end

        return inst
    end

    local function eyebrella_updatesound(inst)
        local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
        if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
            if soundShouldPlay then
                inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound")
            else
                inst.SoundEmitter:KillSound("umbrellarainsound")
            end
        end
    end

    local function eyebrella_init(inst)
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true
    end

    local function eyebrella_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            eyebrella_init(inst)
        end
        opentop_onequip(inst, owner)
        eyebrella_updatesound(inst)

        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    local function eyebrella_onunequip(inst, owner)
        generic_onunequip(inst)
        onunequip(inst, owner)
        eyebrella_updatesound(inst)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end

    local function eyebrella_perish(inst)
        inst.SoundEmitter:KillSound("umbrellarainsound")
        if inst.components.inventoryitem and inst.components.inventoryitem.owner then
            inst.components.inventoryitem.owner.DynamicShadow:SetSize(1.3, 0.6)
        end
        generic_perish(inst)
    end

    local function eyebrella()
        local inst = simple()

        inst.entity:AddSoundEmitter()

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.EYEBRELLA_PERISHTIME)
            inst.components.fueled:SetDepletedFn(eyebrella_perish)
            inst.components.fueled.ontakefuelfn = eyebrella_init
        else
            eyebrella_init(inst)
        end

        inst.components.equippable:SetOnEquip(eyebrella_onequip)
        inst.components.equippable:SetOnUnequip(eyebrella_onunequip)

        inst:ListenForEvent("rainstop", function() eyebrella_updatesound(inst) end, GetWorld())
        inst:ListenForEvent("rainstart", function() eyebrella_updatesound(inst) end, GetWorld())

        return inst
    end

    local function catcoon_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
    end

    local function catcoon_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            catcoon_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function catcoon()
        local inst = simple(catcoon_onequip, generic_onunequip)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.CATCOONHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = catcoon_init
        else
            catcoon_init(inst)
        end

        return inst
    end

    local function watermelon_init(inst)
        inst.components.equippable.equippedmoisture = 0.5

        inst:AddComponent("heater")
        inst.components.heater.iscooler = true
        inst.components.heater.equippedheat = TUNING.WATERMELON_COOLER

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        inst.components.insulator:SetSummer()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL
    end

    local function watermelon_onequip(inst, owner)
        if not GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) and
                GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            watermelon_init(inst)
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        onequip(inst, owner)
    end

    local function watermelon()
        local inst = simple(watermelon_onequip, perishable_onunequip)

        inst.components.equippable.maxequippedmoisture = 32 -- Meter reading rounds up, so set 1 below


        if GetModConfigData("perished_closes", KnownModIndex:GetModActualName("Better Clothes")) then
            watermelon_init(inst)

            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
            inst.components.perishable:StartPerishing()
            inst.components.perishable:SetOnPerishFn(perishable_perish)

            inst:AddTag("icebox_valid")
        elseif GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.PERISH_SUPERFAST)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = watermelon_init
            --            inst:AddTag("no_sewing")--TODO
        else
            watermelon_init(inst)
        end
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = "ICE"
        inst.components.repairable.announcecanfix = false

        inst:AddTag("show_spoilage")

        inst:AddTag("icebox_valid")

        return inst
    end

    local function captain_init(inst)
        inst.durabilitymultiplier = 2
    end

    local function captain_onequip(inst, owner, fname_override)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            captain_init(inst)
        end

        if owner.components.driver then
            owner.components.driver.durabilitymultiplier = inst.durabilitymultiplier
        end

        local build = fname_override or fname
        owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end
        onequip(inst, owner)
    end

    local function captain_onunequip(inst, owner, fname_override)
        generic_onunequip(inst)
        if owner.components.driver then
            owner.components.driver.durabilitymultiplier = 1
        end
    end

    local function captain_perish(inst)
        if owner.components.driver then
            owner.components.driver.durabilitymultiplier = 1
        end
        generic_perish(inst)
    end

    local function captain()
        local inst = simple()

        inst.components.equippable:SetOnEquip(captain_onequip)
        inst.components.equippable:SetOnUnequip(captain_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.CAPTAINHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(captain_perish)
            inst.components.fueled.ontakefuelfn = captain_init
        else
            captain_init(inst)
        end

        return inst
    end

    local function pirate_onmountboat(inst, data)
        inst.components.farseer:AddBonus("piratehat", TUNING.MAPREVEAL_PIRATEHAT_BONUS)
    end

    local function pirate_ondismountboat(inst, data)
        inst.components.farseer:RemoveBonus("piratehat")
    end

    local function pirate_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    end

    local function pirate_onequip(inst, owner, fname_override)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            pirate_init(inst)
        end
        if owner:HasTag("player") then
            if owner.components.farseer then
                local boating = false
                if owner.components.driver and owner.components.driver:GetIsDriving() then
                    boating = true
                end
                if not boating then
                    owner.components.farseer:AddBonus("piratehat", TUNING.MAPREVEAL_NO_BONUS)
                else
                    owner.components.farseer:AddBonus("piratehat", TUNING.MAPREVEAL_PIRATEHAT_BONUS)
                end

                inst:ListenForEvent("mountboat", pirate_onmountboat, owner)
                inst:ListenForEvent("dismountboat", pirate_ondismountboat, owner)
            end
        end
        onequip(inst, owner)
    end

    local function pirate_onunequip(inst, owner, fname_override)
        generic_onunequip(inst)

        if owner:HasTag("player") then
            if owner.components.farseer then
                owner.components.farseer:RemoveBonus("piratehat")

                inst:RemoveEventCallback("mountboat", pirate_onmountboat, owner)
                inst:RemoveEventCallback("dismountboat", pirate_ondismountboat, owner)
            end
        end
    end

    local function pirate()
        local inst = simple()

        inst.components.equippable:SetOnEquip(pirate_onequip)
        inst.components.equippable:SetOnUnequip(pirate_onunequip)

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.PIRATEHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = pirate_init
        else
            pirate_init(inst)
        end

        return inst
    end

    local function gas_init(inst)
        inst.components.equippable.poisongasblocker = true
    end

    local function gas()
        local inst = simple()

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.GASHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = gas_init
        else
            gas_init(inst)
        end

        return inst
    end

    local function aerodynamic_init(inst)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        inst.components.equippable.walkspeedmult = TUNING.AERODYNAMICHAT_SPEED_MULT

        inst:AddComponent("windproofer")
        inst.components.windproofer:SetEffectiveness(TUNING.WINDPROOFNESS_MED)
    end

    local function aerodynamic()
        local inst = simple()
        inst.AnimState:SetBank("hat_aerodynamic")
        inst.AnimState:SetBuild("hat_aerodynamic")
        inst.AnimState:PlayAnimation("anim")

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.AERODYNAMICHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled.ontakefuelfn = aerodynamic_init
        else
            aerodynamic_init(inst)
        end

        return inst
    end

    local function double_umbrella_updatesound(inst)
        local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
        if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
            if soundShouldPlay then
                inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound")
            else
                inst.SoundEmitter:KillSound("umbrellarainsound")
            end
        end
    end

    local function double_umbrella_init(inst)
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true
    end

    local function double_umbrella_onequip(inst, owner)
        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) and not inst.components.fueled:IsEmpty() then
            double_umbrella_init(inst)
        end
        owner.AnimState:OverrideSymbol("swap_hat", "hat_double_umbrella", "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")

        double_umbrella_updatesound(inst)

        owner.DynamicShadow:SetSize(2.2, 1.4)
        onequip(inst, owner)
    end

    local function double_umbrella_onunequip(inst, owner)
        onunequip(inst, owner)
        double_umbrella_updatesound(inst)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end

    local function double_umbrella_perish(inst)
        inst.SoundEmitter:KillSound("umbrellarainsound")
        if inst.components.inventoryitem and inst.components.inventoryitem.owner then
            inst.components.inventoryitem.owner.DynamicShadow:SetSize(1.3, 0.6)
        end
        generic_perish(inst)
    end

    local function double_umbrella()
        local inst = simple()

        inst.AnimState:SetBank("hat_double_umbrella")
        inst.AnimState:SetBuild("hat_double_umbrella")
        inst.AnimState:PlayAnimation("anim")

        inst.entity:AddSoundEmitter()

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.DOUBLE_UMBRELLA_PERISHTIME)
            inst.components.fueled:SetDepletedFn(double_umbrella_perish)
            inst.components.fueled.ontakefuelfn = double_umbrella_init
        else
            double_umbrella_init(inst)
        end

        inst.components.equippable:SetOnEquip(double_umbrella_onequip)
        inst.components.equippable:SetOnUnequip(double_umbrella_onunequip)

        inst:ListenForEvent("rainstop", function() double_umbrella_updatesound(inst) end, GetWorld())
        inst:ListenForEvent("rainstart", function() double_umbrella_updatesound(inst) end, GetWorld())

        return inst
    end

    local function shark_teeth_onequip(inst, owner)
        opentop_onequip(inst, owner)

        if owner.components.driver then
            inst:ListenForEvent("mountboat", inst.onmountboat, owner)
            inst:ListenForEvent("dismountboat", inst.ondismountboat, owner)
        end
    end

    local function shark_teeth_onunequip(inst, owner)
        onunequip(inst, owner)

        if owner.components.driver then
            inst:RemoveEventCallback("mountboat", inst.onmountboat, owner)
            inst:RemoveEventCallback("dismountboat", inst.ondismountboat, owner)
        end
    end

    local function shark_teeth()
        local inst = simple()

        inst.AnimState:SetBank("hat_shark_teeth")
        inst.AnimState:SetBuild("hat_shark_teeth")
        inst.AnimState:PlayAnimation("anim")

        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.SHARK_HAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            --            inst.components.fueled.ontakefuelfn = rain_init
        else
            --            rain_init(inst)
        end

        inst.components.equippable:SetOnEquip(shark_teeth_onequip)
        inst.components.equippable:SetOnUnequip(shark_teeth_onunequip)

        local function shark_teeth_onmountboat(player, data)
            inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
        end

        local function shark_teeth_ondismountboat(player, data)
            inst.components.equippable.dapperness = 0
        end

        inst.onmountboat = shark_teeth_onmountboat
        inst.ondismountboat = shark_teeth_ondismountboat

        return inst
    end

    local function brainjelly_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end

        if owner.components.builder then
            owner.components.builder.jellybrainhat = true
            owner:PushEvent("techlevelchange")
            owner:PushEvent("unlockrecipe")
            inst.brainjelly_onbuild = function()
                inst.components.finiteuses:Use(1)
            end
            owner:ListenForEvent("builditem", inst.brainjelly_onbuild)
            owner:ListenForEvent("bufferbuild", inst.brainjelly_onbuild)
        end
    end

    local function brainjelly_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner.components.builder then
            owner.components.builder.jellybrainhat = false
            owner:PushEvent("techlevelchange")
            owner:PushEvent("unlockrecipe")
            owner:RemoveEventCallback("builditem", inst.brainjelly_onbuild)
            owner:RemoveEventCallback("bufferbuild", inst.brainjelly_onbuild)
            inst.brainjelly_onbuild = nil
        end
    end

    local function brainjelly()
        local inst = simple()

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(4)
        inst.components.finiteuses:SetPercent(1)
        inst.components.finiteuses.onfinished = function() inst:Remove() end

        inst.components.equippable:SetOnEquip(brainjelly_onequip)
        inst.components.equippable:SetOnUnequip(brainjelly_onunequip)

        return inst
    end

    local function woodlegs_spawntreasure(new_sec, old_sec, inst, isload)
        if isload then
            return
        end

        local equipper = inst and inst.components.equippable and inst.components.equippable.equipper

        if equipper and not equipper:HasTag("player") and math.random() > 0.66 then
            --don't always give treasure if not the player.
            return
        end

        local pos = inst:GetPosition()
        local offset = FindGroundOffset(pos, math.random() * 2 * math.pi, math.random(25, 30), 18)

        if offset then
            local spawn_pos = pos + offset
            local tile = GetVisualTileType(spawn_pos:Get())
            local is_water = GetMap():IsWater(tile)
            local treasure = SpawnPrefab("buriedtreasure")

            treasure.Transform:SetPosition(spawn_pos:Get())
            treasure:SetRandomTreasure()

            if equipper then
                inst.components.equippable.equipper:PushEvent("treasureuncover")
            end
        end
    end

    local function woodlegs()
        local inst = simple()

--        if GetModConfigData("closes_need_repair", KnownModIndex:GetModActualName("Better Clothes")) then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = "USAGE"
            inst.components.fueled:InitializeFuelLevel(TUNING.WOODLEGSHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(generic_perish)
            inst.components.fueled:SetSections(TUNING.WOODLEGSHAT_TREASURES)
            inst.components.fueled:SetSectionCallback(woodlegs_spawntreasure)
            --            inst.components.fueled.ontakefuelfn = rain_init
--        else
            --            rain_init(inst)
--        end

		if not GetModConfigData("custom_hats_for_everyone", KnownModIndex:GetModActualName("Better Clothes")) then
	        inst:AddComponent("characterspecific")
	        inst.components.characterspecific:SetOwner("woodlegs")
	    end
        
        return inst
    end

    local function ox()
        local inst = simple()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_OXHAT, TUNING.ARMOR_OXHAT_ABSORPTION)

        inst.components.equippable.poisonblocker = true

        return inst
    end

    local EUREKAHAT_STATES =
    {
        ON = "",
        OFF = "_off",
    }

    local function eurekahat_turnon(inst)
        inst.hatstate = EUREKAHAT_STATES.ON
        if inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem.owner
            owner.AnimState:OverrideSymbol("swap_hat", fname .. inst.hatstate, "swap_hat")
        end
        inst.components.timer:StartTimer("turnoff", TUNING.SEG_TIME * 0.5)
        inst.Light:Enable(true)
        inst.components.inventoryitem:ChangeImageName("lantern_lit")
    end

    local function eurekahat_turnoff(inst)
        inst.hatstate = EUREKAHAT_STATES.OFF
        if inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem.owner
            owner.AnimState:OverrideSymbol("swap_hat", fname .. inst.hatstate, "swap_hat")
        end
        inst.Light:Enable(false)
        inst.components.inventoryitem:ChangeImageName("lantern")
    end

    local function eurekahat_timerdonefn(inst, data)
        if data.name == "turnoff" then
            eurekahat_turnoff(inst)
        end
    end

    local function eureka_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname .. inst.hatstate, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end

        if inst.hatstate == EUREKAHAT_STATES.ON then
            inst.Light:Enable(true)
        else
            inst.Light:Enable(false)
        end

        if owner.components.builder then
            inst.eureka_onbuild = function(builder, data)
                local recname = (data and data.recipe and data.recipe.name) or nil
                if recname and not owner.components.builder:KnowsRecipe(recname) then
                    inst.components.finiteuses:Use(1)
                    eurekahat_turnon(inst)
                end
            end
            owner:ListenForEvent("builditem", inst.eureka_onbuild)
            owner:ListenForEvent("bufferbuild", inst.eureka_onbuild)
        end
    end

    local function eureka_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner.components.builder then
            owner:RemoveEventCallback("builditem", inst.eureka_onbuild)
            owner:RemoveEventCallback("bufferbuild", inst.eureka_onbuild)
            inst.eureka_onbuild = nil
        end
    end

    local function eureka_checklight(inst)
        if inst.hatstate == EUREKAHAT_STATES.ON then
            inst.Light:Enable(true)
        else
            inst.Light:Enable(false)
        end
    end

    local function eureka()
        local inst = simple()

        inst.entity:AddSoundEmitter()

        local light = inst.entity:AddLight()
        light:SetIntensity(.7)
        light:SetFalloff(0.4)
        light:SetRadius(2.5)
        light:SetColour(180 / 255, 195 / 255, 150 / 255)
        light:Enable(false)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(5)
        inst.components.finiteuses:SetPercent(1)
        inst.components.finiteuses.onfinished = function() inst:Remove() end

        inst.components.inventoryitem:SetOnDroppedFn(eureka_checklight)
        inst.components.inventoryitem:SetOnPutInInventoryFn(eureka_checklight)

        inst.hatstate = EUREKAHAT_STATES.OFF

        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", eurekahat_timerdonefn)

        inst.components.equippable:SetOnEquip(eureka_onequip)
        inst.components.equippable:SetOnUnequip(eureka_onunequip)

        return inst
    end

    local fn = nil
    local prefabs = nil
    if name == "bee" then
        fn = bee
    elseif name == "straw" then
        fn = straw
    elseif name == "top" then
        fn = top
    elseif name == "feather" then
        fn = feather
    elseif name == "football" then
        fn = football
    elseif name == "flower" then
        fn = flower
    elseif name == "spider" then
        fn = spider
    elseif name == "miner" then
        fn = miner
        prefabs =
        {
            "strawhat",
        }
    elseif name == "earmuffs" then
        fn = earmuffs
    elseif name == "winter" then
        fn = winter
    elseif name == "beefalo" then
        fn = beefalo
    elseif name == "bush" then
        fn = bush
    elseif name == "walrus" then
        fn = walrus
    elseif name == "slurtle" then
        fn = slurtle
    elseif name == "ruins" then
        prefabs = { "forcefieldfx" }
        fn = ruins
    elseif name == "wathgrithr" then
        fn = wathgrithr
    elseif name == "ice" then
        fn = ice
    elseif name == "mole" then
        fn = mole
    elseif name == "rain" then
        fn = rain
    elseif name == "catcoon" then
        fn = catcoon
    elseif name == "watermelon" then
        fn = watermelon
    elseif name == "eyebrella" then
        fn = eyebrella
    elseif name == "captain" then
        fn = captain
    elseif name == "snakeskin" then
        fn = snakeskin
    elseif name == "pirate" then
        fn = pirate
    elseif name == "gas" then
        fn = gas
    elseif name == "aerodynamic" then
        fn = aerodynamic
    elseif name == "double_umbrella" then
        fn = double_umbrella
    elseif name == "shark_teeth" then
        fn = shark_teeth
    elseif name == "brainjelly" then
        fn = brainjelly
    elseif name == "woodlegs" then
        fn = woodlegs
    elseif name == "ox" then
        fn = ox
    end



    return Prefab("common/inventory/" .. prefabname, fn or simple, assets, prefabs)
end

return MakeHat("straw"),
MakeHat("top"),
MakeHat("beefalo"),
MakeHat("feather"),
MakeHat("bee"),
MakeHat("miner"),
MakeHat("spider"),
MakeHat("football"),
MakeHat("earmuffs"),
MakeHat("winter"),
MakeHat("bush"),
MakeHat("flower"),
MakeHat("walrus"),
MakeHat("slurtle"),
MakeHat("ruins"),
MakeHat("wathgrithr", true),
MakeHat("ice", true),
MakeHat("mole", true),
MakeHat("rain", true),
MakeHat("catcoon", true),
MakeHat("watermelon", true),
MakeHat("eyebrella", true),
MakeHat("captain"),
MakeHat("snakeskin"),
MakeHat("pirate"),
MakeHat("gas"),
MakeHat("aerodynamic"),
MakeHat("double_umbrella"),
MakeHat("shark_teeth"),
MakeHat("brainjelly"),
MakeHat("woodlegs"),
MakeHat("ox")