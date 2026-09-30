# Micro Traité

Micro virtuel **léger** pour Linux/PipeWire : une chaîne de traitement voix
complète (réduction de bruit, égaliseur, compresseur, limiteur) exposée comme
une simple source audio, utilisable dans **n'importe quelle application**
(vokoscreenNG, Shotcut, Firefox, visio, OBS…).

## Pourquoi ?

Les grosses suites de streaming (OBS & co) sont lourdes et peuvent saccader
sur des machines modestes. Micro Traité s'appuie directement sur **PipeWire** :
la même chaîne de traitement, mais sans usine à gaz, avec une interface GTK
minimaliste pour tout régler.

## Chaîne de traitement

```
Micro (webcam / téléphone / autre)
  └─ RNNoise            (suppression de bruit par réseau de neurones)
      └─ Égaliseur       (coupe-bas + 3 bandes : basses / bas-médium / présence)
          └─ Compresseur (seuil, ratio, attaque, relâchement, gain)
              └─ Limiteur (garde-fou anti-saturation)
                  └─ Source virtuelle « Micro Traité »
```

## Prérequis

- Linux avec **PipeWire** (testé sur Linux Mint 22 / PipeWire 1.0.5)
- Debian/Ubuntu pour le script d'installation
- GTK 3 + Python 3 (`python3-gi`, `gir1.2-gtk-3.0`)
- Plugins LADSPA `swh-plugins` et le plugin LADSPA **RNNoise**
  ([noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice))

## Installation

```bash
git clone https://github.com/afrikteck/micro-traite.git
cd micro-traite
sudo ./install.sh
```

Le script installe les dépendances, compile le plugin RNNoise, installe
l'interface et génère une configuration par défaut.

## Utilisation

Lance **« Micro Traité »** depuis le menu Applications, ou :

```bash
micro-traite-gui
```

- Choisis le **micro d'entrée** (détecté automatiquement).
- Ajuste les sections, puis clique **Appliquer**.
- Dans ton logiciel de capture/visio, sélectionne la source **« Micro Traité »**.

L'application écrit `~/.config/pipewire/pipewire.conf.d/micro-prepro.conf`
puis recharge PipeWire (≈ 1 s de coupure audio).

### Réglages par défaut

| Étage | Paramètre | Valeur |
|---|---|---|
| RNNoise | VAD | 50 % |
| RNNoise | Maintien fin de mot | 100 ms |
| EQ | Coupe-bas | 80 Hz |
| EQ | Basses 110 Hz | +3 dB |
| EQ | Bas-médium 350 Hz | -3 dB |
| EQ | Présence 2,5 kHz | +2,5 dB |
| Compresseur | Seuil / Ratio / Attaque / Relâchement / Gain | -18 dB / 3:1 / 8 ms / 150 ms / +2 dB |
| Limiteur | Seuil | -1,5 dB |

## Ligne de commande

```bash
micro-traite-gui --write-conf   # régénère la conf depuis l'état sauvegardé
micro-traite-gui --help
```

## Désinstallation

```bash
sudo ./uninstall.sh
```

## Détails techniques

- Le PipeWire d'Ubuntu n'est pas compilé avec le support **LV2**, donc
  l'égaliseur utilise les biquads `builtin` de PipeWire et le compresseur /
  limiteur des greffons **LADSPA** (`swh-plugins`).
- La conf est un `filter-chain` PipeWire, rechargé par `systemctl --user
  restart pipewire.service`.

## Astuce anti-saccade (webcam USB)

Si l'image de la webcam est capturée en même temps que son micro, elle peut
saturer le bus USB. Dans ce cas, choisis un autre micro, ou règle la webcam en
**MJPEG** plutôt qu'en format non compressé.

## Licence

MIT — voir [LICENSE](LICENSE).

## Crédits

- [RNNoise](https://github.com/xiph/rnnoise) (Xiph.Org)
- [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice)
- [swh-plugins](http://plugin.org.uk/) (Steve Harris)
- [PipeWire](https://pipewire.org/)
