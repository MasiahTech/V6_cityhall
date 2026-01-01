local sharedConfig = require 'config.shared'

--- Build crafting items for ox_inventory RegisterCraftStation
local function buildCraftingItems()
    local items = {}
    
    for licenseKey, licenseData in pairs(sharedConfig.forgedLicenses) do
        if licenseData.requiredItems and #licenseData.requiredItems > 0 then
            local item = {
                name = licenseData.item,
                label = licenseData.label,
                ingredients = {}
            }
            
            -- Convert requiredItems to ingredients format (as key-value pairs)
            for _, material in ipairs(licenseData.requiredItems) do
                item.ingredients[material.item] = material.amount
            end
            
            table.insert(items, item)
        end
    end
    
    return items
end

--- Register crafting station with ox_inventory on startup
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(3000)
        
        local items = buildCraftingItems()
        
        if #items > 0 then
            print('^2[CityHall-Fraud]^7 Registering crafting station...')
            
            -- Register crafting station with correct ox_inventory format
            exports.ox_inventory:RegisterCraftStation('license_forge', {
                name = 'License Forge',
                items = items
            })
            
            print('^2[CityHall-Fraud]^7 Crafting station registered with ' .. #items .. ' recipes')
            for i, item in ipairs(items) do
                print('^3  - ' .. item.name .. ' (' .. item.label .. ')^7')
            end
        else
            print('^1[CityHall-Fraud]^7 ERROR: No forged licenses configured!')
        end
    end
end)



--- Helper: Find forged license by item name
local function findForgedLicenseByItem(itemName)
    for key, data in pairs(sharedConfig.forgedLicenses) do
        if data.item == itemName then
            return key, data
        end
    end
    return nil, nil
end

--- Check if player has a forged license
exports('hasForgedLicense', function(source, licenseKey)
    if not sharedConfig.forgedLicenses[licenseKey] then return false end
    
    local licenseData = sharedConfig.forgedLicenses[licenseKey]
    
    if GetResourceState('ox_inventory') == 'started' then
        local items = exports['ox_inventory']:GetInventoryItems(source)
        if items then
            for _, item in ipairs(items) do
                if item.name == licenseData.item then
                    return true
                end
            end
        end
    end

    return false
end)

--- Check if player has either real or forged license
exports('hasAnyLicense', function(source, licenseKey)
    -- Check real license first
    local realLicenseData = sharedConfig.licenses[licenseKey]
    if realLicenseData then
        if GetResourceState('ox_inventory') == 'started' then
            local items = exports['ox_inventory']:GetInventoryItems(source)
            if items then
                for _, item in ipairs(items) do
                    if item.name == realLicenseData.item then
                        return true, 'real'
                    end
                end
            end
        end
    end

    -- Check forged license
    local forgedLicenseData = sharedConfig.forgedLicenses[licenseKey]
    if forgedLicenseData then
        if GetResourceState('ox_inventory') == 'started' then
            local items = exports['ox_inventory']:GetInventoryItems(source)
            if items then
                for _, item in ipairs(items) do
                    if item.name == forgedLicenseData.item then
                        return true, 'forged'
                    end
                end
            end
        end
    end

    return false, 'none'
end)


