# Omni Prism

A free, cross-platform, open-source image viewer
Download: https://github.com/nexina/omni-prism/releases

## Getting Started

[ WORK IN PROGRESS] - If you are visiting this, thanks <3 I am still woring on it. 

[ CONTRIBUTORS ] You can try the source code in your own way. Read the LICENSE what you can do with this.


## Building & Packaging

### Windows (Microsoft Store / MSIX)
```bash
flutter build windows --release
dart run msix:create
```
The package is written to `build/windows/x64/runner/Release/omni_prism.msix`.
`identity_name` and `publisher` in `msix_config` (pubspec.yaml) must match
**Partner Center → Product management → Product identity**. Bump
`msix_version` for every Store submission.

### Linux (Snap Store)

Snap name: `omni-prism` · App ID: `nexina.omni.prism`

```bash
# First-time setup
sudo snap install snapcraft --classic
sudo snap install lxd && sudo lxd init --auto
sudo usermod -aG lxd $USER && newgrp lxd

# Build
snapcraft pack --use-lxd

# Register (first time only), upload and release
snapcraft register omni-prism
snapcraft upload --release=stable omni-prism_1.0.1_amd64.snap
```
No custom D-Bus slot is used, so no manual review is needed. `removable-media`
is not auto-connected: users run `snap connect omni-prism:removable-media` to
browse USB drives (or request auto-connect on the Snapcraft forum).

To release an update, bump `version` in `snapcraft.yaml`, `version` in
`pubspec.yaml`, `appVersion` in `lib/core/config/constants.dart`,
`msix_version` in `msix_config`, and add a `<release>` entry to
`linux/nexina.omni.prism.metainfo.xml`.

## License

[MIT](LICENSE) © 2026 NEXINA
