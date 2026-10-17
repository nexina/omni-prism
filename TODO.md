# TODO

## Before publishing

- [x] Export a high-res app icon (≥512×512) and replace the upscaled placeholders:
  - [x] `assets/icons/icon_1024.png` (MSIX `logo_path`), `assets/icons/omni_prism_ic.png` (in-app)
  - [x] `linux/nexina.omni.prism.png` (512)
  - [x] `snap/gui/nexina.omni.prism.png` (512)
  - [x] `windows/runner/resources/app_icon.ico`
- [ ] Confirm `msix_config.publisher` and `identity_name` in `pubspec.yaml` match
      Partner Center → Product management → Product identity
- [ ] Reserve the app name "Omni Prism" in Partner Center
- [ ] Register the snap name: `snapcraft register omni-prism`
- [ ] Build and test the snap locally: `snapcraft pack --use-lxd`
- [ ] Build and test the MSIX on Windows: `flutter build windows --release && dart run msix:create`
- [ ] Add screenshots to `linux/nexina.omni.prism.metainfo.xml` and the store listings
- [ ] Make the `nexina/omni-prism` GitHub repo public (homepage/issues URLs point to it)

## Optional

- [ ] Request `removable-media` auto-connect on the Snapcraft forum
- [ ] Flathub manifest (`flatpak/`), like Omni Preview
- [ ] Android: change `applicationId`/`namespace` from `com.example.omni_prism`
      and prepare a Play Store release
- [ ] Add more file associations (TIFF, HEIC, RAW…) once the viewer can decode them

## On every release

- [ ] Bump `version` in `pubspec.yaml` and `snapcraft.yaml`
- [ ] Bump `appVersion` in `lib/core/config/constants.dart`
- [ ] Bump `msix_version` in `msix_config`
- [ ] Add a `<release>` entry to `linux/nexina.omni.prism.metainfo.xml`
