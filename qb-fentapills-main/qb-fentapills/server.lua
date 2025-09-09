local QBCore = exports['qb-core']:GetCoreObject()

-- عداد مرات الصنع لكل لاعب (cache)
local playerMixCounts = {}

-- helper: نحدد level
local function getLevelFromCount(count)
    if count >= 6000 then
        return 3
    elseif count >= 3000 then
        return 2
    else
        return 1
    end
end

-- ✅ ملي resource كيتعاود start (restart script)
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player then
                local saved = Player.PlayerData.metadata and Player.PlayerData.metadata.pillMixCount or 0
                playerMixCounts[playerId] = saved
            end
        end
        print("^2[PILL SYSTEM]^7 Cache reloaded for all online players.")
    end
end)

-- لما اللاعب يدخل السيرفر، نجيب العدد من الميتاداتا
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local saved = Player.PlayerData.metadata and Player.PlayerData.metadata.pillMixCount or 0
    playerMixCounts[src] = saved
end)

-- لما يخرج نمسحو الكاش
AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    playerMixCounts[src] = nil
end)

-- ========== GIVE COMPONENTS ==========
RegisterNetEvent('give:broken_pills', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem('broken_pills', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['broken_pills'], 'add')
    end
end)

RegisterNetEvent('give:fenta_syrup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem('fenta_syrup', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['fenta_syrup'], 'add')
    end
end)

-- ========== CHECK INGREDIENTS ==========
QBCore.Functions.CreateCallback('check:ingredients', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    local compA = Player.Functions.GetItemByName('broken_pills')
    local compB = Player.Functions.GetItemByName('fenta_syrup')
    cb(compA and compB and true or false)
end)

-- ========== CRAFT HEALING PILL ==========
RegisterNetEvent('craft:healingpill', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local compA = Player.Functions.GetItemByName('broken_pills')
    local compB = Player.Functions.GetItemByName('fenta_syrup')

    if compA and compB then
        Player.Functions.RemoveItem('broken_pills', 1)
        Player.Functions.RemoveItem('fenta_syrup', 1)

        -- تحديث العداد
        local current = (playerMixCounts[src] or Player.PlayerData.metadata.pillMixCount or 0) + 1
        playerMixCounts[src] = current
        Player.Functions.SetMetaData('pillMixCount', current)

        -- نحدد level
        local level = getLevelFromCount(current)
        local pillItem = "healing_pill_lv1"
        if level == 2 then
            pillItem = "healing_pill_lv2"
        elseif level == 3 then
            pillItem = "healing_pill_lv3"
        end

        -- نعطي الحبة المناسبة
        Player.Functions.AddItem(pillItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[pillItem], 'add')
        TriggerClientEvent('QBCore:Notify', src, "You crafted a " .. QBCore.Shared.Items[pillItem].label .. "!", "success")

        -- إعلام اللاعب ملي يوصل thresholds
        if current == 3000 then
            TriggerClientEvent('QBCore:Notify', src, "🎉 You unlocked Pill Level 2!", "success")
        elseif current == 6000 then
            TriggerClientEvent('QBCore:Notify', src, "🔥 You unlocked Pill Level 3!", "success")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have the right ingredients!", "error")
    end
end)

-- ========== MAKE PILLS USABLE ==========
QBCore.Functions.CreateUseableItem("healing_pill_lv1", function(source, item)
    TriggerClientEvent("use:healing_pill", source, 1)
end)

QBCore.Functions.CreateUseableItem("healing_pill_lv2", function(source, item)
    TriggerClientEvent("use:healing_pill", source, 2)
end)

QBCore.Functions.CreateUseableItem("healing_pill_lv3", function(source, item)
    TriggerClientEvent("use:healing_pill", source, 3)
end)

-- ========== CHAT COMMAND: PILL INFO ==========
QBCore.Commands.Add("pillinfo", "Check your pill crafting progress", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local current = playerMixCounts[src] or Player.PlayerData.metadata.pillMixCount or 0
    local level = getLevelFromCount(current)

    local nextGoal = nil
    if level == 1 then
        nextGoal = 3000 - current
    elseif level == 2 then
        nextGoal = 6000 - current
    end

    -- رسالة للاعب
    local msg = ("📊 Pill Crafting Progress:\nLevel: %d\nCrafted: %d pills"):format(level, current)
    if nextGoal then
        msg = msg .. ("\nRemaining to next level: %d pills"):format(nextGoal)
    else
        msg = msg .. "\n🔥 You already reached MAX Level!"
    end

    TriggerClientEvent('QBCore:Notify', src, msg, "primary", 10000)
end)
