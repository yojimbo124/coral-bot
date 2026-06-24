# coral-bot — Kitchen Wall Display

A locally-hosted kitchen wall display for Home Assistant. No subscription, no cloud dependency. Runs on a Raspberry Pi 5 with PoE and a 13"+ touchscreen.

Similar in spirit to Hearth Display and Skylight Calendar, built entirely on top of Home Assistant Lovelace with a curated set of custom cards.

## Features

- **Family calendar** — weekly view with per-person color coding (aurora-calendar)
- **Meal planning** — today's lunch/dinner from Mealie, tap to open planner
- **Grocery list** — shared `todo.mealie_groceries`, syncs with HA mobile app
- **Presence** — who's home, with entity pictures and color-coded borders
- **Weather** — current condition and temperature in the header
- **Kiosk mode** — hides HA chrome when accessed with `?kiosk` in the URL

## Quick Start

See [`docs/setup.md`](docs/setup.md) for the full setup guide:

1. Install required HACS cards
2. Load `dashboards/kitchen.yaml` into your HA dashboard
3. Access at `http://homeassistant.local:8123/kitchen/home?kiosk`
4. For the wall display, run `infra/pi-setup/kiosk.sh` on the Pi

## Hardware

Raspberry Pi 5 + Official PoE+ HAT + Waveshare 13.3" HDMI capacitive touchscreen + 3D printed enclosure. ~$250 total. See [`docs/setup.md`](docs/setup.md) for the full BOM.

## Repository Layout

```
dashboards/
  kitchen.yaml        # Lovelace dashboard YAML (load into HA)
infra/pi-setup/
  kiosk.sh            # One-shot Pi OS kiosk setup script
docs/
  setup.md            # Full setup guide + hardware BOM
```
