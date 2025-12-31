local sharedConfig = require 'config.shared'

--- Helper: Check if player has item in inventory
local function hasItemInInventory(source, itemName)
    if GetResourceState('ox_inventory') ~= 'started' then
        return false
    end
    
    local items = exports['ox_inventory']:GetInventoryItems(source)
    if not items then return false end
    
    for _, item in ipairs(items) do
        if item.name == itemName then
            return true
        end
    end
    
    return false
end

--- Checks if player already owns a license (has item in inventory OR metadata)
--- @param source number - Player source ID
--- @param itemName string - Item name to check
--- @return boolean - True if player has the item
local function playerHasLicense(source, itemName)
    -- Check ox_inventory first
    if GetResourceState('ox_inventory') == 'started' then
        local items = exports['ox_inventory']:GetInventoryItems(source)
        if items then
            for _, item in ipairs(items) do
                if item.name == itemName then
                    return true
                end
            end
        end
    end

    -- Check metadata (for systems that grant licenses via metadata)
    local player = exports['qbx_core']:GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.metadata and player.PlayerData.metadata.licences then
        local licenseKey = itemName:gsub('_license', ''):gsub('_card', '')
        if player.PlayerData.metadata.licences[licenseKey] then
            return true
        end
    end

    return false
end

--- Gets player money
--- @param source number - Player source ID
--- @return number - Cash amount
local function getPlayerMoney(source)
    local money = exports['qbx_core']:GetPlayer(source)
    if not money then return 0 end
    return money.PlayerData.money.cash or 0
end

--- Removes money from player
--- @param source number - Player source ID
--- @param amount number - Amount to remove
local function removeMoney(source, amount)
    local player = exports['qbx_core']:GetPlayer(source)
    if not player then return end
    player.Functions.RemoveMoney('cash', amount, 'cityhall_license')
end

--- Adds money to player
--- @param source number - Player source ID
--- @param amount number - Amount to add
local function addMoney(source, amount)
    local player = exports['qbx_core']:GetPlayer(source)
    if not player then return end
    player.Functions.AddMoney('cash', amount, 'cityhall_refund')
end

--- Event: Purchase a license
--- Validates money and inventory before granting license + metadata
RegisterNetEvent('qbx_cityhall:server:purchaseLicense', function(licenseKey)
    local source = source
    
    -- Validate player exists
    local player = exports['qbx_core']:GetPlayer(source)
    if not player then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Error',
            description = 'Player data not found',
            duration = 5000,
        })
    end

    -- Validate license key exists in config
    if not sharedConfig.licenses[licenseKey] then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Error',
            description = 'Invalid license type',
            duration = 5000,
        })
    end

    local licenseData = sharedConfig.licenses[licenseKey]

    -- Check if player already owns this license
    if playerHasLicense(source, licenseData.item) then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = locale('error.title'),
            description = locale('error.already_have_license'),
            duration = 5000,
        })
    end

    -- Check if player has enough money
    if getPlayerMoney(source) < licenseData.cost then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = locale('error.title'),
            description = locale('error.not_enough_money'),
            duration = 5000,
        })
    end

    -- Deduct money
    removeMoney(source, licenseData.cost)

    -- Grant license item to inventory
    local added = false
    if GetResourceState('ox_inventory') == 'started' then
        added = exports['ox_inventory']:AddItem(source, licenseData.item, 1)
    else
        print('^1[CityHall] Error: ox_inventory not running^7')
    end

    if not added then
        -- Return money if inventory full
        addMoney(source, licenseData.cost)
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = locale('error.title'),
            description = 'Your inventory is full',
            duration = 5000,
        })
    end

    -- Grant license via metadata
    if not player.PlayerData.metadata.licences then
        player.PlayerData.metadata.licences = {}
    end
    
    player.PlayerData.metadata.licences[licenseKey] = true
    player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)

    -- Success notification
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = locale('success.title'),
        description = locale('success.license_purchased') .. licenseData.label,
        duration = 5000,
    })

    -- Log the transaction
    print('^2[CityHall]^7 Player ' .. GetPlayerName(source) .. ' purchased ' .. licenseData.label .. ' for $' .. licenseData.cost)
end)

--- Event: Grant a license to another player via metadata
--- Can be used by admins/police to grant licenses to others
RegisterNetEvent('qbx_cityhall:server:grantLicenseMetadata', function(targetId, licenseKey)
    local source = source
    local player = exports['qbx_core']:GetPlayer(source)
    
    if not player then return end
    
    -- Validate license key exists
    if not sharedConfig.licenses[licenseKey] then
        return exports['qbx_core']:Notify(source, 'Invalid license type', 'error')
    end

    local licenseData = sharedConfig.licenses[licenseKey]
    local targetPlayer = exports['qbx_core']:GetPlayer(targetId)
    
    if not targetPlayer then
        return exports['qbx_core']:Notify(source, 'Player not found', 'error')
    end

    -- Initialize metadata if needed
    if not targetPlayer.PlayerData.metadata.licences then
        targetPlayer.PlayerData.metadata.licences = {}
    end

    local licenseKey2 = licenseKey:gsub('_license', ''):gsub('_card', '')
    
    -- Check if already has license
    if targetPlayer.PlayerData.metadata.licences[licenseKey2] then
        return exports['qbx_core']:Notify(source, 'Player already has this license', 'error')
    end

    -- Grant license
    targetPlayer.PlayerData.metadata.licences[licenseKey2] = true
    targetPlayer.Functions.SetMetaData('licences', targetPlayer.PlayerData.metadata.licences)

    -- Notify both players
    exports['qbx_core']:Notify(targetPlayer.PlayerData.source, 'You received a license: ' .. licenseData.label, 'success')
    exports['qbx_core']:Notify(source, 'License granted: ' .. licenseData.label, 'success')
end)

--- Export: Check if player has BOTH inventory item AND valid metadata (strict)
--- Use this for weapon shops and critical license checks
exports('hasValidLicense', function(source, licenseKey)
    if not sharedConfig.licenses[licenseKey] then return false end
    
    local licenseData = sharedConfig.licenses[licenseKey]
    local player = exports['qbx_core']:GetPlayer(source)
    if not player then return false end

    -- Check if player has the physical item in inventory
    local hasItem = false
    if GetResourceState('ox_inventory') == 'started' then
        local items = exports['ox_inventory']:GetInventoryItems(source)
        if items then
            for _, item in ipairs(items) do
                if item.name == licenseData.item then
                    hasItem = true
                    break
                end
            end
        end
    end

    -- Check if metadata is valid
    local hasMetadata = false
    if player.PlayerData.metadata and player.PlayerData.metadata.licences and player.PlayerData.metadata.licences[licenseKey] then
        hasMetadata = true
    end

    -- BOTH must be true for a valid license
    return hasItem and hasMetadata
end)

--- Export: Check if player has license (lenient - either inventory OR metadata)
--- Use this for general checks that don't need strict validation
exports('hasLicenseAny', function(source, licenseKey)
    if not sharedConfig.licenses[licenseKey] then return false end
    
    local licenseData = sharedConfig.licenses[licenseKey]
    return playerHasLicense(source, licenseData.item)
end)

--- Thread: Sync metadata licenses with actual inventory every 5 seconds
--- Ensures metadata stays in sync with physical inventory
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = exports['qbx_core']:GetPlayer(tonumber(playerId))
            if player and player.PlayerData.metadata and player.PlayerData.metadata.licences then
                -- Check each license
                for licenseKey, licenseData in pairs(sharedConfig.licenses) do
                    local licenseValid = player.PlayerData.metadata.licences[licenseKey] or false
                    local hasItem = hasItemInInventory(tonumber(playerId), licenseData.item)
                    
                    -- If metadata says player has license but item is gone - revoke it
                    if licenseValid and not hasItem then
                        player.PlayerData.metadata.licences[licenseKey] = false
                        player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)
                        
                        exports['qbx_core']:Notify(tonumber(playerId), 'Your ' .. licenseData.label .. ' is no longer valid. License revoked.', 'error')
                        print('^3[CityHall]^7 Player ' .. GetPlayerName(tonumber(playerId)) .. ' lost ' .. licenseData.label .. ' - License auto-revoked')
                    end
                    
                    -- If metadata says no license but item exists - grant it
                    if not licenseValid and hasItem then
                        player.PlayerData.metadata.licences[licenseKey] = true
                        player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)
                        
                        print('^2[CityHall]^7 Player ' .. GetPlayerName(tonumber(playerId)) .. ' recovered ' .. licenseData.label .. ' - License auto-granted')
                    end
                end
            end
        end
    end
end)

--- Export: Grant license via metadata (for admin scripts)
exports('grantLicense', function(source, licenseKey)
    local player = exports['qbx_core']:GetPlayer(source)
    if not player or not sharedConfig.licenses[licenseKey] then return false end

    if not player.PlayerData.metadata.licences then
        player.PlayerData.metadata.licences = {}
    end

    local licenseKey2 = licenseKey:gsub('_license', ''):gsub('_card', '')
    if player.PlayerData.metadata.licences[licenseKey2] then
        return false -- Already has license
    end

    player.PlayerData.metadata.licences[licenseKey2] = true
    player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)
    return true
end)

--- Event: Revoke license when item is dropped/removed from inventory
RegisterNetEvent('ox_inventory:itemDropped', function(itemName, amount, slot, metadata)
    -- Check if item is a license
    for licenseKey, licenseData in pairs(sharedConfig.licenses) do
        if licenseData.item == itemName then
            local source = source
            local player = exports['qbx_core']:GetPlayer(source)
            
            if not player then return end

            -- Verify item is actually gone from inventory
            local items = exports['ox_inventory']:GetInventoryItems(source)
            local itemStillExists = false
            
            if items then
                for _, item in ipairs(items) do
                    if item.name == itemName then
                        itemStillExists = true
                        break
                    end
                end
            end

            -- Only revoke if item is confirmed gone
            if not itemStillExists and player.PlayerData.metadata.licences then
                player.PlayerData.metadata.licences[licenseKey] = false
                player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)
                
                -- Notify player
                exports['qbx_core']:Notify(source, 'You dropped your ' .. licenseData.label .. '. License revoked.', 'error')
                print('^3[CityHall]^7 Player ' .. GetPlayerName(source) .. ' dropped ' .. licenseData.label .. ' - License revoked')
            end
            break
        end
    end
end)

--- Event: Revoke license when item is deleted/destroyed
RegisterNetEvent('ox_inventory:itemRemoved', function(itemName, amount, slot, metadata)
    -- Check if item is a license
    for licenseKey, licenseData in pairs(sharedConfig.licenses) do
        if licenseData.item == itemName then
            local source = source
            local player = exports['qbx_core']:GetPlayer(source)
            
            if not player then return end

            -- Verify item is actually gone from inventory
            local items = exports['ox_inventory']:GetInventoryItems(source)
            local itemStillExists = false
            
            if items then
                for _, item in ipairs(items) do
                    if item.name == itemName then
                        itemStillExists = true
                        break
                    end
                end
            end

            -- Only revoke if item is confirmed gone
            if not itemStillExists and player.PlayerData.metadata.licences then
                player.PlayerData.metadata.licences[licenseKey] = false
                player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)
                
                -- Notify player
                exports['qbx_core']:Notify(source, 'Your ' .. licenseData.label .. ' was removed. License revoked.', 'error')
                print('^3[CityHall]^7 Player ' .. GetPlayerName(source) .. ' lost ' .. licenseData.label .. ' - License revoked')
            end
            break
        end
    end
end)
