return {
    -- Available City Hall locations
    cityhalls = {
        {
            coords = vec3(-265.0, -963.6, 31.2),
            showBlip = false,
            blip = {
                label = 'City Services',
                shortRange = true,
                sprite = 487,
                display = 4,
                scale = 0.65,
                colour = 0,
            },
        },
    },

    -- License definitions: item name, display label, cost
    -- Licenses are only valid when physically present in inventory
    licenses = {
        ['id'] = {
            item = 'id_card',
            label = 'ID Card',
            cost = 50,
        },
        ['classa'] = {
            item = 'voucher_a',
            label = 'Class [A] Weapon License',
            cost = 250,
        },
        ['classb'] = {
            item = 'voucher_b',
            label = 'Class [B] Weapon License',
            cost = 250,
        },
        ['classc'] = {
            item = 'voucher_c',
            label = 'Class [C] Weapon License',
            cost = 250,
        },
        ['classd'] = {
            item = 'voucher_d',
            label = 'Class [D] Weapon License',
            cost = 250,
        },
    },

    -- Fraud system: Locations where players can forge licenses
    fraudLocations = {
        {
            name = 'Downtown Forge',
            coords = vec3(127.83, -1028.83, 28.45),
            showBlip = true,
            blip = {
                label = 'License Forge',
                sprite = 227,  -- Camera icon (suspicious)
                display = 4,
                scale = 0.6,
                colour = 1,  -- Red
            },
        },
        -- Add more locations as needed
    },

    -- Forged license definitions
    -- These operate exactly like regular licenses but with different item names
    forgedLicenses = {
        
        ['classa'] = {
            item = 'fvoucher_a',
            label = 'Forged Class [A] License',
            requiredItems = {
                { item = 'plastic', amount = 3 },
                { item = 'ink_cartridge', amount = 2 },
                { item = 'card_empty', amount = 1 },
            },
        },
        ['classb'] = {
            item = 'fvoucher_b',
            label = 'Forged Class [B] License',
            requiredItems = {
                { item = 'plastic', amount = 3 },
                { item = 'ink_cartridge', amount = 2 },
                { item = 'card_empty', amount = 1 },
            },
        },
        ['classc'] = {
            item = 'fvoucher_c',
            label = 'Forged Class [C] License',
            requiredItems = {
                { item = 'plastic', amount = 3 },
                { item = 'ink_cartridge', amount = 2 },
                { item = 'card_empty', amount = 1 },
            },
        },
        ['classd'] = {
            item = 'fvoucher_d',
            label = 'Forged Class [D] License',
            requiredItems = {
                { item = 'plastic', amount = 3 },
                { item = 'ink_cartridge', amount = 2 },
                { item = 'card_empty', amount = 1 },
            },
        },
    },
}
