return {
    -- Interaction method:
    -- 'target' = ox_target (click NPC/point directly)
    -- 'textui' = Text UI prompt (E-key, classic style)
    interactionMethod = 'target',

    -- Interaction range for ox_target (in meters)
    targetRange = 2.5,

    -- Interaction range for text UI (in meters)
    textUIRange = 15,

    -- Interaction range for fraud locations (in meters) - for ox_target
    fraudTargetRange = 1.5,

    -- NPCs at City Hall locations
    peds = {
        { -- Main City Hall Assistant
            model = 'U_M_M_JewelSec_01',
            coords = vec4(256.12, -420.62, 46.77, 68.92),
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
        },
    },
}
