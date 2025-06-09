# Turrext_sell
Gang Shipment &amp; Zone Control System for FiveM for QBCore
# 🚨 Gang Shipment & Zone Control System for FiveM

> **Release Date:** January 24, 2024  
> **Framework:** QB-Core  
> **Inventory Support:** QB or OX  
> **Author:** Turrext  
> **Version:** 1.0

A modular and immersive FiveM script for QB-Core featuring dynamic gang territories, interactive NPCs, timed shipment drops, and a black-market system. Fully configurable and optimized for RP servers seeking deeper criminal gameplay.

---

## 🔥 Key Features

- 📜 Customizable gang zones with blips and radii
- 👥 NPC behavior control (patrol, freeze, notify police)
- 🚔 Rival gang interrogation mechanic
- 🚚 Scheduled shipment drops with expiration logic
- 💲 Configurable black market store (items & weapons)
- ⚙️ Supports both QB and OX inventory
- 🎯 Highly optimized and easy to extend

---

## ⚙️ Configuration Highlights

```lua
Config.Framework = "QB" -- or "ESX"
Config.Inventory = "QB" -- or "OX"
Config.ShowPedLoc = true
Config.InstantRespawnAfterPedDeath = true
Config.RivalGangInterrogateChance = 50
Config.GlobalShipmentDropTimer = 20 * 1000
Config.GlobalShipmentExpireTimer = 60 * 1000
Config.ShowShipmentBlipAnyone = true
Config.Account = "bank"
```

### 📍 Example Zone

- **Location:** `(-1480.96, -344.8, 44.16)`
- **Radius:** 120m  
- **NPC Options:** Freeze, Invincible, Police Alert Chance

### 📦 Shipment Drop Example

- **Coords:** `(-1575.72, -3012.2, 13.96)`
- **Visible to All:** ✅  
- **Drop Timer:** Every 20 seconds (example)  
- **Expire After:** 60 seconds

### 💲 Items Sold

| Item          | Type     | Price | Max |
| ------------- | -------- | ----- | --- |
| Repair Kit    | `item`   | 500   | 50  |
| Pistol Ammo   | `item`   | 50    | 50  |
| Pistol Weapon | `weapon` | 1500  | 2   |

---

## 🧠 Installation

1. Copy the folder into your server's `resources/` directory.
2. Add the following to your `server.cfg`:
   ```
   ensure gangshipment
   ```
3. Configure settings in `config.lua` to match your framework/inventory setup.
4. Restart your server and test!

---

## 🧪 Future Expansion Ideas

- Dynamic zone claiming
- Gang rankings and rep system
- Mobile delivery notifications (QSPhone integration)
- Police tracking or alerts on active shipment zones

---

## 📸 Screenshots

> *(Add images here if desired)*  
> NPCs guarding zones, shipment drop alerts, or store UI

---

## 📣 Feedback & Contributions

Found a bug? Have a feature request? Open an [issue](https://github.com/turrext) or submit a pull request.

---

## 📜 License

MIT License — free to use, modify, and distribute with credit.

---

## 🙌 Credits

Crafted with 💻 for serious RP servers. Developed by turrext.

🙌 Credits

Crafted with 💻 for serious RP servers. Developed by [YourNameHere].

