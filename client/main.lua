local config = require 'config.client'
local sharedConfig = require 'config.shared'

-- State tracking
local playerNearPed = false
local pedsSpawned = false
local blips = {}

--- Gets the closest city hall location
local function getClosestCityhall()
    local playerCoords = GetEntityCoords(cache.ped)
    local closestIndex = 1
    local closestDistance = #(playerCoords - sharedConfig.cityhalls[1].coords)

    for i = 2, #sharedConfig.cityhalls do
        local distance = #(playerCoords - sharedConfig.cityhalls[i].coords)
        if distance < closestDistance then
            closestDistance = distance
            closestIndex = i
        end
    end

    return closestIndex, closestDistance
end

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
    local closestIndex = getClosestCityhall()
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
                -- Trigger purchase on server with error handling
                TriggerServerEvent('qbx_cityhall:server:purchaseLicense', args)
            end,
        }
    end

    -- Use ZSX-UI context menu
    lib.registerContext({
        id = 'cityhall_licenses',
        title = locale('info.licenses'),
        menu = 'cityhall_main',
        options = options,
        onExit = function()
            if playerNearPed then
                lib.showTextUI(locale('info.open_cityhall'))
            end
        end,
    })

    lib.showContext('cityhall_licenses')
end

--- Opens the main city hall menu
local function openMainMenu()
    local options = {
        {
            title = locale('info.licenses'),
            description = locale('info.obtain_licenses'),
            icon = 'fa-solid fa-scroll',
            onSelect = function()
                openLicenseMenu()
            end,
        },
    }

    -- Register main context menu
    lib.registerContext({
        id = 'cityhall_main',
        title = locale('info.cityhall'),
        options = options,
        onExit = function()
            if playerNearPed then
                lib.showTextUI(locale('info.open_cityhall'))
            end
        end,
    })

    lib.showContext('cityhall_main')
end

--- Creates a blip for a city hall location
local function createBlip(cityhall)
    local blip = AddBlipForCoord(cityhall.coords.x, cityhall.coords.y, cityhall.coords.z)
    SetBlipSprite(blip, cityhall.blip.sprite or 1)
    SetBlipDisplay(blip, cityhall.blip.display or 4)
    SetBlipScale(blip, cityhall.blip.scale or 1.0)
    SetBlipColour(blip, cityhall.blip.colour or 1)
    SetBlipAsShortRange(blip, cityhall.blip.shortRange or false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(cityhall.blip.label or locale('info.cityhall'))
    EndTextCommandSetBlipName(blip)
    return blip
end

local function deleteBlips()
    if not blips then return end
    for i = 1, #blips do
        local blip = blips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function initBlips()
    for i = 1, #sharedConfig.cityhalls do
        local cityhall = sharedConfig.cityhalls[i]

        if not cityhall.showBlip or not cityhall.blip then return end

        blips[#blips + 1] = createBlip({blip = cityhall.blip, coords = cityhall.coords})
    end
end


--- Spawns city hall NPCs and sets up interactions
local function spawnPeds()
    if not config.peds or not next(config.peds) or pedsSpawned then return end
    for i = 1, #config.peds do
        local current = config.peds[i]
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        lib.requestModel(current.model, 5000)
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        SetModelAsNoLongerNeeded(current.model)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, 0, true)
        current.pedHandle = ped
        if config.useTarget then
            exports.ox_target:addLocalEntity(ped, {{
                name = 'cityhall_main' .. i,
                icon = 'fa-solid fa-city',
                label = locale('info.target_open_cityhall'),
                distance = 1.5,
                debug = true,
                onSelect = function()
                    inRangeCityhall = true
                    openMainMenu()
                end
            }})
        else
            local options = current.zoneOptions
            if options then
                lib.zones.box({
                    name = 'cityhall',
                    coords = current.coords.xyz,
                    size = vec3(2, 2, 3),
                    rotation = current.coords.w,
                    debug = false,
                    onEnter = function()
                        inRangeCityhall = true
                        lib.showTextUI(locale('info.open_cityhall'))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                        inRangeCityhall = false
                    end,
                    inside = function()
                        if IsControlJustPressed(0, 38) then
                            openCityhallMenu()
                            lib.hideTextUI()
                        end
                    end,
                })
            end
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not config.peds or not next(config.peds) or not pedsSpawned then return end
    for i = 1, #config.peds do
        local current = config.peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end


--- Handle player loaded event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    initBlips()
    spawnPeds()
end)

--- Handle resource start
AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end
    initBlips()
    spawnPeds()
end)

--- Handle player unload
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteBlips()
    deletePeds()
end)

--- Handle resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    deleteBlips()
    deletePeds()
end)

--- Update player data on inventory change (refresh license status)
RegisterNetEvent('inventory:itemUpdate', function()
    -- License status will be re-checked when menu opens
end)
