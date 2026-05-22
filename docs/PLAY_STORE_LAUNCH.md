# VFD Hub — Google Play Store Launch Guide

## Current readiness: ~88% app / ~75% store listing (signing + assets still required)

Code-side Play prep is in place (auth gate, privacy policy screen, release signing template). You still need a Google Play Console account, store assets, and an upload keystore.

---

## 1. Create upload keystore (one-time)

```powershell
cd d:\Spray_VFD\vfd_param_app\android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `key.properties.example` to `key.properties` and fill passwords:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=../upload-keystore.jks
```

**Backup `upload-keystore.jks` safely.** Losing it blocks future updates.

---

## 2. Build release AAB (required by Play)

```powershell
cd d:\Spray_VFD\vfd_param_app
flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build\app\outputs\bundle\release\app-release.aab`

Optional APK for testing:

```powershell
flutter build apk --release
```

---

## 3. Google Play Console checklist

| Item | Status |
|------|--------|
| Developer account ($25 one-time) | You |
| App name: **VFD Hub** | Ready |
| Package: `com.vfdapp.vfd_param_app` | Ready |
| Privacy policy URL | Host `docs/PRIVACY_POLICY.md` on a public page OR use GitHub Pages; link must match in-app policy |
| App category | Tools / Business |
| Content rating questionnaire | Complete in Console |
| Data safety form | Declare: local account, camera, microphone, files — no server collection |
| Screenshots (phone) | Min 2, recommend 6–8 |
| Feature graphic 1024×500 | Required |
| High-res icon 512×512 | Use `assets/images/icon.png` scaled |
| Short + full description | Write in Console |
| Contact email | Required |

---

## 4. Data safety (honest answers)

- **Account data**: Email/name stored **on device only** (optional signup).
- **Photos/files**: User-uploaded manuals/drawings, local only.
- **Camera**: QR scanning only when user opens scanner.
- **Microphone**: Voice commands only when user taps mic.
- **No data sold**, no ad SDK in current `pubspec.yaml`.

---

## 5. Permissions declared

- `INTERNET` — online manuals / URLs  
- `CAMERA` — QR scanner  
- `RECORD_AUDIO` — voice commands  

---

## 6. Pre-submit testing

- [ ] Fresh install → Welcome → Guest / Sign up / Sign in  
- [ ] Full VFD path: vendor → model → kW → voltage → parameters  
- [ ] QR scan on real device  
- [ ] Sign out returns to Welcome  
- [ ] Release build on Android 10+ device  
- [ ] Privacy Policy opens from Welcome and About  

---

## 7. Version for each upload

Edit `pubspec.yaml`:

```yaml
version: 1.1.0+3   # 1.1.0 = versionName, 3 = versionCode (must increase every upload)
```

---

## 8. After first approval

- Use **internal testing** track first (up to 100 testers).
- Then **closed** → **open** → **production**.
- Enable Play App Signing (recommended) when prompted.

---

## Remaining product gaps (not blocking first upload)

- `database_helper.dart` / `home_screen.dart` refactor (maintainability)
- Cloud backup / multi-device accounts
- Home widget recent configs (stub returns empty)
- Full E2E test on physical devices

---

## Support contact

Use the same email on the Play listing that you monitor for user privacy or support requests.
