#!/usr/bin/env bash
# Micro Traité - désinstallation
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
LADSPA_DIR="${LADSPA_DIR:-/usr/lib/ladspa}"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

[ "$(id -u)" -eq 0 ] || { echo "Lance ce script avec sudo." >&2; exit 1; }

rm -f "$PREFIX/bin/micro-traite-gui"
rm -f "$TARGET_HOME/.local/share/applications/micro-traite.desktop"
rm -f "$TARGET_HOME/Bureau/micro-traite.desktop"
rm -f "$TARGET_HOME/.config/pipewire/pipewire.conf.d/micro-prepro.conf"
rm -f "$TARGET_HOME/.config/micro-traite-gui.json"
rm -f "$LADSPA_DIR/librnnoise_ladspa.so"

runuser -u "$TARGET_USER" -- env "XDG_RUNTIME_DIR=/run/user/$(id -u "$TARGET_USER")" \
    systemctl --user restart pipewire.service || true

echo "Micro Traité désinstallé."
