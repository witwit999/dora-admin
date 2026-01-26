# dora_admin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Desktop (Windows + macOS)

This admin panel supports **Windows** and **macOS** desktop builds. For desktop image upload, the app uses a native file dialog (`file_picker`) so admins can select images from the computer and upload them via the existing `dio` multipart APIs.

### Windows build

- **Prereqs**
  - Flutter SDK (`flutter doctor` should be clean)
  - Visual Studio 2022 with **Desktop development with C++** + Windows SDK
- **Build**
  - `flutter clean`
  - `flutter pub get`
  - `flutter build windows --release`
- **Output**
  - `build/windows/x64/runner/Release/`
- **Packaging**
  - For internal use: zip the Release folder
  - For distribution: create an installer (MSIX / Inno Setup / NSIS)

### macOS build (outside Mac App Store)

- **Prereqs**
  - Xcode + Command Line Tools (`xcode-select --install`)
  - CocoaPods if any plugin requires it
- **Build**
  - `flutter clean`
  - `flutter pub get`
  - `flutter build macos --release`
- **Signing + notarization (recommended)**
  - Sign the `.app` with a **Developer ID Application** certificate
  - Notarize via `xcrun notarytool`
  - Staple the ticket to the app
- **Packaging**
  - Distribute as a notarized `.app` inside a DMG
