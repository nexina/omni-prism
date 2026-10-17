# Omni Prism

A free, cross-platform, open-source image viewer
Download: https://github.com/nexina/omni-prism/releases

## Getting Started

[ WORK IN PROGRESS] - If you are visiting this, thanks <3 I am still woring on it. 

[ CONTRIBUTORS ] You can try the source code in your own way. Read the LICENSE what you can do with this.


## Building & Packaging

### Windows (Microsoft Store / MSIX)

Identity name: `RakibulHasan.OmniPrism`

#### 1. Build the release binaries
```bash
flutter build windows --release
```

#### 2. Create the MSIX package
```bash
dart run msix:create
```
The package is written to `build/windows/x64/runner/Release/omni_prism.msix`.
`msix_config` in `pubspec.yaml` generates the Store logos from
`assets/icons/icon_1024.png` and declares the image file associations
(`.jpg .jpeg .png .gif .webp .bmp .ico .svg`).

#### 3. Check the Partner Center identity (first time only)
Reserve the name **Omni Prism** in Partner Center, then make sure
`identity_name` and `publisher` in `msix_config` match
**Partner Center → Product management → Product identity**.
`store: true` leaves signing to the Store, so you don't need a certificate.

#### 4. Submit
Create a new submission in Partner Center, upload `omni_prism.msix` under
**Packages**, fill in the Store listing (description, screenshots) and submit
for certification.

---

### Linux (Snap / Snap Store)

Snap name: `omni-prism` · App ID: `nexina.omni.prism`

#### 1. Build the snap package
```bash
# Requires LXD for a clean build environment
# First-time setup:
sudo snap install snapcraft --classic
sudo snap install lxd
sudo lxd init --auto
sudo usermod -aG lxd $USER
newgrp lxd  # or log out/in

# Build the snap
snapcraft pack --use-lxd
```
The generated `.snap` file will be in the project root (e.g., `omni-prism_1.0.1_amd64.snap`).

#### 2. Test it locally
```bash
sudo snap install --dangerous omni-prism_1.0.1_amd64.snap
snap run omni-prism
```

#### 3. Register the snap name (first time only)
```bash
snapcraft login
snapcraft register omni-prism
```

#### 4. Upload to the Snap Store
Upload to the `edge` channel first for testing:
```bash
snapcraft upload --release=edge omni-prism_1.0.1_amd64.snap
```

#### 5. Promote to stable
After testing the edge build, promote the revision to stable:
```bash
snapcraft release omni-prism <revision> stable
# or via dashboard: https://snapcraft.io/snaps/omni-prism/releases
```

No custom D-Bus slot is used, so no manual review is needed. `removable-media`
is not auto-connected: users run `snap connect omni-prism:removable-media` to
browse USB drives (or request auto-connect on the Snapcraft forum).

**Note:** The snap uses the `flutter` plugin, which runs `flutter pub get` and
`flutter build linux --release` automatically. The `override-build` step
deletes any existing `build/` directory to avoid CMake cache mismatches, then
installs the desktop entry, the 512px icon and the AppStream metainfo from
`linux/`. The Snap Store icon comes from `snap/gui/nexina.omni.prism.png` (the
`icon:` key in `snapcraft.yaml`).

---

### Releasing an update

1. Bump the version everywhere:
   - `version` in `pubspec.yaml` and `snapcraft.yaml`
   - `appVersion` in `lib/core/config/constants.dart`
   - `msix_version` in `msix_config` (Store requires a higher version every submission)
   - add a `<release>` entry to `linux/nexina.omni.prism.metainfo.xml`
2. Snap: `snapcraft pack --use-lxd`, upload to `edge`, promote to `stable` once tested.
3. MSIX: `flutter build windows --release && dart run msix:create`, then a new
   Partner Center submission with the new package.

## License

[MIT](LICENSE) © 2026 NEXINA
