@echo off
chcp 65001 >nul
title VFD Hub - Emulator Test

set "PROJECT_DIR=%~dp0"
set "PUB_CACHE=%PROJECT_DIR%.pub-cache"
set "GRADLE_USER_HOME=%PROJECT_DIR%.gradle"
if not exist "%PUB_CACHE%" mkdir "%PUB_CACHE%"
if not exist "%GRADLE_USER_HOME%" mkdir "%GRADLE_USER_HOME%"

echo [1/3] Checking emulator...
flutter devices | findstr /i "emulator" >nul
if errorlevel 1 (
  echo Starting Pixel7 emulator...
  flutter emulators --launch Pixel7
  timeout /t 15 /nobreak >nul
)

for /f %%d in ('powershell -NoProfile -Command "$o = flutter devices 2>$null | Out-String; if ($o -match ''(emulator-\d+)'') { $matches[1] }"') do set "DEVICE=%%d"
if "%DEVICE%"=="" (
  echo No Android emulator found.
  exit /b 1
)
echo Using device: %DEVICE%

echo [2/3] Unit tests...
flutter test --concurrency=4
if errorlevel 1 exit /b 1

echo [3/3] Integration tests on emulator...
flutter test integration_test -d %DEVICE%
exit /b %ERRORLEVEL%
