local config = require 'config.client'
local sharedConfig = require 'config.shared'

-- State tracking
local blips = {}
local points = {} -- Interaction points for textui
local peds = {} -- Spawned PEDs

--- Checks if player has license item in inventory
--- @param item string - Item name to check
--- @return boolean - True if player has the item
local function hasLicense(item)
    if not QBX or not QBX.PlayerData or not QBX.PlayerData.items then
        return false
    end

    for _, itemData in ipairs(QBX.PlayerData.items) do
        if itemData and itemData.name == item then
            return true
        end
    end

    return false
end

--- Opens the main license purchase menu
local function openLicenseMenu()
    local options = {}

    -- Build menu options for each available license
    for licenseKey, licenseData in pairs(sharedConfig.licenses) do
        local hasItem = hasLicense(licenseData.item)
        local description = string.format('Price: $%d', licenseData.cost)
        
        if hasItem then
            description = description .. ' ✓ (Owned)'
        end

        options[#options + 1] = {
            title = licenseData.label,
            description = description,
            icon = 'fa-solid fa-id-card',
            args = licenseKey,
            onSelect = function(args)
                TriggerServerEvent('qbx_cityhall:server:purchaseLicense', args)
            end,
        }
    end

    lib.registerContext({
        id = 'cityhall_licenses',
        title = 'Licenses',
        menu = 'cityhall_main',
        options = options,
    })

    lib.showContext('cityhall_licenses')
end

--- Opens the main city hall menu
local function openMainMenu()
    local options = {
        {
            title = 'Licenses',
            description = 'Purchase licenses',
            icon = 'fa-solid fa-scroll',
            onSelect = function()
                openLicenseMenu()
            end,
        },
    }

    lib.registerContext({
        id = 'cityhall_main',
        title = 'City Hall',
        options = options,
    })

    lib.showContext('cityhall_main')
end

--- Creates a blip for a city hall location
local function createBlip(cityhall)
    local blip = AddBlipForCoord(cityhall.coords.x, cityhall.coords.y, cityhall.coords.z)
    SetBlipSprite(blip, cityhall.blip.sprite or 487)
    SetBlipDisplay(blip, cityhall.blip.display or 4)
    SetBlipScale(blip, cityhall.blip.scale or 0.65)
    SetBlipColour(blip, cityhall.blip.colour or 0)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(cityhall.blip.label or 'City Hall')
    EndTextCommandSetBlipName(blip)
    
    return blip
end

--- Initializes blips for all city halls
local function initBlips()
    for i = 1, #sharedConfig.cityhalls do
        local cityhall = sharedConfig.cityhalls[i]
        if cityhall.showBlip and cityhall.blip then
            blips[#blips + 1] = createBlip(cityhall)
        end
    end
end

--- Removes all blips
local function deleteBlips()
    for i = 1, #blips do
        if DoesBlipExist(blips[i]) then
            RemoveBlip(blips[i])
        end
    end
    blips = {}
end

--- Spawns city hall NPCs and sets up interactions (BOTH METHODS)
local function spawnPeds()
    if not config.peds or not next(config.peds) then return end

    for i = 1, #config.peds do
        local pedConfig = config.peds[i]
        local model = type(pedConfig.model) == 'string' and joaat(pedConfig.model) or pedConfig.model

        lib.requestModel(model, 5000)
        
        local ped = CreatePed(4, model, pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z, pedConfig.coords.w, false, false)
        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)

        if config.interactionMethod == 'target' then
            -- Use ox_target for interaction
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'cityhall_open',
                    icon = 'fa-solid fa-city',
                    label = 'Open City Hall',
                    distance = config.targetRange,
                    onSelect = function()
                        openMainMenu()
                    end,
                },
            })
        end
        
        peds[i] = ped
    end
end

--- Delete spawned PEDs
local function deletePeds()
    for i = 1, #peds do
        if peds[i] and DoesEntityExist(peds[i]) then
            DeleteEntity(peds[i])
        end
    end
    peds = {}
end

--- Create interaction points for all city halls (TEXTUI METHOD - uses PED location)
local function createCityHallPoints()
    if config.interactionMethod ~= 'textui' then return end
    
    print('^2[CityHall]^7 Creating textui points for ' .. #config.peds .. ' peds')
    
    for i = 1, #config.peds do
        local pedConfig = config.peds[i]
        local pedCoords = vec3(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z)
        
        print('^2[CityHall]^7 Creating point at ped location: ' .. tostring(pedCoords))
        
        points[i] = lib.points.new({
            coords = pedCoords,
            distance = config.textUIRange,
            onEnter = function()
                print('^2[CityHall]^7 Entered point range')
                lib.showTextUI('[E] Open City Hall')
            end,
            onExit = function()
                print('^2[CityHall]^7 Exited point range')
                lib.hideTextUI()
            end,
            nearby = function()
                if IsControlJustPressed(0, 38) then -- E key
                    print('^2[CityHall]^7 E key pressed, opening menu')
                    openMainMenu()
                    lib.hideTextUI()
                end
            end,
        })
    end
end

--- Remove all interaction points
local function removeCityHallPoints()
    for i = 1, #points do
        if points[i] then
            points[i]:remove()
        end
    end
    points = {}
end

--- Handle player loaded event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    print('^2[CityHall]^7 Player loaded, interaction method: ' .. config.interactionMethod)
    initBlips()
    spawnPeds()
    createCityHallPoints()
end)

--- Handle resource start
AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    print('^2[CityHall]^7 Resource started, interaction method: ' .. config.interactionMethod)
    initBlips()
    spawnPeds()
    createCityHallPoints()
end)

--- Handle player unload
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    print('^2[CityHall]^7 Player unloaded')
    deleteBlips()
    deletePeds()
    removeCityHallPoints()
end)

--- Handle resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    print('^2[CityHall]^7 Resource stopped')
    deleteBlips()
    deletePeds()
    removeCityHallPoints()
end)
