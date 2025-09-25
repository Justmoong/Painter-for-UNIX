# Vincent macOS App Store Packaging Guide

This document captures the end-to-end steps needed to turn the `Vincent` build tree into an App Store–compliant package. It assumes you are working on macOS with an active Apple Developer account and that the Qt/KF dependencies referenced in the repository README are already installed.

## 1. Prerequisites
- Apple Developer Program membership with access to App Store Connect.
- Certificates downloaded in Keychain Access:
  - **Apple Distribution** (or legacy *3rd Party Mac Developer Application*).
  - **Apple Installer** (or legacy *3rd Party Mac Developer Installer*).
- A macOS App Store provisioning profile that matches your bundle identifier.
- Xcode command-line tools (`xcode-select --install`) and Transporter from the Mac App Store.
- Qt toolchain available in your `PATH` so that `macdeployqt` is callable.

## 2. Configure the Release Build
```bash
cmake -S . -B build-release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DVINCENT_BUNDLE_IDENTIFIER=com.yourcompany.vincent
cmake --build build-release --target Vincent
```
The cache variable `VINCENT_BUNDLE_IDENTIFIER` (declared in the root `CMakeLists.txt`) feeds the bundle ID into the generated `Info.plist`. Adjust the deployment target if you need to support newer or older macOS releases.

## 3. Stage the App Bundle
The built app lives under `build-release/Vincent.app`. Copy it to a staging directory (for example, `dist/Vincent.app`) so you can safely run deployment tools without touching your build tree.

## 4. Embed Qt and KDE Frameworks
Run `macdeployqt` in App Store mode to embed the required Qt frameworks and QML plugins:
```bash
macdeployqt dist/Vincent.app \
  -appstore-compliant \
  -qmldir=App/qml \
  -always-overwrite
```
Verify that all `.framework` bundles now sit inside `dist/Vincent.app/Contents/Frameworks` and that `qt.conf` exists in `Contents/Resources/`.

## 5. Prepare Metadata
Update the generated `Info.plist` (inside `dist/Vincent.app/Contents/`) with:
- `CFBundleIdentifier` matching your bundle ID.
- `CFBundleVersion` and `CFBundleShortVersionString` set to a semantic version number you are shipping.
- Any usage description strings your app requires (e.g., `NSMicrophoneUsageDescription`)—Vincent currently relies only on file picker access.

## 6. Sandbox Entitlements
Customize `packaging/macos/Vincent.entitlements` if the app needs additional capabilities. The default template enables the App Sandbox and grants read/write access to user-selected files and picture libraries. Keep entitlements minimal to improve App Review approval chances.

## 7. Codesign the Bundle
```bash
codesign --force --options runtime \
  --entitlements packaging/macos/Vincent.entitlements \
  --sign "Apple Distribution: Your Company" \
  dist/Vincent.app
```
Then validate the signature:
```bash
codesign --verify --deep --strict dist/Vincent.app
spctl --assess --type execute dist/Vincent.app
```
If `spctl` warns about missing the hardened runtime, make sure `--options runtime` was passed.

## 8. Create the Installer Package
```bash
productbuild \
  --component dist/Vincent.app /Applications \
  --sign "Apple Installer: Your Company" \
  dist/Vincent.pkg
```
This produces the installer payload required by App Store Connect. Keep the `.pkg` under 4 GB.

## 9. Upload to App Store Connect
1. Open Transporter.
2. Drag `dist/Vincent.pkg` into the queue.
3. Provide your App Store Connect credentials and upload.
4. Resolve any validation issues that Transporter reports (missing icons, entitlement mismatches, etc.).

## 10. Post-Upload Checklist
- Create an App Store Connect record with screenshots, localized descriptions, and pricing.
- Attach the uploaded build to a new version submission and complete the export compliance questionnaire.
- Submit for review.

## Troubleshooting Tips
- Use `otool -L dist/Vincent.app/Contents/MacOS/Vincent` to ensure no absolute paths to your build tree remain.
- Leverage `plutil -p` to inspect `Info.plist` after `macdeployqt` runs.
- If Transporter rejects the upload due to missing `LC_VERSION_MIN_MACOSX`, make sure `CMAKE_OSX_DEPLOYMENT_TARGET` is set at configure time.
- Should you require notarization for outside-the-store distribution, rerun codesigning with the same entitlements and submit via `xcrun notarytool`; App Store submissions do not need separate notarization.
