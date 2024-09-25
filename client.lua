local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}

-- Event to update the player's job information from the framework
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)

-- Event to set the initial job information when the player loads
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

-- Event to toggle the player's duty status
RegisterNetEvent('tobacco:client:ToggleDuty', function()
    TriggerServerEvent('tobacco:server:ToggleDuty')
end)



-- Event to start working in the field
RegisterNetEvent('tobacco:client:WorkField', function()
    local ped = PlayerPedId()

    -- Ensure the player has the correct job
    if QBCore.Functions.GetPlayerData().job.name == "tobacco" then
        QBCore.Functions.Progressbar("working_in_field", "Picking tobacco leaves...", 1000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_b",  -- Default animation
            anim = "idle_d",
            flags = 49,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('tobacco:server:CollectTobaccoLeaves')
        end, function() -- Cancel
            ClearPedTasks(ped)
            TriggerEvent('QBCore:Notify', "Action cancelled.", "error")
        end)
    else
        TriggerEvent('QBCore:Notify', "You are not a tobacco worker.", "error")
    end
end)

-- Event to dry tobacco leaves
RegisterNetEvent('tobacco:client:DryLeaves', function()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local amount = 0

    -- Check for tobacco_leaf item in player inventory
    for _, item in pairs(playerData.items) do
        if item.name == 'tobacco_leaf' then
            amount = item.amount
            break
        end
    end

    if amount > 0 then
        QBCore.Functions.Progressbar("drying_leaves", "Drying tobacco leaves...", amount * 200, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_b",
            anim = "idle_d",
            flags = 49,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('tobacco:server:DryTobaccoLeaves')
        end, function() -- Cancel
            ClearPedTasks(ped)
            TriggerEvent('QBCore:Notify', "Drying cancelled.", "error")
        end)
    else
        TriggerEvent('QBCore:Notify', "You don't have any tobacco leaves to dry.", "error")
    end
end)


-- Event to process dried tobacco leaves
RegisterNetEvent('tobacco:client:ProcessLeaves', function()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local amount = nil

    -- Find the amount of dried tobacco leaves in the player's inventory
    for _, item in pairs(playerData.items) do
        if item.name == 'dried_tobacco_leaf' then
            amount = item
            break
        end
    end

    if amount and amount.amount > 0 then
        QBCore.Functions.Progressbar("processing_leaves", "Processing dried tobacco leaves...", amount.amount * 200, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_b",
            anim = "idle_d",
            flags = 49,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('tobacco:server:ProcessTobaccoLeaves')
        end, function() -- Cancel
            ClearPedTasks(ped)
            TriggerEvent('QBCore:Notify', "Processing cancelled.", "error")
        end)
    else
        TriggerEvent('QBCore:Notify', "You don't have any dried tobacco leaves to process.", "error")
    end
end)

-- Event to make cigarettes
RegisterNetEvent('tobacco:client:MakeCigarettes', function()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local processedTobaccoItem = nil

    for _, item in pairs(playerData.items) do
        if item.name == 'processed_tobacco' then
            processedTobaccoItem = item
            break
        end
    end

    if processedTobaccoItem and processedTobaccoItem.amount >= 20 then
        QBCore.Functions.Progressbar("making_cigarettes", "Making cigarettes...", processedTobaccoItem.amount * 200, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_b",
            anim = "idle_d",
            flags = 49,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('tobacco:server:MakeCigarettes')
        end, function() -- Cancel
            ClearPedTasks(ped)
            TriggerEvent('QBCore:Notify', "Making cigarettes cancelled.", "error")
        end)
    else
        TriggerEvent('QBCore:Notify', "You need at least 20 processed tobacco leaves to make a pack of cigarettes.", "error")
    end
end)

-- Event to box cigarettes
RegisterNetEvent('tobacco:client:BoxCigarettes', function()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local cigarettePackItem = nil

    -- Debugging: Print player data and items
    if playerData and playerData.items then
        -- Find cigarette_pack item in player data
        for _, item in pairs(playerData.items) do
            if item.name == 'cigarette_pack' then
                cigarettePackItem = item
                break
            end
        end
    else
    end

    if cigarettePackItem and cigarettePackItem.amount and cigarettePackItem.amount >= 10 then
        QBCore.Functions.Progressbar("boxing_cigarettes", "Boxing cigarettes...", cigarettePackItem.amount * 200, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@idle_b",
            anim = "idle_d",
            flags = 49,
        }, {}, {}, function() -- Done
            ClearPedTasks(ped)
            TriggerServerEvent('tobacco:server:BoxCigarettes')
        end, function() -- Cancel
            ClearPedTasks(ped)
            TriggerEvent('QBCore:Notify', "Boxing cigarettes cancelled.", "error")
        end)
    else
        TriggerEvent('QBCore:Notify', "You need at least 10 packs of cigarettes to box them.", "error")
    end
end)

-- Target interactions for various job locations
exports['qb-target']:AddBoxZone("clockintobacco", vector3(2895.84, 4413.09, 50.29), 2.6, 1, {
    name = "clockintobacco",
    heading = 25,
    minZ = 49.89,
    maxZ = 51.49
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:ToggleDuty",
            icon = "fas fa-sign-in-alt",
            label = "Clock In/Out",
            job = "tobacco"
        }
    },
    distance = 2.0
})


-- Define the first segment
exports['qb-target']:AddBoxZone("newseg1", vector3(2881.81, 4587.64, 58.94), 15, 15, {
    name = "newseg1",
    heading = 16,
    minZ = 46.94,
    maxZ = 49.94,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the second segment
exports['qb-target']:AddBoxZone("newseg2", vector3(2865.29, 4582.55, 47.29), 15, 15, {
    name = "newseg2",
    heading = 15,
    minZ = 43.29,
    maxZ = 49.29,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the third segment
exports['qb-target']:AddBoxZone("newseg3", vector3(2860.71, 4598.13, 47.78), 15, 15, {
    name = "newseg3",
    heading = 16,
    minZ = 43.78,
    maxZ = 49.78,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the fourth segment
exports['qb-target']:AddBoxZone("newseg4", vector3(2876.27, 4603.41, 47.78), 15, 15, {
    name = "newseg4",
    heading = 15,
    minZ = 43.78,
    maxZ = 49.78,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the fifth segment
exports['qb-target']:AddBoxZone("newseg5", vector3(2873.16, 4619.48, 48.26), 15, 15, {
    name = "newseg5",
    heading = 20,
    minZ = 44.26,
    maxZ = 50.26,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the sixth segment
exports['qb-target']:AddBoxZone("newseg6", vector3(2857.47, 4613.65, 48.0), 15, 15, {
    name = "newseg6",
    heading = 15,
    minZ = 44.0,
    maxZ = 50.0,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the seventh segment
exports['qb-target']:AddBoxZone("newseg7", vector3(2839.59, 4612.59, 48.49), 15, 15, {
    name = "newseg7",
    heading = 15,
    minZ = 44.49,
    maxZ = 50.49,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})

-- Define the eighth segment
exports['qb-target']:AddBoxZone("newseg8", vector3(2845.52, 4592.59, 47.2), 24.4, 15, {
    name = "newseg8",
    heading = 10,
    minZ = 42.2,
    maxZ = 52.2,
    debugPoly = false,  -- Enable debugging
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:WorkField",
            icon = "fas fa-seedling",
            label = "Work in Field",
            job = "tobacco"
        }
    },
    distance = 10.0
})



exports['qb-target']:AddBoxZone("dryleaves", vector3(2887.27, 4507.26, 48.15), 5.6, 10, {
    name = "dryleaves",
    heading = 80,
    minZ = 48.65,
    maxZ = 50.25
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:DryLeaves",
            icon = "fas fa-leaf",
            label = "Dry Leaves",
            job = "tobacco"
        }
    },
    distance = 2.0
})

exports['qb-target']:AddBoxZone("processleaves", vector3(2907.23, 4497.09, 48.25), 11, 12, {
    name = "processleaves",
    heading = 55,
    minZ = 40.85,
    maxZ = 60.65
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:ProcessLeaves",
            icon = "fas fa-cogs",
            label = "Process Leaves",
            job = "tobacco"
        }
    },
    distance = 5.0
})

exports['qb-target']:AddBoxZone("packageleaves", vector3(2921.02, 4477.31, 48.17), 15.0, 12.4, {
    name = "packageleaves",
    heading = 310,
    minZ = 47.57,
    maxZ = 48.57
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:MakeCigarettes",
            icon = "fas fa-cigarette",
            label = "Make Cigarettes",
            job = "tobacco"
        },
        {
            type = "client",
            event = "tobacco:client:BoxCigarettes",
            icon = "fas fa-box",
            label = "Box Cigarettes",
            job = "tobacco"
        }
        
    },
    distance = 2.0
})


--storage box open
-- Add this to your qb-target configuration
exports['qb-target']:AddBoxZone("storageinput", vector3(2872.28, 4419.18, 49.17), 1.6, 1, {
    name = "storageinput",
    heading = 295,
    minZ = 48.37,
    maxZ = 50.17
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:ConvertPacks",
            icon = "fas fa-box",
            label = "Store Delivery Boxes",
            job = "tobacco"
        }
    },
    distance = 2.0
})

-- Event to handle conversion interaction
RegisterNetEvent('tobacco:client:ConvertPacks', function()
    TriggerServerEvent('tobacco:server:ConvertPacks')
end)




-- end of farming










--client side
local QBCore = exports['qb-core']:GetCoreObject()

-- Sandy Shop Delivery Zone
exports['qb-target']:AddBoxZone("sandyshop", vector3(1959.98, 3753.26, 32.24), 2.6, 1, {
    name = "sandyshop",
    heading = 35,
    minZ = 31.24,
    maxZ = 33.64
}, {
    options = {
        {
            type = "client",
            event = "deliverytrigger",
            icon = "fas fa-box",
            label = "Deliver Package",
        },
    },
    distance = 2.0
})

-- Near Harmony Shop Delivery Zone
-- Near Harmony Shop Delivery Zone
exports['qb-target']:AddBoxZone("nearharmonyshop", vector3(543.98, 2658.99, 42.19), 3.0, 1, {
    name = "nearharmonyshop",
    heading = 10,
    minZ = 39.79,
    maxZ = 43.79,
    debugPoly = false -- Ensure this is false or set to true for debugging
}, {
    options = {
        {
            type = "client",
            event = "deliverytrigger",
            icon = "fas fa-box",
            label = "Deliver Package",
        },
    },
    distance = 3.0
})



-- Main City Delivery Zone
exports['qb-target']:AddBoxZone("maincity", vector3(31.72, -1316.63, 29.52), 3.4, 1, {
    name = "maincity",
    heading = 90,
    minZ = 27.52,
    maxZ = 31.52
}, {
    options = {
        {
            type = "client",
            event = "deliverytrigger",
            icon = "fas fa-box",
            label = "Deliver Package",
        },
    },
    distance = 5.0
})


-- Grove Shop Delivery Zone
exports['qb-target']:AddBoxZone("groveshop", vector3(-41.59, -1748.65, 29.24), 1.4, 1, {
    name = "groveshop",
    heading = 50,
    minZ = 28.24,
    maxZ = 31.04
}, {
    options = {
        {
            type = "client",
            event = "deliverytrigger",
            icon = "fas fa-box",
            label = "Deliver Package",
        },
    },
    distance = 5.0
})

-- Little Saul Shop Delivery Zone
exports['qb-target']:AddBoxZone("littlesaulshop", vector3(-702.8, -916.2, 19.02), 1.6, 1, {
    name = "littlesaulshop",
    heading = 85,
    minZ = 16.82,
    maxZ = 20.82
}, {
    options = {
        {
            type = "client",
            event = "deliverytrigger",
            icon = "fas fa-box",
            label = "Deliver Package",
        },
    },
    distance = 5.0
})


-- Setting up the Redwood PC interaction for starting the delivery job
exports['qb-target']:AddBoxZone("box_interaction", vector3(2874.47, 4420.14, 49.15), 1, 1, {
    name = "box_interaction",
    heading = 294,
    minZ = 48.35,
    maxZ = 50.15
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:PickupBox",
            icon = "fas fa-box",
            label = "Pick up Box",
        }
    },
    distance = 2.0
})

-- Setting up the Redwood PC interaction for starting the delivery job
exports['qb-target']:AddBoxZone("redwoodpc", vector3(2879.12, 4417.11, 49.19), 3.4, 1, {
    name = "redwoodpc",
    heading = 25,
    minZ = 48.59,
    maxZ = 49.79
}, {
    options = {
        {
            type = "client",
            event = "tobacco:client:OpenDashboard",  -- New event to open the HTML page
            icon = "fas fa-laptop",
            label = "Open Dashboard",
        },
    },
    distance = 2.0
})

-- Open RedwoodPC
RegisterNetEvent('tobacco:client:OpenDashboard', function()
    local playerData = QBCore.Functions.GetPlayerData() -- Get player data to access their job and duty status

    -- Check if the player's job is 'tobacco' and if they are on duty
    if playerData and playerData.job and playerData.job.name == "tobacco" and playerData.job.onduty then
        -- Proceed to open the dashboard if the player meets the job and duty check
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openUI"
        })
        TriggerServerEvent('tobacco:server:fetchStock')
        TriggerServerEvent('tobacco:server:fetchPreviousDeliveries') -- Fetch previous deliveries
    else
        -- Notify the player that they don't meet the requirements
        QBCore.Functions.Notify("You must be a tobacco worker and on duty to access the dashboard!", "error")
    end
end)



local isDeliveryActive = false -- Flag to check if a delivery job is active

RegisterNUICallback('startDelivery', function(data, cb)
    if isDeliveryActive then
        -- Notify the UI that a job is already in progress
        TriggerEvent('chat:addMessage', { args = { "A delivery job is already in progress!" } })
        cb('already_in_progress') -- Indicate that the job cannot start
        return
    end

    isDeliveryActive = true -- Set the flag to indicate a job is active

    -- Trigger the existing delivery job event
    TriggerEvent('tobacco:client:StartDelivery5')

    -- Notify the server to log the delivery
    TriggerServerEvent('tobacco:server:logDelivery')

    -- Notify the UI to close
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeUI" })

    cb('ok') -- Acknowledge the callback
end)

-- When the delivery is finished or canceled, reset the flag and notify NUI
function finishDelivery()
    isDeliveryActive = false
    -- Notify the NUI that the delivery is finished
    SendNUIMessage({ action = "updateDeliveryStatus", status = "not_active" })
    QBCore.Functions.Notify("Delivery job completed!", "success") -- Notify player
end

-- Add a delivery log entry from the server
RegisterNetEvent('tobacco:client:addDeliveryLog', function(playerName, time)
    -- Send the log information to the NUI
    SendNUIMessage({
        action = "addDeliveryLog",
        playerName = playerName,
        time = time
    })
end)

RegisterNetEvent('tobacco:client:UpdateStock', function(stock)
    -- Update the UI with the current stock value
    SendNUIMessage({
        action = "updateStock",
        stock = stock
    })
end)

RegisterNUICallback('closeUI', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeUI"
    })
end)

RegisterNUICallback('setFocus', function(data, cb)
    if data.focus then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
    cb('ok') -- Acknowledge the callback
end)

-- Ensure to call finishDelivery() when the delivery job completes
-- This should be part of the delivery job logic when the job ends.


-- Initial variables
local van = nil
local totalPickedBoxes = 0  -- Tracks total number of boxes picked up
local maxBoxes = 5          -- Maximum boxes allowed to be picked up
local currentCarriedBoxes = 0  -- Tracks currently carried boxes
local boxesInVan = 0        -- Tracks boxes in the van
local isCarryingBox = false
local prop = nil
local hasStartedDeliveryJob = false  -- Tracks if the player has started a delivery job
local deliveryPoints = {
    vector3(1964.24, 3755.5, 32.24),  -- Sandy Shores
    vector3(539.07, 2658.54, 42.32),  -- Up from Harmony
    vector3(28.97, -1312.17, 29.35),  -- Main City
    vector3(-39.25, -1745.16, 29.13), -- Grove Street
    vector3(-702.75, -916.82, 19.21)  -- Little Soul
}



local currentDeliveryIndex = 1
local deliveryVan = nil

Config = {}
Config.VanModel = "burrito2"
Config.VanSpawnLocation = { x = 2881.85, y = 4394.73, z = 50.56 }
Config.VanSpawnHeading = 25.0

-- Start Delivery Job for 5 deliveries
RegisterNetEvent('tobacco:client:StartDelivery5', function()
    hasStartedDeliveryJob = true
    maxBoxes = 5  -- Set the max boxes for this job
    totalPickedBoxes = 0  -- Reset the counter
    currentCarriedBoxes = 0
    hasStartedDeliveryJob = true  -- Mark job as started
    QBCore.Functions.Notify("Starting delivery job...", "info")  -- Notify player

    local playerPed = PlayerPedId()
    local vehicleModel = GetHashKey(Config.VanModel)
    local spawnLocation = Config.VanSpawnLocation

    -- Request the vehicle model
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(500)
    end

    -- Create the vehicle and set keys
    deliveryVan = CreateVehicle(vehicleModel, spawnLocation.x, spawnLocation.y, spawnLocation.z, Config.VanSpawnHeading, true, false)
    SetVehicleOnGroundProperly(deliveryVan)
    SetEntityAsMissionEntity(deliveryVan, true, true)
    TaskWarpPedIntoVehicle(playerPed, deliveryVan, -1)
    SetVehicleHasBeenOwnedByPlayer(deliveryVan, true)  -- Make sure the player owns it
    SetVehicleDoorsLocked(deliveryVan, 1) -- Unlock vehicle

    -- Give player the keys to the van
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(deliveryVan))

    -- Set up interaction with the van using qb-target
    exports['qb-target']:AddTargetEntity(deliveryVan, {
        options = {
            {
                -- Load box into van action
                icon = "fas fa-box",
                label = "Load Box into Van",
                action = function(entity)
                    TriggerEvent('tobacco:client:LoadBoxIntoVan')  -- Trigger the event instead of calling the function
                end
            },
            {
                -- Unload box from van action
                icon = "fas fa-box",
                label = "Unload Box from Van",
                action = function(entity)
                    TriggerEvent('tobacco:client:UnloadBoxFromVan')  -- Corrected event name
                end
            }
        },
        distance = 3.0
    })
end)


-- Pickup Box Event with Job Check
-- Pickup Box Event
-- Pickup Box Event with Job Check
RegisterNetEvent('tobacco:client:PickupBox', function()
    if hasStartedDeliveryJob then
        if not isCarryingBox then
            -- Send the player's current box count and max boxes to the server
            TriggerServerEvent('tobacco:server:PickupBox', totalPickedBoxes, maxBoxes)
        else
            QBCore.Functions.Notify("You are already carrying a box!", "error")
        end
    else
        QBCore.Functions.Notify("You need to start a delivery job first!", "error")
    end
end)


-- Box Pickup Event
RegisterNetEvent('tobacco:client:BoxPickedUp', function(newStock)
    if totalPickedBoxes < maxBoxes then
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        -- Create the box prop
        local boxProp = CreateObject(GetHashKey("prop_cardbordbox_02a"), pos.x, pos.y, pos.z, true, true, true)

        -- Attach the box to both hands with corrected position and rotation
        AttachEntityToEntity(
            boxProp,                                  -- The box prop entity
            playerPed,                                -- The player entity
            GetPedBoneIndex(playerPed, 24816),        -- Spine bone (or try 0 for root bone)
            -0.07,                                      -- X offset
            0.55,                                      -- Y offset
            0.1,                                      -- Z offset (closer to hands)
            90.0,                                      -- Pitch (rotation around X-axis)
            0.0,                                      -- Roll (rotation around Y-axis)
            90.0,                                      -- Yaw (rotation around Z-axis)
            true,                                     -- Is attached
            true,                                     -- Is collision enabled
            false,                                    -- Physics disabled
            true,                                     -- Allow collision only with the player
            1,                                        -- Rotation fixed
            true                                      -- Allow soft pinning
        )

        -- Play the carry animation (both hands up)
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)

        -- Update variables
        isCarryingBox = true
        totalPickedBoxes = totalPickedBoxes + 1
        currentCarriedBoxes = currentCarriedBoxes + 1
        prop = boxProp

        QBCore.Functions.Notify("You picked up a box. Total boxes: " .. totalPickedBoxes, "success")
        
        -- Set waypoint for van when fully loaded
        if totalPickedBoxes >= maxBoxes then
            SetInitialWaypoint()
        end
    else
        QBCore.Functions.Notify("You have already picked up the maximum number of boxes for this job!", "error")
    end
end)



-- Load Box into Van Event
RegisterNetEvent('tobacco:client:LoadBoxIntoVan', function()
    if isCarryingBox and deliveryVan then
        if boxesInVan < maxBoxes then
            -- Detach the box and delete the object
            DetachEntity(prop, true, true)
            DeleteObject(prop)
            prop = nil

            -- Clear the carry animation
            ClearPedTasksImmediately(PlayerPedId())

            -- Update variables
            isCarryingBox = false
            boxesInVan = boxesInVan + 1
            currentCarriedBoxes = currentCarriedBoxes - 1

            QBCore.Functions.Notify("Box loaded into van.", "success")

        else
            QBCore.Functions.Notify("The van is full.", "error")
        end
    else
        QBCore.Functions.Notify("You are not carrying a box or no van found.", "error")
    end
end)


-- Unload Box from Van Event
-- Unload Box from Van Event
RegisterNetEvent('tobacco:client:UnloadBoxFromVan', function()
    if isCarryingBox then
        QBCore.Functions.Notify("You are already carrying a box!", "error")
        return
    end

    if deliveryVan and boxesInVan > 0 then
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        -- Create the box prop
        local boxProp = CreateObject(GetHashKey("prop_cardbordbox_02a"), pos.x, pos.y, pos.z, true, true, true)

        -- Attach the box to the player's hands
        AttachEntityToEntity(
            boxProp,                                  -- The box prop entity
            playerPed,                                -- The player entity
            GetPedBoneIndex(playerPed, 24816),        -- Spine bone (or try 0 for root bone)
            -0.07,                                      -- X offset
            0.55,                                      -- Y offset
            0.1,                                      -- Z offset (closer to hands)
            90.0,                                      -- Pitch (rotation around X-axis)
            0.0,                                      -- Roll (rotation around Y-axis)
            90.0,                                      -- Yaw (rotation around Z-axis)
            true,                                     -- Is attached
            true,                                     -- Is collision enabled
            false,                                    -- Physics disabled
            true,                                     -- Allow collision only with the player
            1,                                        -- Rotation fixed
            true                                      -- Allow soft pinning
        )

        -- Play a carrying animation
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Citizen.Wait(100)
        end
        TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)

        -- Update variables
        isCarryingBox = true
        boxesInVan = boxesInVan - 1
        currentCarriedBoxes = currentCarriedBoxes + 1
        prop = boxProp

        QBCore.Functions.Notify("Box unloaded from van.", "success")
    else
        QBCore.Functions.Notify("No boxes in the van or no van found.", "error")
    end
end)


-- Start Delivery Event
Citizen.CreateThread(function()
    local notificationShown = false  -- Track if notification has been shown

    while true do
        Citizen.Wait(500)  -- Adjust wait time to optimize performance

        if deliveryVan and hasStartedDeliveryJob then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local deliveryPoint = deliveryPoints[currentDeliveryIndex]

            if deliveryPoint then
                local dist = #(playerPos - deliveryPoint)

                -- Check if the player is within range of the delivery point
                if dist < 10.0 and isCarryingBox then
                    -- Logic to handle box delivery and reward
                    if not notificationShown then
                        notificationShown = true
                        QBCore.Functions.Notify("Delivery point reached. Deliver the box.", "success")

                        -- Simulate successful delivery
                        currentCarriedBoxes = currentCarriedBoxes - 1
                        if currentCarriedBoxes > 0 then
                            QBCore.Functions.Notify("Box delivered successfully!", "success")
                            
                            -- Proceed to the next delivery point
                            currentDeliveryIndex = currentDeliveryIndex + 1
                        
                            -- Reset index if it's beyond the number of delivery points
                            if currentDeliveryIndex > #deliveryPoints then
                                currentDeliveryIndex = 1
                                QBCore.Functions.Notify("All delivery points visited. Returning to van.", "success")
                                SetWaypointForVan() -- Set waypoint to return to the van
                            else
                                SetInitialWaypoint() -- Set waypoint for the next delivery point
                            end
                        else
                        end
                        
                    end
                elseif dist >= 10.0 then
                    -- Reset notification flag if the player moves away from the delivery point
                    if notificationShown then
                        notificationShown = false
                    end
                end
            end
        else
            Citizen.Wait(1000)  -- If the job isn't active, wait longer to reduce CPU load
        end
    end
end)


-- Function to set the initial waypoint for the delivery route
function SetInitialWaypoint()
    if deliveryPoints and #deliveryPoints > 0 and currentDeliveryIndex and deliveryPoints[currentDeliveryIndex] then
        local waypoint = deliveryPoints[currentDeliveryIndex]
        if waypoint then
            SetNewWaypoint(waypoint.x, waypoint.y)
            QBCore.Functions.Notify("Waypoint set for your delivery location: " .. currentDeliveryIndex, "success")
        else
            QBCore.Functions.Notify("Invalid waypoint index.", "error")
        end
    else
        QBCore.Functions.Notify("Unable to set waypoint. Delivery points are missing.", "error")
    end
end

-- Function to set a waypoint back to the van's spawn location
function SetWaypointForVan()
    local vanSpawnLocation = Config.VanSpawnLocation
    if vanSpawnLocation then
        SetNewWaypoint(vanSpawnLocation.x, vanSpawnLocation.y)
        QBCore.Functions.Notify("Return to the van's spawn location.", "success")
    else
        QBCore.Functions.Notify("Van spawn location not found.", "error")
    end
end


-- Function to check if player is at the current delivery location
local function isPlayerAtDeliveryLocation()
    if currentDeliveryIndex < 1 or currentDeliveryIndex > #deliveryPoints then
        return false -- Invalid index
    end
    
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local deliveryLocation = deliveryPoints[currentDeliveryIndex]

    -- Define a threshold distance to consider them "in" the location
    local threshold = 5.0
    return Vdist(playerPos.x, playerPos.y, playerPos.z, deliveryLocation.x, deliveryLocation.y, deliveryLocation.z) < threshold
end

-- Event to handle the delivery trigger
RegisterNetEvent('deliverytrigger', function()
    if isCarryingBox then
        if isPlayerAtDeliveryLocation() then
            -- Notify the server to process the delivery
            TriggerServerEvent('tobacco:server:ProcessDelivery', currentDeliveryIndex)

            -- Clear the box from the player's hand
            if prop then
                DeleteObject(prop)
                prop = nil
            end

            -- Clear the carry animation
            ClearPedTasksImmediately(PlayerPedId())

            -- Update variables
            isCarryingBox = false
            currentCarriedBoxes = currentCarriedBoxes - 1

            -- Update currentDeliveryIndex and set the next waypoint
            currentDeliveryIndex = currentDeliveryIndex + 1
            if currentDeliveryIndex > maxBoxes then
                currentDeliveryIndex = 1
                QBCore.Functions.Notify("All delivery points visited. Returning to van.", "success")
                SetWaypointForVan() -- Waypoint back to the van's spawn location
            else
                SetInitialWaypoint() -- Waypoint for the next delivery point
            end
        else
            QBCore.Functions.Notify("You must be at the correct delivery location to complete the delivery!", "error")
        end
    else
        QBCore.Functions.Notify("You need to have a box in hand to make a delivery.", "error")
    end
end)






-- Flag to prevent multiple triggers
Config.VanReturnLocation = vector3(2881.85, 4394.73, 50.56) -- Replace with your actual coordinates
Config.VanReturnRadius = 10.0 -- Set your desired radius

-- Flag to prevent multiple triggers
local inReturnZone = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Check continuously

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Check if the player is in a vehicle and it's the delivery van
        if vehicle and IsVehicleModel(vehicle, Config.VanModel) then
            local distance = #(playerPos - Config.VanReturnLocation)

            -- Check if the player is within the return zone
            if distance < Config.VanReturnRadius then
                -- Display the help prompt if not already in the zone
                if not inReturnZone then
                    inReturnZone = true
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to return the van.") -- E key prompt
                    EndTextCommandDisplayHelp(0, false, true, -1)
                end

                -- Check if "E" is pressed
                if IsControlJustReleased(0, 38) then -- 38 is the key code for "E"
                    TriggerEvent('tobacco:client:ReturnVan')
                end
            else
                inReturnZone = false -- Reset the flag if outside the zone
            end
        else
            inReturnZone = false -- Reset the flag if not in the van
        end
    end
end)

-- Event to handle van return and cancel the active delivery
RegisterNetEvent('tobacco:client:ReturnVan')
AddEventHandler('tobacco:client:ReturnVan', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false) -- Get the current vehicle the player is in

    -- Check if the player is in the delivery van
    if vehicle and IsVehicleModel(vehicle, Config.VanModel) then
        -- Delete the van
        DeleteVehicle(vehicle)
        finishDelivery() -- Call finishDelivery to reset the delivery status

        -- Reset delivery state variables
        if hasStartedDeliveryJob then
            hasStartedDeliveryJob = false -- Set delivery as inactive
            totalPickedBoxes = 0 -- Reset the box count
            currentCarriedBoxes = 0 -- Reset the total boxes
            boxesInVan = 0 -- reset van 

            -- Notify the player that the delivery was canceled
            QBCore.Functions.Notify("Delivery has been canceled and the van returned successfully.", "success")
        else
            -- Notify player of successful van return without an active delivery
            QBCore.Functions.Notify("Van returned successfully. No active delivery to cancel.", "success")
        end
    else
        -- Notify player they are not in the correct vehicle
        QBCore.Functions.Notify("You are not in the delivery van.", "error")
    end
end)


----- end of deliveries








































