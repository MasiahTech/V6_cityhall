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
}
