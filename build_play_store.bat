@echo off
chcp 65001 >nul
title VFD Hub - Play Store AAB Builder

set "PROJECT_DIR=%~dp0"
set "PUB_CACHE=%PROJECT_DIR%.pub-cache"
rem Use C: drive Gradle cache to avoid D: transform lock issues on Windows
set "GRADLE_USER_HOME=%USERPROFILE%\.gradle-vfd-hub"
if not exist "%PUB_CACHE%" mkdir "%PUB_CACHE%"
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

if not exist "%PROJECT_DIR%android\key.properties" (
  echo ERROR: android\key.properties missing. See android\key.properties.example
  exit /b 1
)
if not exist "%PROJECT_DIR%android\upload-keystore.jks" (
  echo ERROR: android\upload-keystore.jks missing. See android\KEYSTORE_BACKUP.txt
  exit /b 1
)

echo [1/3] Dependencies...
flutter pub get
if errorlevel 1 exit /b 1

echo [2/3] Building release App Bundle (AAB)...
flutter build appbundle --release
if errorlevel 1 exit /b 1

echo.
echo [3/3] Done!
echo Upload this file to Google Play Console:
echo   %PROJECT_DIR%build\app\outputs\bundle\release\app-release.aab
echo.
echo See docs\PLAY_STORE_UPLOAD.md for Console steps.
exit /b 0
