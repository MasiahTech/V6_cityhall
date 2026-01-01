local config = require 'config.client'
local sharedConfig = require 'config.shared'

-- State tracking
local fraudPoints = {} -- Interaction points for textui
local fraudZones = {} -- Zones for target method
local fraudBlips = {} -- Blips for fraud locations

--- Creates a blip for a fraud location
local function createFraudBlip(fraudLocation)
    local blip = AddBlipForCoord(fraudLocation.coords.x, fraudLocation.coords.y, fraudLocation.coords.z)
    SetBlipSprite(blip, fraudLocation.blip.sprite or 227)
    SetBlipDisplay(blip, fraudLocation.blip.display or 4)
    SetBlipScale(blip, fraudLocation.blip.scale or 0.6)
    SetBlipColour(blip, fraudLocation.blip.colour or 1)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(fraudLocation.blip.label or 'License Forge')
    EndTextCommandSetBlipName(blip)
    
    return blip
end

--- Initializes blips for all fraud locations
local function initFraudBlips()
    for i = 1, #sharedConfig.fraudLocations do
        local fraudLocation = sharedConfig.fraudLocations[i]
        if fraudLocation.showBlip and fraudLocation.blip then
            fraudBlips[#fraudBlips + 1] = createFraudBlip(fraudLocation)
        end
    end
end

--- Removes all fraud blips
local function deleteFraudBlips()
    for i = 1, #fraudBlips do
        if DoesBlipExist(fraudBlips[i]) then
            RemoveBlip(fraudBlips[i])
        end
    end
    fraudBlips = {}
end

--- Open crafting bench via export
local function openCraftingBench()
    print('^2[CityHall-Fraud]^7 Opening crafting bench...')
    exports['ox_inventory']:openInventory('crafting', {id='license_forge'})
end

--- Create interaction for all fraud locations (both textui and target)
local function createFraudPoints()
    for i = 1, #sharedConfig.fraudLocations do
        local fraudLocation = sharedConfig.fraudLocations[i]
        local fraudCoords = fraudLocation.coords
        
        -- Ensure coords is a vector3
        if type(fraudCoords) ~= 'vector3' then
            fraudCoords = vec3(fraudCoords.x, fraudCoords.y, fraudCoords.z)
        end
        
        if config.interactionMethod == 'textui' then
            -- Text UI interaction with lib.points
            fraudPoints[i] = lib.points.new({
                coords = fraudCoords,
                distance = config.textUIRange,
                onEnter = function()
                    lib.showTextUI('[E] License Forge')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                nearby = function()
                    if IsControlJustPressed(0, 38) then -- E key
                        openCraftingBench()
                        lib.hideTextUI()
                    end
                end,
            })
        elseif config.interactionMethod == 'target' then
            -- Target interaction using ox_target zones
            fraudZones[i] = exports.ox_target:addBoxZone({
                coords = fraudCoords,
                distance = config.fraudTargetRange,
                debug = false,
                options = {
                    {
                        name = 'license_forge_' .. i,
                        icon = 'fa-solid fa-flask-vial',
                        label = 'Forge License',
                        onSelect = function()
                            openCraftingBench()
                        end,
                    },
                },
            })
        end
    end
end

--- Remove all fraud points
local function removeFraudPoints()
    for i = 1, #fraudPoints do
        if fraudPoints[i] then
            fraudPoints[i]:remove()
        end
    end
    fraudPoints = {}
end

--- Remove all fraud zones
local function removeFraudZones()
    for i = 1, #fraudZones do
        if fraudZones[i] then
            exports.ox_target:removeZone(fraudZones[i])
        end
    end
    fraudZones = {}
end

--- Handle player loaded event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    initFraudBlips()
    createFraudPoints()
end)

--- Handle resource start
AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    initFraudBlips()
    createFraudPoints()
end)

--- Handle player unload
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteFraudBlips()
    removeFraudPoints()
    removeFraudZones()
end)

--- Handle resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    deleteFraudBlips()
    removeFraudPoints()
    removeFraudZones()
end)
