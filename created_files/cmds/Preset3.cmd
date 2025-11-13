@echo off
:: === Check for admin rights ===
>nul 2>&1 net session
if %errorlevel% NEQ 0 (
    echo [INFO] Elevating to administrator...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

echo [INFO] Running with administrative privileges.

SETLOCAL

:: Check if choco is installed
where choco >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo Chocolatey is already installed.
) ELSE (
    echo Chocolatey not found. Installing...

    :: Install Chocolatey
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

    :: Check again
    where choco >nul 2>nul
    IF %ERRORLEVEL% EQU 0 (
        echo Chocolatey installed successfully.
        pause
        exit /b
    ) ELSE (
        echo Failed to install Chocolatey.
        pause
        exit /b
    )
)

ENDLOCAL
pause


:: === HKCU Local telemetry and feedback disable ===
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f  
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f  
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v PeriodInDays /t REG_DWORD /d 0 /f  
reg add "HKCU\Software\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d 1 /f  

:: Optional Office telemetry settings
reg add "HKCU\SOFTWARE\Microsoft\Office\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d 1 /f  
reg add "HKCU\SOFTWARE\Microsoft\Office\Common\ClientTelemetry" /v "VerboseLogging" /t REG_DWORD /d 0 /f  

:: Disable Windows Media Player usage tracking
reg add "HKCU\SOFTWARE\Microsoft\MediaPlayer\Preferences" /v "UsageTracking" /t REG_DWORD /d 0 /f 

echo [OK] Local user optimizations applied.


:: === Global telemetry & tracking disable ===
echo [GLOBAL] Disabling telemetry services and tasks...

sc stop DiagTrack 
sc config DiagTrack start= disabled 
sc stop dmwappushservice 
sc config dmwappushservice start= disabled 
sc config diagnosticshub.standardcollector.service start= disabled 

schtasks /change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE 
schtasks /change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE 
schtasks /change /TN "\Microsoft\Windows\Application Experience\AITAgent" /DISABLE 
schtasks /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE 
schtasks /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE 
schtasks /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE 

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f 

echo [OK] Global telemetry settings applied.

:: === Set High Performance Power Plan ===
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

:: === Disable Background Apps for CURRENT user (HKCU) ===
echo [INFO] Disabling background apps for current user...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v AppBackgroundEnabled /t REG_DWORD /d 0 /f

:: === Disable Background Apps for FUTURE users (Default Profile) ===
echo [INFO] Disabling background apps for future users (Default profile)...

reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v AppBackgroundEnabled /t REG_DWORD /d 0 /f
reg unload HKU\DefaultUser

echo [OK] Background apps have been disabled for both current and future users.

:: === User Creation Block ===

SETLOCAL

:: === Rename Current User ===
set MY_USER=%USERNAME%
echo Renaming current user %USERNAME% to Admin...
wmic useraccount where name="%USERNAME%" rename "Admin"
net user "Admin" /fullname:"Admin"

ENDLOCAL

pause



:: === Folder Setup for Admin ===
IF EXIST C: (
    mkdir "C:\Admin"
    mkdir "C:\Admin\PerfLogs"
    mkdir "C:\Admin\Program Files"
    mkdir "C:\Admin\Program Files (x86)"
    mkdir "C:\Admin\Users"
    mkdir "C:\Admin\Windows"
    mkdir "C:\Admin\XboxGames"
    :: Set permissions for Admin and Admin
    icacls "C:\Admin" /inheritance:r
    icacls "C:\Admin" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Admin"
    :: Set permissions for Admin and Admin
    icacls "D:\Admin" /inheritance:r
    icacls "D:\Admin" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Admin"
    :: Set permissions for Admin and Admin
    icacls "E:\Admin" /inheritance:r
    icacls "E:\Admin" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)


:: === Global App Folders Setup ===
IF EXIST C: (
    mkdir "C:\Apps"
    mkdir "C:\Apps\PerfLogs"
    mkdir "C:\Apps\Program Files"
    mkdir "C:\Apps\Program Files (x86)"
    mkdir "C:\Apps\Users"
    mkdir "C:\Apps\Windows"
    mkdir "C:\Apps\XboxGames"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Apps"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Apps"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)

:: === Global App Install ===
IF EXIST "C:\Apps\PerfLogs" (
    choco install steam -y --ignore-checksums --params "/InstallDir=C:\Apps\PerfLogs"
) ELSE (
    echo Folder C:\Apps\PerfLogs not found. Skipping install for steam.
)
shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f