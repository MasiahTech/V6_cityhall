# 🏛️ V6 Cityhall

**Complete license management system for QBCore/QBX** with license purchases at City Hall and crafting-based forgery.

---

## ✨ Features

- 📋 **Buy Licenses** - Purchase real licenses at City Hall
- 🔨 **Forge Licenses** - Craft fake licenses using ox_inventory crafting system
- 🔄 **Auto Metadata Sync** - Licenses automatically grant/revoke metadata
- 🎯 **Flexible Interactions** - Choose ox_target clicks or E-key prompts
- 🛡️ **Server-Side Validation** - Prevents exploits and duplication
- 🌍 **Multi-Language** - 10+ languages included

---

## 🚀 Installation


### 1. Add to server.cfg
```
ensure v6_cityhall
```

### 2. Add Items to ox_inventory

Add to `ox_inventory/data/items.lua`:

```lua
-- Real Licenses
['id_card'] = { label = 'ID Card', weight = 0, stack = false },
['driver_license'] = { label = 'Driver License', weight = 0, stack = false },
['weaponlicense'] = { label = 'Weapon License', weight = 0, stack = false },

-- Forged Licenses
['fvoucher_d'] = { label = 'Forged Class D License', weight = 0, stack = false },
['fvoucher_a'] = { label = 'Forged Class A License', weight = 0, stack = false },
['fvoucher_b'] = { label = 'Forged Class B License', weight = 0, stack = false },

-- Materials
['plastic'] = { label = 'Plastic', weight = 100, stack = true },
['ink_cartridge'] = { label = 'Ink Cartridge', weight = 50, stack = true },
['security_chip'] = { label = 'Security Chip', weight = 50, stack = true },
```

### 3. ⚠️ CRITICAL - ox_inventory Setup

Your ox_inventory `fxmanifest.lua` **MUST** include `modules/Crafting.lua`:

```lua
shared_scripts {
    '@ox_lib/init.lua',
    'locale.lua',
    'modules/Items.lua',
    'modules/Crafting.lua',  -- REQUIRED for crafting to work
}
```

See [ox_inventory crafting docs](https://docs.mt-scripts.com/workshops/installation#ox-inventory-craft-changes) for details.

---

## ⚙️ Configuration

### Client (`config/client.lua`)

```lua
return {
    interactionMethod = 'target',  -- 'target' or 'textui'
    targetRange = 2.5,             -- Click range for ox_target
    fraudTargetRange = 1.5,        -- Forgery location range
    textUIRange = 15,              -- E-key prompt range
}
```

### Shared (`config/shared.lua`)

**City Hall Locations:**
```lua
cityhalls = {
    {
        coords = vec3(-265.0, -963.6, 31.2),
        showBlip = true,
        blip = { label = 'City Hall', sprite = 487, display = 4, scale = 0.65, colour = 0 },
    },
}
```

**Real Licenses:**
```lua
licenses = {
    ['id'] = { item = 'id_card', label = 'ID Card', cost = 50 },
    ['driver'] = { item = 'driver_license', label = 'Driver License', cost = 50 },
    ['weapon'] = { item = 'weaponlicense', label = 'Weapon License', cost = 250 },
}
```

**Forgery Locations:**
```lua
fraudLocations = {
    {
        coords = vec3(127.83, -1028.83, 28.45),
        showBlip = true,
        blip = { label = 'License Forge', sprite = 227, display = 4, scale = 0.6, colour = 1 },
    },
}
```

**Forgery Recipes:**
```lua
forgedLicenses = {
    ['classa'] = {
        item = 'fvoucher_a',
        label = 'Forged Class A License',
        requiredItems = {
            { item = 'plastic', amount = 3 },
            { item = 'ink_cartridge', amount = 2 },
            { item = 'security_chip', amount = 1 },
        },
    },
}
```

---

## 🎮 How It Works

**Buying Licenses:**
1. Go to City Hall
2. Click NPC (ox_target) or press E (textui)
3. Select license to purchase
4. License item added + metadata granted automatically

**Forging Licenses:**
1. Gather materials (plastic, ink cartridge, security chip)
2. Go to forge location
3. Click location to open crafting bench
4. Select recipe and craft
5. Forged license item added + metadata granted automatically
6. Works identically to real licenses

**How Metadata Works:**
- When you have a license item → metadata automatically set to `true`
- When you drop/lose the item → metadata automatically set to `false`
- Server checks both item AND metadata for validity
- Syncs every 5 seconds

---

## 📚 Server Exports

### Check License (works for real & forged)
```lua
if exports['qbx_cityhall']:hasValidLicense(source, 'weapon') then
    -- Player has weapon license (real or forged)
    TriggerEvent('weapon_shop:allowPurchase')
end
```

### Grant License
```lua
exports['qbx_cityhall']:grantLicense(source, 'driver')
```

---

## 🎯 Interaction Methods

**Option 1: ox_target (Recommended)**
- Set `interactionMethod = 'target'` in config
- Click directly on NPCs and locations
- Requires ox_target running

**Option 2: Text UI (Lightweight)**
- Set `interactionMethod = 'textui'` in config
- Press E near locations
- Only requires ox_lib

---

## 🛠️ Customization

**Add New License Type:**

1. Edit `config/shared.lua`:
```lua
licenses = {
    ['pilot'] = { item = 'pilot_license', label = 'Pilot License', cost = 1000 },
}
```

2. Add item to ox_inventory
3. Restart: `refresh qbx_cityhall`

**Add Forgery Recipe:**

1. Edit `config/shared.lua`:
```lua
forgedLicenses = {
    ['pilot'] = {
        item = 'forged_pilot_license',
        label = 'Forged Pilot License',
        requiredItems = {
            { item = 'plastic', amount = 5 },
            { item = 'ink_cartridge', amount = 3 },
            { item = 'security_chip', amount = 2 },
        },
    },
}
```

2. Add forged item to ox_inventory
3. Restart: `refresh qbx_cityhall`

---

## 🐛 Troubleshooting

**Crafting bench won't open?**
- Verify ox_inventory has `modules/Crafting.lua` in shared_scripts
- Restart ox_inventory: `refresh ox_inventory`
- Check server console for errors

**Can't use forged license?**
- Wait 5 seconds for metadata to sync
- Check you have the item in inventory
- Verify item name matches config exactly

**License menu won't open?**
- If ox_target: ensure it's running
- If textui: press E within range
- Check NPC spawned: `/debug ped` at City Hall

**Materials not consuming?**
- Verify item names match ox_inventory exactly
- Test with: `/giveitem plastic 5`
- Check server logs for errors

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| Client Load | Negligible |
| Memory | ~150KB |
| Server Load | Event-driven (optimized) |
| Metadata Sync | On inventory change + fallback every 30 sec |
| Scales to | 500+ players |

---

## 📦 Dependencies

**Required:**
- `qbx_core` - QBX Framework
- `ox_lib` - UI library
- `ox_inventory` - Inventory with Crafting enabled

**Recommended:**
- `ox_target` - Modern interactions

---

## ✅ Quick Start

1. ✅ Add all items to ox_inventory
2. ✅ Enable `modules/Crafting.lua` in ox_inventory fxmanifest
3. ✅ Configure locations in `config/shared.lua`
4. ✅ Choose interaction method in `config/client.lua`
5. ✅ Start resource
6. ✅ Test license purchase at City Hall
7. ✅ Test forgery at forge location

---

## 🤝 Support

**Issues?**
1. Check Troubleshooting section above
2. Check server console: `con`
3. Verify ox_inventory has crafting enabled
4. Verify all items are in ox_inventory

**Pro Tips:**
- Use `/giveitem plastic 5` to quickly test forgery
- Use `/debug ped` to verify NPCs spawn
- Restart ox_inventory if crafting doesn't work: `refresh ox_inventory`

---

**Happy roleplaying!** 🎉
