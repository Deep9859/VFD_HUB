@echo off
chcp 65001 >nul
set "OUT=%~dp0docs\store-assets\screenshots"
if not exist "%OUT%" mkdir "%OUT%"

for /f "delims=" %%D in ('adb devices ^| findstr /r "emulator-[0-9]*\s*device"') do (
  set "SERIAL=%%D"
  goto :found
)
echo No emulator/device found. Start emulator first.
exit /b 1

:found
for /f "tokens=1" %%S in ("%SERIAL%") do set "ADB_SERIAL=%%S"
set "TS=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TS=%TS: =0%"
set "FILE=%OUT%\screenshot_%TS%.png"
echo Capturing to %FILE% ...
adb -s %ADB_SERIAL% exec-out screencap -p > "%FILE%"
if errorlevel 1 (
  echo Capture failed.
  exit /b 1
)
echo Done. Upload PNGs from docs\store-assets\screenshots\
exit /b 0
