# V6_Cityhall

A complete City Hall resource for QBox framework with inventory-based license system, automatic metadata synchronization, and ZSX point integration.

## Features

### 🎫 Advanced License System
- **Inventory-Based Validation**: Licenses are physical items in ox_inventory
- **Metadata Synchronization**: Automatically syncs with metadata for compatibility
- **Auto-Revoke on Drop**: When players drop a license item, metadata is instantly revoked
- **Three License Types**:
  - ID Card ($50)
  - Driver License ($50)
  - Weapon License ($250)

### 🎮 Modern Interaction System
- **ZSX Point System**: Visual points appear when within 25 meters (working on it)
- **ox_target Support**: Optional targeting system for direct NPC clicks
- **Clean Menu Interface**: Professional ox_lib context menus with ownership status
- **No Proximity Distance Limits**: Menu can be accessed from anywhere (client-side handled)

### 🔒 Security Features
- **Server-Side Validation**: All purchases validated server-side
- **Anti-Exploit Protection**: Prevents remote license purchases
- **Inventory Space Check**: Refunds money if inventory is full
- **Automatic Metadata Sync**: Every 5 seconds, verifies inventory/metadata match

### 🌍 Multi-Location Support
- Multiple City Hall locations with configurable blips
- Each location has spawned NPCs
- Easy to add new locations via config

### 🎨 Customization Ready
- Fully configurable license types and prices
- Support for multiple languages via locale files
- Easy to extend with new features
- Modular job system (can be re-enabled)

---

## Installation

### 1. Download and Extract


### 2. Add to Server.cfg
```
ensure v6_cityhall
```

### 3. Add License Items to ox_inventory
Add these items to your ox_inventory items config (items.lua or database):

```lua
['id_card'] = {
    label = 'ID Card',
    weight = 0,
    stack = false,
    description = 'Your identification card'
},
['driver_license'] = {
    label = 'Driver License',
    weight = 0,
    stack = false,
    description = 'Your driver license'
},
['weaponlicense'] = {
    label = 'Weapon License',
    weight = 0,
    stack = false,
    description = 'Your weapon license'
},
```

Or via SQL:
```sql
INSERT INTO items (name, label, weight, stack, description) VALUES
('id_card', 'ID Card', 0, 0, 'Your identification card'),
('driver_license', 'Driver License', 0, 0, 'Your driver license'),
('weaponlicense', 'Weapon License', 0, 0, 'Your weapon license');
```

### 4. Start the Resource
```
start v6_cityhall
```

---

## Configuration

### Client Configuration (`config/client.lua`)

```lua
return {
    -- Interaction method: true = ox_target, false = ZSX points
    useTarget = true,

    -- NPCs at City Hall locations
    peds = {
        { -- Main City Hall Assistant
            model = 'U_M_M_JewelSec_01',
            coords = vec4(256.12, -420.62, 46.77, 68.92),
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
        },
    },
}
```

### Shared Configuration (`config/shared.lua`)

```lua
-- City Hall Locations
cityhalls = {
    {
        coords = vec3(-265.0, -963.6, 31.2),
        showBlip = true,
        blip = {
            label = 'City Hall',
            sprite = 487,
            display = 4,
            scale = 0.65,
            colour = 0,
        },
    },
}

-- Available Licenses
licenses = {
    ['id'] = {
        item = 'id_card',
        label = 'ID Card',
        cost = 50,
    },
    ['driver'] = {
        item = 'driver_license',
        label = 'Driver License',
        cost = 50,
    },
    ['weapon'] = {
        item = 'weaponlicense',
        label = 'Weapon License',
        cost = 250,
    },
}
```

---

## How It Works

### License Purchase Flow

1. Player approaches City Hall NPC
2. **With ox_target enabled**: Click NPC or target to open menu
3. **With ZSX points enabled**: Point appears within 25 meters, click to open menu (Textui)
4. Menu shows available licenses with prices
5. Click to purchase (if affordable and don't already own)
6. License is added to inventory + metadata granted
7. License shows as "✓ Owned" in menu

### Metadata Synchronization

- **Purchase**: License added to inventory + metadata set to `true`
- **Drop Item**: Item removed from inventory, metadata synced within 5 seconds and set to `false`
- **Auto-Recovery**: If item reappears, metadata is automatically re-granted
- **Fallback Notifications**: Players notified when licenses are auto-revoked

### Compatibility with Existing Systems

Your existing weapon shops and systems that check `player.PlayerData.metadata.licences.weapon` will work seamlessly:
- Metadata is automatically kept in sync with inventory
- If player drops the license item, metadata is revoked within 5 seconds
- Weapon shops check metadata and automatically deny purchase
- **No modifications to other scripts required**

---

## Server Exports

### Check if Player Has License
```lua
if exports['qbx_cityhall']:hasValidLicense(source, 'weapon') then
    -- Player has weapon license
end
```

**Parameters:**
- `source` (number): Player server ID
- `licenseKey` (string): License key ('id', 'driver', 'weapon')

**Returns:** boolean

### Grant License via Code
```lua
exports['qbx_cityhall']:grantLicense(playerId, 'driver')
```

**Parameters:**
- `playerId` (number): Player server ID
- `licenseKey` (string): License key ('id', 'driver', 'weapon')

**Returns:** boolean (success/failure)

---

## Server Events

### Grant License to Another Player
```lua
TriggerServerEvent('qbx_cityhall:server:grantLicenseMetadata', targetPlayerId, 'weapon')
```

**Parameters:**
- `targetPlayerId` (number): Target player ID
- `licenseKey` (string): License key ('id', 'driver', 'weapon')

---

## Customization Guide

### Adding a New License Type

**Step 1:** Edit `config/shared.lua`
```lua
licenses = {
    ['pilot'] = {
        item = 'pilot_license',
        label = 'Pilot License',
        cost = 1000,
    },
}
```

**Step 2:** Add item to ox_inventory
```lua
['pilot_license'] = {
    label = 'Pilot License',
    weight = 0,
    stack = false,
    description = 'Your pilot license'
},
```

**Step 3:** Restart resource

### Changing License Prices

Edit `config/shared.lua`:
```lua
['weapon'] = {
    item = 'weaponlicense',
    label = 'Weapon License',
    cost = 500,  -- Changed from 250
},
```

### Adding City Hall Locations

Edit `config/shared.lua`:
```lua
cityhalls = {
    {
        coords = vec3(-265.0, -963.6, 31.2),
        showBlip = true,
        blip = {
            label = 'City Hall',
            sprite = 487,
            display = 4,
            scale = 0.65,
            colour = 0,
        },
    },
    {
        coords = vec3(500.0, 100.0, 150.0),
        showBlip = true,
        blip = {
            label = 'North City Hall',
            sprite = 487,
            display = 4,
            scale = 0.65,
            colour = 0,
        },
    },
}
```

### Re-Enabling Job System (Optional)

The job system is disabled by default but can be re-enabled:

**Step 1:** Uncomment in `fxmanifest.lua`:
```lua
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    -- 'client/jobs.lua',  -- UNCOMMENT THIS
}

server_scripts {
    'server/main.lua',
    -- 'server/jobs.lua',  -- UNCOMMENT THIS
}
```

**Step 2:** Restart resource

---

## Interaction Methods

### Option 1: ox_target (Recommended)
Set `useTarget = true` in `config/client.lua`
- Click NPC with targeting cursor
- Fast and intuitive
- Requires ox_target dependency

### Option 2: ZSX Points (just text ui rn)
Set `useTarget = false` in `config/client.lua`
- Visual point system appears at 25 meters
- Click point to open menu
- No additional dependencies needed

---

## Performance

| Metric | Value |
|--------|-------|
| Client Load | Negligible |
| Server Load | Minimal |
| Memory Footprint | ~100KB |
| Distance Checks | None (removed) |
| Metadata Sync Interval | 5 seconds |
| Blip Count | 1 per location |

---

## Dependencies

- **qb-core** or **qbx_core** - Framework
- **ox_lib** - UI and utilities
- **ox_inventory** - Inventory system
- **ox_target** - Optional (if useTarget = true)

---

## Troubleshooting

### License Not Appearing in Menu as "Owned"
- Verify ox_inventory has the license items configured
- Check that item names match config exactly
- Test with `/giveitem id_card 1`

### Menu Won't Open
- Ensure ox_target is running (if `useTarget = true`)
- Check that NPC is spawning
- Verify ZSX points appear within 25 meters

### Metadata Not Syncing
- Check that ox_inventory is running
- Verify server console for errors
- Restart resource and try again
- Check player data is loading properly

### Weapon Shop Still Allows Purchase After Dropping License
- Metadata sync runs every 5 seconds
- Wait a few seconds and try purchasing again
- Metadata should be revoked automatically
- If still broken, check logs for inventory sync errors

---

## Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Inventory is full" | No inventory space | Drop items to make room |
| "Invalid license type" | Wrong license key | Check config/shared.lua |
| "Already have license" | Item already in inventory | Use the license or drop it |
| "Not enough money" | Insufficient funds | Earn more money |
| "License revoked" | Item was dropped | Notification when auto-revoked |

---

## File Structure

```
v6_cityhall/
├── client/
│   ├── main.lua              # Core client (licenses, menus, ZSX points) WIP
│   └── jobs.lua              # Job system (disabled by default)
├── server/
│   ├── main.lua              # Core server (validation, metadata sync)
│   └── jobs.lua              # Job events (disabled by default)
├── config/
│   ├── client.lua            # Client configuration
│   └── shared.lua            # Shared configuration
├── locales/
│   ├── en.json               # English translations
│   ├── es.json               # Spanish translations
│   └── (other languages)
├── fxmanifest.lua            # Resource manifest
└── README.md                 # This file
```

---

## Version History

### V6_Cityhall (Current)
- ✅ Automatic metadata synchronization (every 5 seconds)
- ✅ License revocation on item drop
- ✅ ZSX point system integration (25m range) (Working on it)
- ✅ Removed server-side distance checks
- ✅ ox_target optional support
- ✅ Dual license validation (inventory + metadata)
- ✅ Multi-language support
- ✅ Job system modular (disabled by default)

### Previous Features
- Inventory-based license system
- License purchase at City Hall
- Configurable prices and locations
- Multiple City Hall locations with blips
- Server-side validation and anti-exploit protection

---

## Contributing

Found a bug or have a suggestion? Submit an issue with:
1. Description of the problem
2. Steps to reproduce
3. Server console errors (if any)
4. Your configuration

---

## License

This resource is provided as-is for use with FiveM servers.

---

## Support

For issues or questions, check the Troubleshooting section above or review your server logs for detailed error messages.

**Pro Tip**: Use `/debug ped` to verify NPCs are spawning correctly at City Hall locations.
