# VFD Hub — Play Store upload (step-by-step)

**Technical build: ready.** Upload `app-release.aab` from your PC. Console steps below are manual (Google account required).

## Files ready on your PC

| Item | Path |
|------|------|
| **AAB (upload this)** | `build/app/outputs/bundle/release/app-release.aab` |
| Upload keystore | `android/upload-keystore.jks` |
| Keystore passwords | `android/KEYSTORE_BACKUP.txt` |
| Privacy policy (HTML) | `docs/privacy-policy.html` |
| Privacy policy (markdown) | `docs/PRIVACY_POLICY.md` |
| Store copy | `docs/STORE_LISTING.md` |
| Icon 512×512 | `docs/store-assets/play-store-icon-512.png` |
| Feature graphic | `docs/store-assets/feature-graphic-1024x500.png` |
| Screenshots guide | `docs/store-assets/SCREENSHOTS.md` |

Build AAB again anytime:

```bat
build_play_store.bat
```

Uses Gradle cache on `%USERPROFILE%\.gradle-vfd-hub` (avoids Windows D: drive transform errors).

Before each new upload, increase build number in `pubspec.yaml`:

```yaml
version: 1.1.0+5   # +5 must be higher than last upload
```

---

## 1. Google Play Console

1. Open https://play.google.com/console ($25 one-time developer fee if new account).
2. **Create app** → name: **VFD Hub** → default language: English → App / free.

---

## 2. Store listing (Main store listing)

Use text from `docs/STORE_LISTING.md`.

Required graphics (generated unless noted):

- **App icon** 512×512 → `docs/store-assets/play-store-icon-512.png`
- **Feature graphic** 1024×500 → `docs/store-assets/feature-graphic-1024x500.png`
- **Phone screenshots** — min 2 → `capture_screenshots.bat` while emulator is open (see `docs/store-assets/SCREENSHOTS.md`)

**Privacy policy URL** — must be public HTTPS. Options:

1. **GitHub Pages** — enable Pages on repo, use `docs/privacy-policy.html` → URL like `https://YOUR_USER.github.io/vfd_param_app/privacy-policy.html`
2. **Raw GitHub** — less ideal but works: link to hosted HTML on any site you control

Use the **same** policy content as in the app (About → Privacy Policy).

---

## 3. App content (required forms)

| Section | What to declare |
|---------|-----------------|
| Privacy policy | URL from step 2 |
| Ads | No ads |
| Content rating | Complete questionnaire (tools / business app) |
| Target audience | Not for children |
| Data safety | See table below — local only, optional camera/mic/files |

### Data safety form (copy these answers)

| Question | Answer |
|----------|--------|
| Collect or share user data? | Yes — data processed on device |
| Data encrypted in transit | N/A (no server upload) |
| Account creation | Optional email/name — stored locally |
| Data deleted on request | User can uninstall or clear app storage |
| Camera | QR scan when user opens scanner |
| Microphone | Voice commands when user taps mic |
| Files | Manuals/drawings user imports — local only |
| Data sold | No |
| Data shared with third parties | No |
| News apps | No |

---

## 4. Release

1. **Release** → **Production** (or **Internal testing** first — recommended).
2. **Create new release** → upload `app-release.aab`.
3. Enable **Google Play App Signing** when asked (recommended).
4. Release notes example: `Initial Play Store release of VFD Hub.`

---

## 5. After submit

- Review: usually **1–3 days** (up to 7).
- Fix any policy/rejection emails in Console.

---

## Package info

- **Application ID:** `com.vfdapp.vfd_param_app`
- **Version name:** 1.1.0
- **Version code:** 4
