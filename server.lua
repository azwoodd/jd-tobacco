local QBCore = exports['qb-core']:GetCoreObject()

-- Load the config file using LoadResourceFile
local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
assert(configFile, "Failed to load config.lua")  -- Ensure file is loaded
local func, err = load(configFile)
assert(func, err)  -- Ensure no loading errors
func()  -- Execute the loaded config code


-- Register the server event to toggle the player's duty status
RegisterNetEvent('tobacco:server:ToggleDuty', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player and Player.PlayerData.job.name == "tobacco" then
        local newDutyStatus = not Player.PlayerData.job.onduty
        Player.Functions.SetJobDuty(newDutyStatus)

        TriggerClientEvent('QBCore:Notify', src, newDutyStatus and "You are now on duty." or "You are now off duty.", "success")

    else
        TriggerClientEvent('QBCore:Notify', src, Config.JobRequiredMsg, "error")
    end
end)



-- Server event to handle collecting tobacco leaves
RegisterNetEvent('tobacco:server:CollectTobaccoLeaves', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Check if the player is part of the tobacco job
    if Player and Player.PlayerData.job.name == "tobacco" then
        -- Add 3 tobacco leaves to the player's inventory
        Player.Functions.AddItem('tobacco_leaf', 3)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['tobacco_leaf'], "add")
        TriggerClientEvent('QBCore:Notify', src, "You collected 3 tobacco leaves.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You are not a tobacco worker.", "error")
    end
end)





-- Server event to dry tobacco leaves
RegisterNetEvent('tobacco:server:DryTobaccoLeaves', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName('tobacco_leaf')

    if Player and Player.PlayerData.job.name == "tobacco" and item and item.amount > 0 then
        local driedAmount = item.amount * 3
        Player.Functions.RemoveItem('tobacco_leaf', item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['tobacco_leaf'], "remove")
        Wait(Config.DryTime)
        Player.Functions.AddItem('dried_tobacco_leaf', driedAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['dried_tobacco_leaf'], "add")
        TriggerClientEvent('QBCore:Notify', src, Config.SuccessMsg, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, Config.InsufficientItemsMsg, "error")
    end
end)


-- Server event to process dried tobacco leaves
RegisterNetEvent('tobacco:server:ProcessTobaccoLeaves', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = Player.Functions.GetItemByName('dried_tobacco_leaf')

    if Player and Player.PlayerData.job.name == "tobacco" and amount and amount.amount > 0 then
        local processedAmount = amount.amount
        Player.Functions.RemoveItem('dried_tobacco_leaf', amount.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['dried_tobacco_leaf'], "remove")
        Wait(Config.ProcessTime)  -- Use the configured process time
        Player.Functions.AddItem('processed_tobacco', processedAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['processed_tobacco'], "add")
        TriggerClientEvent('QBCore:Notify', src, Config.SuccessMsg, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, Config.InsufficientItemsMsg, "error")
    end
end)


-- Server event to make cigarettes
RegisterNetEvent('tobacco:server:MakeCigarettes', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local processedTobaccoItem = Player.Functions.GetItemByName('processed_tobacco')

    if Player and Player.PlayerData.job.name == "tobacco" and processedTobaccoItem and processedTobaccoItem.amount >= 20 then
        local cigarettePacks = math.floor(processedTobaccoItem.amount / Config.CigsPerPack)
        local remainingTobacco = processedTobaccoItem.amount % Config.CigsPerPack

        -- Remove processed tobacco
        Player.Functions.RemoveItem('processed_tobacco', cigarettePacks * Config.CigsPerPack)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['processed_tobacco'], "remove")

        Wait(Config.PackageTime)  -- Use the configured package time

        -- Add cigarette packs
        Player.Functions.AddItem('cigarette_pack', cigarettePacks)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cigarette_pack'], "add")
        TriggerClientEvent('QBCore:Notify', src, "You have made " .. cigarettePacks .. " packs of cigarettes.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You need at least 20 processed tobacco leaves to make a pack of cigarettes.", "error")
    end
end)


-- Server event to box cigarette packs into delivery boxes
RegisterNetEvent('tobacco:server:BoxCigarettes', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cigarettePackItem = Player.Functions.GetItemByName('cigarette_pack')


    if Player and Player.PlayerData.job.name == "tobacco" and cigarettePackItem and cigarettePackItem.amount and cigarettePackItem.amount >= 10 then
        local deliveryBoxes = math.floor(cigarettePackItem.amount / 10)
        local remainingPacks = cigarettePackItem.amount % 10

        -- Remove cigarette packs
        Player.Functions.RemoveItem('cigarette_pack', deliveryBoxes * 10)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cigarette_pack'], "remove")

        Wait(Config.PackageTime)  -- Use the configured package time

        -- Add delivery boxes
        Player.Functions.AddItem('delivery_box', deliveryBoxes)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['delivery_box'], "add")
        TriggerClientEvent('QBCore:Notify', src, "You have made " .. deliveryBoxes .. " delivery boxes.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You need at least 10 cigarette packs to box them.", "error")
    end
end)



--storage boxes
-- Server event to convert cigarette packs to delivery boxes
-- Server event to convert delivery boxes into stock
RegisterNetEvent('tobacco:server:ConvertPacks', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player and Player.PlayerData.job.name == "tobacco" then
        -- Fetch all the delivery boxes the player has
        local deliveryBoxItem = Player.Functions.GetItemByName('delivery_box')
        local deliveryBoxCount = deliveryBoxItem and deliveryBoxItem.amount or 0


        if deliveryBoxCount > 0 then
            -- Remove all delivery boxes from player inventory
            local removeSuccess = Player.Functions.RemoveItem('delivery_box', deliveryBoxCount)


            if removeSuccess then
                -- Update stock count in database by the exact amount of delivery boxes removed
                local boxName = 'default_box'
                local stockIncrement = deliveryBoxCount
                local result = exports.oxmysql:executeSync('UPDATE delivery_box_stock SET stock = stock + ? WHERE box_name = ?', {stockIncrement, boxName})


              
            -- Payment for Farmer
        -- Payment for Farmer
if Player.PlayerData.job.grade.name == "Farmer" then
    local paymentAmount = deliveryBoxCount * Config.PaymentPerBox
    Player.Functions.AddMoney('cash', paymentAmount, "payment-for-delivery-boxes")
    
    if Config.IsPlayerOwned then
        exports['qb-banking']:AddMoney('tobacco', paymentAmount, "Paid for storing delivery boxes")
    end

    TriggerClientEvent('QBCore:Notify', src, string.format("Received $%d for storing delivery boxes.", paymentAmount), "success")
end

    

                -- Notify player of success
                TriggerClientEvent('QBCore:Notify', src, string.format("Inputted %d delivery boxes into stock.", deliveryBoxCount), "success")
            else
                -- Notify player of failure to remove items
                TriggerClientEvent('QBCore:Notify', src, "Failed to remove delivery boxes from inventory.", "error")
            end
        else
            -- Notify player they don't have enough delivery boxes
            TriggerClientEvent('QBCore:Notify', src, "You don't have any delivery boxes to store.", "error")
        end
    else
        -- Notify player of job or item issues
        TriggerClientEvent('QBCore:Notify', src, "You don't have the correct job or items to store items here.", "error")
    end
end)








-- end farming

--server side
-- Pickup Box Event
RegisterNetEvent('tobacco:server:PickupBox', function(totalPickedBoxes, maxBoxes)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    if totalPickedBoxes < maxBoxes then
        exports.oxmysql:single('SELECT stock FROM delivery_box_stock WHERE box_name = ?', {'default_box'}, function(result)
            if result and result.stock then
                local currentStock = tonumber(result.stock)
                if currentStock and currentStock > 0 then
                    exports.oxmysql:execute('UPDATE delivery_box_stock SET stock = stock - 1 WHERE box_name = ?', {'default_box'}, function(updateResult)
                        if updateResult and updateResult.affectedRows > 0 then
                            local newStock = currentStock - 1
                            TriggerClientEvent('tobacco:client:BoxPickedUp', src, newStock)
                        else
                            TriggerClientEvent('QBCore:Notify', src, "Failed to update stock.", "error")
                        end
                    end)
                else
                    TriggerClientEvent('QBCore:Notify', src, "Insufficient stock to pick up a box.", "error")
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Stock information not found or incorrect structure.", "error")
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "You have already picked up the maximum number of boxes for this job!", "error")
    end
end)

-- Process Delivery Event
RegisterNetEvent('tobacco:server:ProcessDelivery', function(deliveryIndex)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    local rewardAmount = Config.PaymentAmount
    xPlayer.Functions.AddMoney('cash', rewardAmount, "Delivery payment")

    if Config.IsPlayerOwned then
        exports['qb-banking']:AddMoney('tobacco', rewardAmount, "Paid for delivery job")
    end

    TriggerClientEvent('QBCore:Notify', src, "Delivery " .. deliveryIndex .. " completed! You received $" .. rewardAmount, "success")
end)


RegisterNetEvent('tobacco:server:fetchStock', function()
    local src = source
    exports.oxmysql:single('SELECT stock FROM delivery_box_stock WHERE box_name = ?', {'default_box'}, function(result)
        if result and result.stock then
            TriggerClientEvent('tobacco:client:UpdateStock', src, result.stock) -- Ensure this matches client-side event
        else
            TriggerClientEvent('QBCore:Notify', src, "Could not fetch stock information.", "error")
        end
    end)
end)

-- Handle player logging
RegisterNetEvent('tobacco:server:logDelivery', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = xPlayer.PlayerData.name or "Unknown"
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")

    exports.oxmysql:insert('INSERT INTO delivery_logs (player_name, delivery_time) VALUES (?, ?)', {playerName, currentTime}, function(id)
        if id then
            TriggerClientEvent('tobacco:client:addDeliveryLog', -1, playerName, currentTime)
        else
        end
    end)
end)

-- Fetch Previous Deliveries from Database
RegisterNetEvent('tobacco:server:fetchPreviousDeliveries')
AddEventHandler('tobacco:server:fetchPreviousDeliveries', function()
    local src = source

    exports.oxmysql:fetch('SELECT player_name, delivery_time FROM delivery_logs', {}, function(results)
        for _, log in ipairs(results) do
            TriggerClientEvent('tobacco:client:addDeliveryLog', src, log.player_name, log.delivery_time)
        end
    end)
end)


-- end delivery job

