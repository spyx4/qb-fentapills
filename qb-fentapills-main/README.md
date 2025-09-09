# qb-pillcraft

A FiveM QBCore script that allows players to **farm ingredients**, **craft healing pills**, and **use them with effects**.  
Players level up their pill-crafting skill the more they craft.

---

## 📦 Features
- Farming system with props (broken pills & fenta syrup).
- Crafting system with progress bar + animations.
- Pills with 3 levels (stronger effects each tier).
- Level progression:
  - Level 1 → default.
  - Level 2 → unlocked after 3000 crafts.
  - Level 3 → unlocked after 6000 crafts.
- Usable pills (restore health & armor).
- Chat command `/pillinfo` → check your progress (level, crafted amount, remaining to next level).

---

## ⚙️ Installation
1. Clone or download this resource into your `resources/[qb]` folder:

2. Add the following to your **server.cfg**:

3. Make sure you have the items in **`qb-core/shared/items.lua`**:

```lua
	fenta_syrup                  = { name = 'fenta_syrup', label = 'Fenta Syrup', weight = 100, type = 'item', image = 'fenta_syrup.png', unique = false, useable = false, shouldClose = true, description = 'A syrup base laced with fentanyl, very potent.' },
    broken_pills                  = { name = 'broken_pills', label = 'Broken Pills', weight = 100, type = 'item', image = 'broken_pills.png', unique = false, useable = false, shouldClose = true, description = 'Crushed or broken pills, used to make street mixes.' },
    healing_pill_lv1                  = { name = 'healing_pill_lv1', label = 'Healing Pill (Level 1)', weight = 100, type = 'item', image = 'healing_pill_lv1.png', unique = false, useable = true, shouldClose = true, description = 'Restores a little health and armor' },
	healing_pill_lv2                  = { name = 'healing_pill_lv2', label = 'Healing Pill (Level 2)', weight = 100, type = 'item', image = 'healing_pill_lv2.png', unique = false, useable = true, shouldClose = true, description = 'Restores a little health and armor' },
    healing_pill_lv3                  = { name = 'healing_pill_lv3', label = 'Healing Pill (Level 3)', weight = 100, type = 'item', image = 'healing_pill_lv3.png', unique = false, useable = true, shouldClose = true, description = 'Restores a little health and armor' },
	```
4. Add the corresponding images (PNG) to
	```qb-inventory/html/images```
	
5. Go to the farming zones to collect:

```Broken Pills 

Fenta Syrup 
```

Use the lab zone to craft pills.

Pills are usable items that restore health & armor.

Use the chat command:
```/pillinfo``` to check your current level and remaining crafts until the next level

