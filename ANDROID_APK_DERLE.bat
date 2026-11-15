@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>&1
if errorlevel 1 (echo HATA: Flutter PATH uzerinde bulunamadi. & exit /b 1)
call flutter doctor -v
if errorlevel 1 exit /b 1
call flutter pub get
if errorlevel 1 exit /b 1
call flutter analyze
if errorlevel 1 exit /b 1
call flutter test
if errorlevel 1 exit /b 1
call flutter build apk --debug
if errorlevel 1 exit /b 1
echo APK: build\app\outputs\flutter-apk\app-debug.apk
