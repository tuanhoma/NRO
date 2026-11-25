@echo off
title Anwin Version 3 Server
cd /d "%~dp0"

echo ===============================
echo     Starting Anwin Version 3 Server
echo ===============================

tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I "mysqld.exe" >NUL
if errorlevel 1 (
    if exist "C:\xampp\mysql\bin\mysqld.exe" (
        echo [MYSQL] Starting XAMPP MySQL...
        start "" /B "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini"
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$i=0; while($i -lt 15 -and -not (Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)) { Start-Sleep -Milliseconds 500; $i++ }"
        powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)) { exit 1 }"
        if errorlevel 1 (
            echo [MYSQL] MySQL chua mo cong 3306, thu khoi phuc aria_log va bat lai...
            taskkill /F /IM mysqld.exe >NUL 2>&1
            del /F /Q "C:\xampp\mysql\data\aria_log_control" >NUL 2>&1
            del /F /Q "C:\xampp\mysql\data\aria_log.*" >NUL 2>&1
            start "" /B "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini"
            powershell -NoProfile -ExecutionPolicy Bypass -Command "$i=0; while($i -lt 15 -and -not (Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)) { Start-Sleep -Milliseconds 500; $i++ }"
        )
    ) else (
        echo [WARN] Khong tim thay C:\xampp\mysql\bin\mysqld.exe. Hay dam bao MySQL dang chay!
    )
) else (
    echo [MYSQL] MySQL is already running.
)

if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot\bin\javac.exe" (
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot"
    set "PATH=C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot\bin;%PATH%"
) else if defined JAVA_HOME (
    set "PATH=%JAVA_HOME%\bin;%PATH%"
)

echo [BUILD] Compiling source...

if not exist out mkdir out
if exist sources.txt del sources.txt

powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-ChildItem -Recurse -Path src -Filter *.java | ForEach-Object { (Resolve-Path -Relative $_.FullName).Replace('\', '/') }) | Set-Content -Path sources.txt -Encoding Ascii"

javac -encoding UTF-8 -cp "lib\*" -d out @sources.txt

if errorlevel 1 (
    echo [ERROR] Build that bai! Kiem tra loi compile.
    pause
    exit /b
)

echo [OK] Build thanh cong!

echo [CLEANUP] Stopping any old ServerManager process...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'java.exe' -and $_.CommandLine -like '*nro.server.ServerManager*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"

echo [RUN] Starting server...
java -Dfile.encoding=UTF-8 -Xms128m -Xmx3g -Xss256k -XX:CompressedClassSpaceSize=128m -XX:ReservedCodeCacheSize=128m -XX:CICompilerCount=2 -cp "out;lib\*" -Duser.dir="%cd%" nro.server.ServerManager

echo ===============================
echo     Server da dung
echo ===============================
pause