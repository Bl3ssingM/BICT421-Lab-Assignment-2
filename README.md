# BICT421-Lab-Assignment-2

Complete instructions to set up, run, build, and test this Flutter project.

## Prerequisites

- Install Flutter (stable channel). Check: `flutter --version`.
- Install an editor: Android Studio, Visual Studio Code, or IntelliJ.
- For Android builds: Android SDK and a device/emulator.
- For iOS builds: macOS + Xcode (required to build/run on iOS).
- For web: Chrome or another supported browser.

If you are unsure, run:

```bash
flutter doctor
```

## Quick setup

1. Open a terminal and change to the project root:

```bash
cd path/to/BICT421-Lab-Assignment-2
```

2. Fetch Dart/Flutter packages:

```bash
flutter pub get
```

3. (Optional) Verify static analysis:

```bash
flutter analyze
```

## Running the app

General: list devices, then run on a chosen device.

```bash
flutter devices
flutter run -d <device-id>
```

Common targets:

- Android emulator or device:

	```bash
	flutter run
	# or specify device id
	flutter run -d emulator-5554
	```

- Chrome (web):

	```bash
	flutter run -d chrome
	```

- Windows desktop (on Windows host):

	```bash
	flutter run -d windows
	```

- iOS (macOS host with Xcode):

	```bash
	flutter run -d <ios-device-id-or-simulator>
	```

Notes:

- Use `flutter emulators --launch <emulatorId>` to start an Android emulator.
- If you get build errors, run `flutter clean` then `flutter pub get`.

## Building release artifacts

- Android APK (debug/release):

	```bash
	flutter build apk --release
	# or debug
	flutter build apk --debug
	```

- Android App Bundle (for Play Store):

	```bash
	flutter build appbundle --release
	```

- iOS (macOS only):

	```bash
	flutter build ios --release
	```

- Web:

	```bash
	flutter build web --release
	```

- Windows:

	```bash
	flutter build windows --release
	```

## Tests

- Unit & widget tests:

	```bash
	flutter test
	```

- Integration tests (if present):

	```bash
	flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
	```

## Linting & formatting

- Analyze for issues:

	```bash
	flutter analyze
	```

- Format Dart files:

	```bash
	dart format .
	```

## Assets

This project includes an `assets/` folder. If you add new assets:

1. Place files under `assets/...`.
2. Ensure `pubspec.yaml` references them under `flutter/assets`.
3. Run `flutter pub get`.

## Common troubleshooting

- If Flutter reports missing SDKs or tools, run `flutter doctor` and follow instructions.
- If Android builds fail due to SDK location, ensure `local.properties` in the project root points to your SDK, e.g.:

	```text
	sdk.dir=C:\Users\<you>\AppData\Local\Android\sdk
	```

- If Gradle cache or build artifacts cause errors:

	```bash
	flutter clean
	flutter pub get
	```

- For dependency resolution problems, try:

	```bash
	flutter pub cache repair
	```

## Useful commands summary

```bash
flutter pub get          # install deps
flutter devices          # list connected devices/emulators
flutter run              # run on default device
flutter run -d chrome    # run on web
flutter build apk        # build android apk
flutter build appbundle  # build aab for Play Store
flutter test             # run tests
flutter analyze          # static analysis
```

## Notes & next steps

- This README gives platform-appropriate run/build/test instructions. If you want, I can:
	- Add CI instructions (GitHub Actions) for building and testing.
	- Tailor steps for a particular OS (Windows / macOS / Linux) with screenshots or emulator setup.

If anything fails for you locally, paste the `flutter run` or `flutter build` error and I will help troubleshoot.
