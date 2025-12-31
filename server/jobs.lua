-- EMPLOYMENT MODULE (Disabled by default - can be re-integrated)
-- This module was removed from main.lua for cleaner code separation
-- To re-enable: uncomment the require line in server/main.lua and add the menu option in client/main.lua

-- Uncomment the line below to enable the employment system:
-- local jobsEnabled = true

-- If re-integrating, add this to the main menu in client/main.lua:
--[[ 
    options[#options + 1] = {
        title = locale('info.employment'),
        description = locale('info.select_job'),
        icon = 'fa-solid fa-briefcase',
        onSelect = function()
            openJobMenu()
        end,
    }
--]]

local QBCore = exports['qbx_core']:GetCoreObject()

-- Available jobs configuration
local AVAILABLE_JOBS = {
    unemployed = 'Unemployed',
    trucker = 'Trucker',
    taxi = 'Taxi Driver',
    tow = 'Tow Truck Driver',
    reporter = 'News Reporter',
    garbage = 'Garbage Collector',
    bus = 'Bus Driver',
}

--- Event: Apply for a job
--- Validates job selection and applies employment
RegisterNetEvent('qbx_cityhall:server:applyJob', function(jobName)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    if not player then return end
    
    -- Validate job exists
    if not AVAILABLE_JOBS[jobName] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid job selection',
        })
        return
    end

    -- Set job (grade 0 = entry level)
    player.Functions.SetJob(jobName, 0)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = locale('success.title'),
        description = locale('success.new_job'),
    })
end)

-- Export for checking if player has specific job
exports('getPlayerJob', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return nil end
    return player.PlayerData.job.name
end)
