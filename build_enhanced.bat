@echo off
chcp 65001 >nul
color 0A
title VFD Hub - APK Builder

echo ╔════════════════════════════════════════════════════════════╗
echo ║           VFD Hub - Enhanced APK Builder                   ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Keep build + pub cache on the same drive to avoid Kotlin/Gradle path issues on Windows.
set "PROJECT_DIR=%~dp0"
set "PUB_CACHE=%PROJECT_DIR%.pub-cache"
set "GRADLE_USER_HOME=%PROJECT_DIR%.gradle"
if not exist "%PUB_CACHE%" mkdir "%PUB_CACHE%"
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

echo [1/4] Cleaning old APK files...
if exist build\app\outputs\flutter-apk\*.apk (
    del /Q build\app\outputs\flutter-apk\*.apk
    echo ✓ Old APK files deleted
) else (
    echo ✓ No old APK files found
)
echo.

echo [2/4] Cleaning Flutter build cache...
flutter clean
echo ✓ Build cache cleaned
echo.

echo [3/4] Getting dependencies...
flutter pub get
echo ✓ Dependencies updated
echo.

echo [4/4] Building release APK files...
flutter build apk --split-per-abi --release
echo.

if exist build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                  BUILD SUCCESSFUL! ✓                       ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo APK Location: build\app\outputs\flutter-apk\
    echo.
    echo Generated Files:
    dir /B build\app\outputs\flutter-apk\*.apk
    echo.
    echo Opening APK folder...
    start "" "build\app\outputs\flutter-apk\"
) else (
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║                  BUILD FAILED! ✗                           ║
    echo ╚════════════════════════════════════════════════════════════╝
)

echo.
pause
