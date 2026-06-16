# VFD Hub — Google Play Store Launch Guide

## Current readiness

| Area | Status |
|------|--------|
| Release AAB signed | **Done** — `build/app/outputs/bundle/release/app-release.aab` |
| Upload keystore | **Done** — `android/upload-keystore.jks` (backup required) |
| Store icon + feature graphic | **Done** — `docs/store-assets/` |
| Privacy policy HTML | **Done** — `docs/privacy-policy.html` (host on HTTPS) |
| Phone screenshots | **You** — min 2 (`capture_screenshots.bat`) |
| Play Console account | **You** — $25 one-time fee |
| Contact email on listing | **You** — required field |

---

## 1. Keystore (already created)

Backup these files off this PC:

- `android/upload-keystore.jks`
- `android/KEYSTORE_BACKUP.txt` (passwords)

Losing the keystore blocks future app updates.

---

## 2. Build release AAB

```bat
build_play_store.bat
```

Output: `build\app\outputs\bundle\release\app-release.aab` (~65 MB)

Signing: release upload key (`CN=VFD Hub`). Enable **Google Play App Signing** in Console on first upload.

---

## 3. Google Play Console checklist

| Item | Status |
|------|--------|
| Developer account ($25 one-time) | You |
| App name: **VFD Hub** | Ready |
| Package: `com.vfdapp.vfd_param_app` | Ready |
| Privacy policy URL | Host `docs/privacy-policy.html` |
| App category | Tools / Business |
| Content rating questionnaire | Complete in Console |
| Data safety form | See `docs/PLAY_STORE_UPLOAD.md` |
| Screenshots (phone) | Min 2 — `capture_screenshots.bat` |
| Feature graphic 1024×500 | `docs/store-assets/feature-graphic-1024x500.png` |
| High-res icon 512×512 | `docs/store-assets/play-store-icon-512.png` |
| Short + full description | `docs/STORE_LISTING.md` |
| Contact email | Required — add yours |

Full upload steps: **`docs/PLAY_STORE_UPLOAD.md`**

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

- [x] Unit tests (209)
- [x] Emulator integration smoke test
- [ ] QR scan on **real device** (recommended)
- [ ] Release install from AAB on Android 10+ device (optional: internal testing track)

---

## 7. Version for each upload

Edit `pubspec.yaml`:

```yaml
version: 1.1.0+4   # 1.1.0 = versionName, 4 = versionCode (increase +N every upload)
```

---

## 8. Recommended launch order

1. **Internal testing** — upload AAB, add your Gmail as tester  
2. Install from Play link, verify guest login + tools  
3. **Production** (or closed testing) after you are satisfied  

Review time: usually 1–3 days.

---

## Support contact

Use the same email on the Play listing that you monitor for user privacy or support requests.
