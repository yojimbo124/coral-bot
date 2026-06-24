#!/usr/bin/env bash
# Pi 5 Kiosk Setup — Kitchen Wall Display
#
# Run once on a fresh Raspberry Pi OS Lite 64-bit install.
# Points Chromium at your Home Assistant kitchen dashboard in kiosk mode.
#
# Usage:
#   sudo bash kiosk.sh
#
# Prerequisites:
#   - Pi OS Lite 64-bit (bookworm) flashed and booted
#   - Network configured (Wi-Fi or Ethernet / PoE)
#   - SSH enabled (via raspi-config or imager)

set -euo pipefail

HA_URL="${HA_URL:-http://homeassistant.local:8123}"
DASHBOARD_PATH="${DASHBOARD_PATH:-/kitchen/home}"
KIOSK_USER="${KIOSK_USER:-kiosk}"

echo "=== Installing packages ==="
apt-get update -qq
apt-get install -y --no-install-recommends \
  chromium-browser \
  xorg \
  openbox \
  unclutter \
  xdotool

echo "=== Creating kiosk user ==="
id "$KIOSK_USER" &>/dev/null || useradd -m -s /bin/bash "$KIOSK_USER"

echo "=== Writing Openbox autostart ==="
mkdir -p "/home/$KIOSK_USER/.config/openbox"
cat > "/home/$KIOSK_USER/.config/openbox/autostart" <<EOF
# Disable screensaver and power management
xset s off
xset -dpms
xset s noblank

# Hide cursor when idle
unclutter -idle 3 &

# Launch Chromium in kiosk mode pointing at HA dashboard
chromium-browser \\
  --kiosk \\
  --noerrdialogs \\
  --disable-infobars \\
  --disable-session-crashed-bubble \\
  --disable-restore-session-state \\
  --no-first-run \\
  --touch-events=enabled \\
  --enable-features=OverlayScrollbar \\
  --app="${HA_URL}${DASHBOARD_PATH}?kiosk" &
EOF
chown -R "$KIOSK_USER:$KIOSK_USER" "/home/$KIOSK_USER/.config"

echo "=== Configuring auto-login to X session ==="
# systemd autologin for the kiosk user
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $KIOSK_USER --noclear %I \$TERM
EOF

echo "=== Writing .bash_profile to start X on login ==="
cat > "/home/$KIOSK_USER/.bash_profile" <<'EOF'
[[ -z "$DISPLAY" && "$XDG_VTNR" -eq 1 ]] && exec startx /usr/bin/openbox-session
EOF
chown "$KIOSK_USER:$KIOSK_USER" "/home/$KIOSK_USER/.bash_profile"

echo "=== Writing /boot/firmware/config.txt additions ==="
BOOT_CONFIG="/boot/firmware/config.txt"
if ! grep -q "hdmi_force_hotplug=1" "$BOOT_CONFIG"; then
  cat >> "$BOOT_CONFIG" <<EOF

# Kitchen Display — Waveshare 13.3" 1920x1080
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
gpu_mem=128
EOF
fi

echo ""
echo "=== Done ==="
echo "Reboot to start kiosk mode:"
echo "  sudo reboot"
echo ""
echo "Dashboard URL: ${HA_URL}${DASHBOARD_PATH}?kiosk"
echo ""
echo "To adjust HA URL or dashboard path, re-run with env vars:"
echo "  HA_URL=http://192.168.1.x:8123 DASHBOARD_PATH=/kitchen/home sudo -E bash kiosk.sh"
