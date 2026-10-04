@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "PYTHON_EXE=%CD%\.venv\Scripts\python.exe"
if not exist "%PYTHON_EXE%" set "PYTHON_EXE=python"

"%PYTHON_EXE%" -c "import fastapi, uvicorn, jinja2, multipart" >nul 2>&1
if errorlevel 1 (
    echo Required packages are not installed.
    echo Run: .venv\Scripts\python -m pip install -r requirements.txt
    pause
    exit /b 1
)

if not exist "outputs" mkdir "outputs"

set "PID_FILE=%CD%\outputs\dashboard.pid"
set "PORT_FILE=%CD%\outputs\dashboard.port"
set "OUT_LOG=%CD%\outputs\dashboard.out.log"
set "ERR_LOG=%CD%\outputs\dashboard.err.log"

rem Reuse the server recorded by the previous successful launch.
if exist "%PID_FILE%" (
    set "DASHBOARD_PID="
    for /f "usebackq delims=" %%P in ("%PID_FILE%") do set "DASHBOARD_PID=%%P"
    if defined DASHBOARD_PID (
        tasklist /fi "PID eq !DASHBOARD_PID!" 2>nul | find "!DASHBOARD_PID!" >nul
        if not errorlevel 1 (
            set "DASHBOARD_PORT=8000"
            if exist "%PORT_FILE%" for /f "usebackq delims=" %%R in ("%PORT_FILE%") do set "DASHBOARD_PORT=%%R"
            echo Dashboard is already running with PID !DASHBOARD_PID!.
            echo URL: http://127.0.0.1:!DASHBOARD_PORT!
            if not defined NO_BROWSER start "" "http://127.0.0.1:!DASHBOARD_PORT!"
            exit /b 0
        )
    )
    del /q "%PID_FILE%" >nul 2>&1
    del /q "%PORT_FILE%" >nul 2>&1
)

rem Select the first free port so an unrelated process cannot cause Errno 10048.
set "DASHBOARD_PORT="
for /f "delims=" %%R in ('powershell.exe -NoProfile -Command "foreach($port in 8000..8010){$listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port); try{$listener.Start(); $listener.Stop(); Write-Output $port; break}catch{}}"') do set "DASHBOARD_PORT=%%R"

if not defined DASHBOARD_PORT (
    echo No free dashboard port was found between 8000 and 8010.
    pause
    exit /b 1
)

if not "%DASHBOARD_PORT%"=="8000" (
    echo Port 8000 is already in use. Using port %DASHBOARD_PORT% instead.
)

echo Starting Health Insurance Claims dashboard...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$process = Start-Process -WindowStyle Hidden -FilePath $env:PYTHON_EXE -ArgumentList @('-m','uvicorn','web.main:app','--host','127.0.0.1','--port',$env:DASHBOARD_PORT) -WorkingDirectory $PWD -RedirectStandardOutput $env:OUT_LOG -RedirectStandardError $env:ERR_LOG -PassThru; Set-Content -LiteralPath $env:PID_FILE -Value $process.Id; Set-Content -LiteralPath $env:PORT_FILE -Value $env:DASHBOARD_PORT"

if errorlevel 1 (
    echo Failed to start the dashboard. Check outputs\dashboard.err.log.
    pause
    exit /b 1
)

timeout /t 3 /nobreak >nul
set "DASHBOARD_PID="
for /f "usebackq delims=" %%P in ("%PID_FILE%") do set "DASHBOARD_PID=%%P"
tasklist /fi "PID eq !DASHBOARD_PID!" 2>nul | find "!DASHBOARD_PID!" >nul
if errorlevel 1 (
    echo Dashboard stopped during startup. Check outputs\dashboard.err.log.
    del /q "%PID_FILE%" >nul 2>&1
    del /q "%PORT_FILE%" >nul 2>&1
    pause
    exit /b 1
)

echo Dashboard started with PID !DASHBOARD_PID!.
echo URL: http://127.0.0.1:%DASHBOARD_PORT%
echo Logs: outputs\dashboard.out.log and outputs\dashboard.err.log
if not defined NO_BROWSER start "" "http://127.0.0.1:%DASHBOARD_PORT%"
exit /b 0
