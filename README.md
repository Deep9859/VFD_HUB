# VFD Hub

Flutter app for VFD parameter management — vendor/model selection, protocols, parameters, manuals, fault codes, QR tools, and calculators.

## Requirements

- Flutter SDK 3.5+
- Android Studio or VS Code

## Setup

```bash
flutter pub get
flutter run
```

## Build (Android)

```bash
flutter build apk --release
# or split APKs:
flutter build apk --split-per-abi --release
# Windows helper script:
build_enhanced.bat
```

## App icons

```bash
flutter pub run flutter_launcher_icons
```

Requires `assets/images/icon.png` (1024×1024).

## Project layout (required folders only)

```
vfd_param_app/
├── android/                 # Android build & widget
├── assets/images/           # icon.png, logo.svg
├── lib/
│   ├── core/                # config, security, services, theme, utils
│   ├── data/                # database, datasources, models, services
│   ├── l10n/                # translations (6 languages)
│   ├── presentation/        # auth, providers, screens, widgets
│   └── main.dart
├── test/                    # unit & widget tests
├── tools/                   # Excel import script only
├── docs/                    # Play Store & privacy (reference)
├── pubspec.yaml
├── l10n.yaml
├── analysis_options.yaml
└── build_enhanced.bat       # Windows APK build
```

Not kept in repo: `build/`, `.dart_tool/`, `.gradle/`, `.pub-cache/`, empty `tool/`, IDE `.vscode/`.
iOS folder (`ios/`) is optional — remove if you ship Android only.

## Tests

```bash
# Fast (parallel, no animation settle wait)
flutter test --concurrency=4
# or on Windows:
test_fast.bat
```

```bash
flutter analyze
```

## Excel catalog re-import

When the master Excel file changes, run:

```bash
python tools/import_excel_master.py
```

See [tools/README.md](tools/README.md) for details.

## License

Private and proprietary.
