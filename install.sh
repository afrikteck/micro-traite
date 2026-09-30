#!/usr/bin/env bash
# Micro Traité - installation (Debian/Ubuntu)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/usr/local}"
LADSPA_DIR="${LADSPA_DIR:-/usr/lib/ladspa}"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mErreur:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Lance ce script avec sudo."
command -v apt-get >/dev/null || die "Ce script cible Debian/Ubuntu."

log "Installation des dépendances (git, cmake, GTK, plugins LADSPA)"
apt-get update -qq
apt-get install -y --no-install-recommends \
    git cmake make gcc g++ python3-gi gir1.2-gtk-3.0 swh-plugins ladspa-sdk

log "Compilation du plugin RNNoise (noise-suppression-for-voice)"
build_dir="$(mktemp -d)"
git clone --depth 1 --recurse-submodules --shallow-submodules \
    https://github.com/werman/noise-suppression-for-voice.git "$build_dir/nsfv"
cmake -S "$build_dir/nsfv" -B "$build_dir/nsfv/build" -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTS=OFF -DBUILD_VST_PLUGIN=OFF -DBUILD_VST3_PLUGIN=OFF \
    -DBUILD_LV2_PLUGIN=OFF -DBUILD_LADSPA_PLUGIN=ON \
    -DBUILD_AU_PLUGIN=OFF -DBUILD_AUV3_PLUGIN=OFF >/dev/null
cmake --build "$build_dir/nsfv/build" -j"$(nproc)" >/dev/null
install -Dm755 "$build_dir/nsfv/build/bin/ladspa/librnnoise_ladspa.so" \
    "$LADSPA_DIR/librnnoise_ladspa.so"
rm -rf "$build_dir"

log "Installation de l'interface dans $PREFIX/bin"
install -Dm755 "$REPO_DIR/bin/micro-traite-gui" "$PREFIX/bin/micro-traite-gui"

log "Création du raccourci applicatif pour $TARGET_USER"
app_dir="$TARGET_HOME/.local/share/applications"
install -d -o "$TARGET_USER" -g "$TARGET_USER" "$app_dir"
cat > "$app_dir/micro-traite.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Micro Traité
Comment=Piloter la chaîne audio du micro virtuel
Exec=micro-traite-gui
Icon=audio-input-microphone
Terminal=false
Categories=AudioVideo;Audio;
EOF
chown "$TARGET_USER":"$TARGET_USER" "$app_dir/micro-traite.desktop"

log "Génération de la configuration par défaut"
runuser -u "$TARGET_USER" -- env "XDG_RUNTIME_DIR=/run/user/$(id -u "$TARGET_USER")" \
    "$PREFIX/bin/micro-traite-gui" --write-conf || true

log "Rechargement de PipeWire"
runuser -u "$TARGET_USER" -- env "XDG_RUNTIME_DIR=/run/user/$(id -u "$TARGET_USER")" \
    systemctl --user restart pipewire.service || true

log "Terminé. Lance « Micro Traité » depuis le menu, ou la commande micro-traite-gui."
