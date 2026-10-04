@echo off
setlocal
cd /d "%~dp0"

set "PID_FILE=%CD%\outputs\dashboard.pid"
set "PORT_FILE=%CD%\outputs\dashboard.port"

if not exist "%PID_FILE%" (
    echo Dashboard is not running, or its PID file is missing.
    echo If it was started manually, stop that terminal with Ctrl+C.
    exit /b 0
)

set "DASHBOARD_PID="
for /f "usebackq delims=" %%P in ("%PID_FILE%") do set "DASHBOARD_PID=%%P"

if not defined DASHBOARD_PID (
    echo The dashboard PID file is empty.
    del /q "%PID_FILE%" >nul 2>&1
    del /q "%PORT_FILE%" >nul 2>&1
    exit /b 1
)

tasklist /fi "PID eq %DASHBOARD_PID%" 2>nul | find "%DASHBOARD_PID%" >nul
if errorlevel 1 (
    echo Dashboard process %DASHBOARD_PID% is no longer running.
    del /q "%PID_FILE%" >nul 2>&1
    del /q "%PORT_FILE%" >nul 2>&1
    exit /b 0
)

echo Stopping dashboard process %DASHBOARD_PID%...
taskkill /pid %DASHBOARD_PID% /t /f >nul 2>&1
if errorlevel 1 (
    echo Unable to stop dashboard process %DASHBOARD_PID%.
    exit /b 1
)

del /q "%PID_FILE%" >nul 2>&1
del /q "%PORT_FILE%" >nul 2>&1
echo Dashboard stopped.
exit /b 0
