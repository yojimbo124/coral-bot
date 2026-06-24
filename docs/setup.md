# Kitchen Display Setup

## 1. Hardware (one-time purchase)

| Item | Source | ~Cost |
|------|--------|-------|
| Raspberry Pi 5 4GB | raspberrypi.com | $60 |
| Official Pi 5 PoE+ HAT (SC0795) | raspberrypi.com | $20 |
| Waveshare 13.3" HDMI IPS touch (`13.3HP-CAPQLED`) | waveshare.com | $110 |
| Short right-angle HDMI cable | Amazon | $8 |
| USB-A to USB-A (touch data) | Amazon | $5 |
| 64GB microSD A2 (Sandisk Extreme) | Amazon | $12 |
| PETG filament + M3 hardware (enclosure) | — | ~$13 |
| PoE injector 802.3at (if no PoE switch) | Amazon | $15 |

**Enclosure notes**: PETG over PLA (PoE HAT generates heat). The HAT sits ~15mm above the Pi — leave rear cavity clearance. Include a wall-mount cleat and a recess pocket for the Waveshare bezel.

---

## 2. HA Cards to Install (via HACS)

Install all of these before loading the dashboard YAML.

**Lovelace cards** (HACS → Frontend):

| Card | HACS search | Repo |
|------|-------------|------|
| Mushroom | `mushroom` | piitaya/lovelace-mushroom |
| Card Mod | `card-mod` | thomasloven/lovelace-card-mod |
| Kiosk Mode | `kiosk-mode` | maykar0/kiosk-mode |
| Simple Clock Card | `simple-clock-card` | wassy92x/lovelace-simple-clock-card |

**Aurora Calendar — Custom Integration** (HACS → Integrations, NOT Frontend):

1. HACS → Integrations → ⋮ → Custom Repositories
   - URL: `https://github.com/davidlop28/ha-aurora-calendar`
   - Category: **Integration**
2. Download → restart HA
3. Settings → Devices & Services → Add Integration → search **"Aurora Calendar"**
4. In the integration setup wizard, add your HA calendar entities and assign colors:
   - `calendar.family` → blue `#3498db`
   - `calendar.jimmy` → purple `#8e44ad`
   - `calendar.shirin` → green `#27ae60`
   - `calendar.river` → red `#e74c3c`
   - `calendar.meals` → orange `#f39c12`

The Lovelace card (`type: custom:aurora-calendar-card`) then pulls its config from the integration automatically — no entity list needed in the card YAML.

---

## 3. Load the Dashboard

1. In HA go to **Settings → Dashboards → Add Dashboard** (or edit your existing "Kitchen" dashboard)
2. Open the YAML editor (⋮ → Edit in YAML)
3. Paste the contents of `dashboards/kitchen.yaml` from this repo
4. Save

The aurora-calendar card has a built-in visual editor — after loading, click the card pencil icon to adjust fonts, visible hour range, background style, etc.

---

## 4. Kiosk Mode

The dashboard uses the `kiosk-mode` card which hides the HA header and sidebar when the URL includes `?kiosk`.

**Wall display URL:**
```
http://homeassistant.local:8123/kitchen/home?kiosk
```

On the Pi, the kiosk setup script (`infra/pi-setup/kiosk.sh`) launches Chromium to this URL automatically on boot.

---

## 5. Pi Kiosk Setup

Flash **Raspberry Pi OS Lite 64-bit (bookworm)** to the SD card using Raspberry Pi Imager. Enable SSH in the imager settings.

SSH into the Pi and run:

```bash
# Clone this repo
git clone https://github.com/yojimbo124/coral-bot.git
cd coral-bot

# Run setup (defaults to homeassistant.local:8123)
sudo bash infra/pi-setup/kiosk.sh

# Or with a specific IP if mDNS doesn't work on your network:
HA_URL=http://192.168.1.x:8123 sudo -E bash infra/pi-setup/kiosk.sh

sudo reboot
```

After reboot, Chromium launches full-screen to the kitchen dashboard automatically.

**Touch calibration**: The Waveshare 13.3" USB HID touchscreen is detected automatically by libinput. If touch origin is offset, run `xinput list` to find the device and create `/etc/X11/xorg.conf.d/99-calibration.conf`.

---

## 6. HA Entities Used

| Entity | Purpose |
|--------|---------|
| `weather.forecast_home` | Weather chip in header |
| `person.jimmy` | Presence badge (color: #8e44ad) |
| `person.shirin` | Presence badge (color: #27ae60) |
| `person.river` | Presence badge (color: #e74c3c) |
| `calendar.family` | Calendar (blue #3498db) |
| `calendar.jimmy` | Calendar (purple #8e44ad) |
| `calendar.shirin` | Calendar (green #27ae60) |
| `calendar.river` | Calendar (red #e74c3c) |
| `calendar.meals` | Calendar (orange #f39c12) |
| `sensor.mealie_lunch_today` | Today's lunch |
| `sensor.mealie_dinner_today` | Today's dinner |
| `todo.mealie_groceries` | Grocery list |
