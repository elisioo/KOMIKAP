@echo off
echo ========================================
echo KOMIKAP Web App Starter
echo ========================================
echo.
echo This script will start the proxy server and web app
echo.
echo Step 1: Starting Proxy Server...
echo.

REM Start proxy server in a new window
start "KOMIKAP Proxy Server" cmd /k "dart run server/proxy_server.dart"

REM Wait for proxy to start
timeout /t 3 /nobreak

echo.
echo Step 2: Starting Flutter Web App...
echo.

REM Start flutter web app
flutter run -d chrome

echo.
echo Done!
pause
