local QBCore = exports['qb-core']:GetCoreObject()


local activeProps = {
    componentA = {},
    componentB = {}
}


local function FreezePlayer(ped, state)
    FreezeEntityPosition(ped, state)
    SetEntityInvincible(ped, state)
    DisablePlayerFiring(ped, state)
end


local function PlayFarmAnim()
    local ped = PlayerPedId()
    RequestAnimDict("amb@prop_human_bum_bin@idle_a")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_a") do Wait(0) end
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_a", "idle_a", 3.0, -1, -1, 49, 0, false, false, false)
end


local function SpawnProp(model, coords, heading)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, true)
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)
    return obj
end


local function SpawnFarmProps(zone, baseCoords, eventName)
    for i = 1, 3 do
        local offset = vector3(math.random(-3,3), math.random(-3,3), 0.0)
        local coords = baseCoords + offset
        local model = Config.FarmProps[zone][math.random(#Config.FarmProps[zone])]
        local prop = SpawnProp(model, coords)
        table.insert(activeProps[zone], prop)

        exports['qb-target']:AddTargetEntity(prop, {
            options = {
                {
                    type = "client",
                    event = eventName,
                    icon = "fas fa-hand",
                    label = "Collect",
                    propEntity = prop
                },
            },
            distance = 2.5
        })
    end
end


CreateThread(function()
    SpawnFarmProps("componentA", Config.FarmComponentAPos, "farm:componentA")
    SpawnFarmProps("componentB", Config.FarmComponentBPos, "farm:componentB")

    exports['qb-target']:AddBoxZone("lab_zone", Config.LabPos, 3.0, 3.0, {
        name = "lab_zone",
        heading = 0,
        debugPoly = false,
        minZ = Config.LabPos.z - 1.5,
        maxZ = Config.LabPos.z + 1.5,
    }, {
        options = {
            {
                type = "client",
                event = "start:craftingpill",
                icon = "fas fa-pills",
                label = "Mix Components",
            },
        },
        distance = 3.0
    })
end)


RegisterNetEvent('farm:componentA', function(data)
    local ped = PlayerPedId()
    local usedProp = data.entity

    FreezePlayer(ped, true)
    PlayFarmAnim()

    QBCore.Functions.Progressbar("farm_a", "Collecting Broken Pills...", 7000, false, true, {}, {}, {}, {}, function()
        ClearPedTasks(ped)
        FreezePlayer(ped, false)
        DeleteEntity(usedProp)

        for i, p in ipairs(activeProps.componentA) do
            if p == usedProp then
                table.remove(activeProps.componentA, i)
                break
            end
        end

        local offset = vector3(math.random(-3,3), math.random(-3,3), 0.0)
        local newModel = Config.FarmProps.componentA[math.random(#Config.FarmProps.componentA)]
        local newProp = SpawnProp(newModel, Config.FarmComponentAPos + offset)
        table.insert(activeProps.componentA, newProp)

        exports['qb-target']:AddTargetEntity(newProp, {
            options = {
                {
                    type = "client",
                    event = "farm:componentA",
                    icon = "fas fa-hand",
                    label = "Collect",
                    propEntity = newProp
                },
            },
            distance = 2.5
        })

        TriggerServerEvent('give:broken_pills')
    end, function()
        ClearPedTasks(ped)
        FreezePlayer(ped, false)
        QBCore.Functions.Notify("Canceled!", "error")
    end)
end)

RegisterNetEvent('farm:componentB', function(data)
    local ped = PlayerPedId()
    local usedProp = data.entity

    FreezePlayer(ped, true)
    PlayFarmAnim()

    QBCore.Functions.Progressbar("farm_b", "Collecting Fenta Syrup...", 7000, false, true, {}, {}, {}, {}, function()
        ClearPedTasks(ped)
        FreezePlayer(ped, false)
        DeleteEntity(usedProp)

        for i, p in ipairs(activeProps.componentB) do
            if p == usedProp then
                table.remove(activeProps.componentB, i)
                break
            end
        end

        local offset = vector3(math.random(-3,3), math.random(-3,3), 0.0)
        local newModel = Config.FarmProps.componentB[math.random(#Config.FarmProps.componentB)]
        local newProp = SpawnProp(newModel, Config.FarmComponentBPos + offset)
        table.insert(activeProps.componentB, newProp)

        exports['qb-target']:AddTargetEntity(newProp, {
            options = {
                {
                    type = "client",
                    event = "farm:componentB",
                    icon = "fas fa-hand",
                    label = "Collect",
                    propEntity = newProp
                },
            },
            distance = 2.5
        })

        TriggerServerEvent('give:fenta_syrup')
    end, function()
        ClearPedTasks(ped)
        FreezePlayer(ped, false)
        QBCore.Functions.Notify("Canceled!", "error")
    end)
end)


RegisterNetEvent('start:craftingpill', function()
    QBCore.Functions.TriggerCallback('check:ingredients', function(hasItems)
        if hasItems then
            local ped = PlayerPedId()
            RequestAnimDict("mini@repair")
            while not HasAnimDictLoaded("mini@repair") do Wait(0) end
            TaskPlayAnim(ped, "mini@repair", "fixing_a_player", 3.0, -1, -1, 49, 0, false, false, false)

            QBCore.Functions.Progressbar("craft_pill", "Mixing components...", 20000, false, true, {}, {}, {}, {}, function()
                ClearPedTasks(ped)
                TriggerServerEvent('craft:healingpill')
            end, function()
                ClearPedTasks(ped)
                QBCore.Functions.Notify("Canceled!", "error")
            end)
        else
            QBCore.Functions.Notify("You don't have the right ingredients!", "error")
        end
    end)
end)


RegisterNetEvent("use:healing_pill", function(level)
    local ped = PlayerPedId()

    RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do Wait(0) end
    TaskPlayAnim(ped, "mp_suicide", "pill", 3.0, -1, -1, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("pill", "Taking pill...", 3000, false, true, {}, {}, {}, {}, function()
        ClearPedTasks(ped)

        local health = GetEntityHealth(ped)

        if level == 1 then
            SetEntityHealth(ped, math.min(200, health + 10))
            AddArmourToPed(ped, GetPedArmour(ped) + 5)
            QBCore.Functions.Notify("You feel a bit better (Level 1 Pill)", "success")

        elseif level == 2 then
            SetEntityHealth(ped, math.min(200, health + 30))
            AddArmourToPed(ped, GetPedArmour(ped) + 15)
            QBCore.Functions.Notify("The pill feels stronger! (Level 2 Pill)", "success")

        elseif level == 3 then
            SetEntityHealth(ped, math.min(200, health + 70))
            AddArmourToPed(ped, GetPedArmour(ped) + 30)
            QBCore.Functions.Notify("This pill is super effective! (Level 3 Pill)", "success")
            TriggerEvent("hospital:client:StopBleeding")
        end

        TriggerServerEvent("pill:consume", level)
    end, function()
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Canceled!", "error")
    end)
end)
