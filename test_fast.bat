@echo off
chcp 65001 >nul
title VFD Hub - Fast Tests

echo Running tests (parallel, no animation settle)...
flutter test --concurrency=4 %*
