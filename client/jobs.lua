-- EMPLOYMENT MODULE (Disabled by default - can be re-integrated)
-- This module was removed from main.lua for cleaner code separation
-- To re-enable: uncomment the require line in client/main.lua and add the menu option

local AVAILABLE_JOBS = {
    unemployed = 'Unemployed',
    trucker = 'Trucker',
    taxi = 'Taxi Driver',
    tow = 'Tow Truck Driver',
    reporter = 'News Reporter',
    garbage = 'Garbage Collector',
    bus = 'Bus Driver',
}

--- Opens the job selection menu
local function openJobMenu()
    local options = {}

    for jobName, jobLabel in pairs(AVAILABLE_JOBS) do
        local isCurrentJob = QBX.PlayerData.job.name == jobName
        local description = jobLabel
        
        if isCurrentJob then
            description = description .. ' ✓ (Current)'
        end

        options[#options + 1] = {
            title = jobLabel,
            description = description,
            icon = 'fa-solid fa-briefcase',
            args = jobName,
            onSelect = function(args)
                TriggerServerEvent('qbx_cityhall:server:applyJob', args)
            end,
        }
    end

    lib.registerContext({
        id = 'cityhall_jobs',
        title = locale('info.employment'),
        menu = 'cityhall_main',
        options = options,
        onExit = function()
            lib.showContext('cityhall_main')
        end,
    })

    lib.showContext('cityhall_jobs')
end

-- Export for other scripts to trigger job selection
exports('openJobMenu', openJobMenu)
