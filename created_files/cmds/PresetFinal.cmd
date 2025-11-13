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

:: === Disable Bing Search and Start Menu Ads ===

:: For CURRENT USER
:: === Restart Explorer to safely apply UI registry changes ===
taskkill /f /im explorer.exe

:: === Apply registry tweaks ===
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsDeviceSearchHistoryEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsCloudSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f

:: === Restart Explorer to reflect changes ===
start explorer.exe




:: For FUTURE USERS (Default profile)
reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsDeviceSearchHistoryEnabled /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsCloudSearchEnabled /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f
reg unload HKU\DefaultUser


:: === Close OneDrive if running ===
taskkill /f /im OneDrive.exe >nul 2>&1
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

:: === Remove Built-in UWP Apps for Current and New Users ===
powershell -Command "$AppsList=@('Microsoft.MicrosoftOfficeHub','Microsoft.SkypeApp','Microsoft.MicrosoftSolitaireCollection','microsoft.windowscommunicationsapps','Microsoft.People','Microsoft.CommsPhone','Microsoft.WindowsPhone','Microsoft.XboxApp','Microsoft.Messaging','Microsoft.Reader','Microsoft.WindowsCamera','Microsoft.OneConnect','Microsoft.Office.OneNote','Microsoft.WindowsStore','Microsoft.XboxGameOverlay','Microsoft.Windows.Photos','Microsoft.MSPaint','Microsoft.WindowsSoundRecorder','Microsoft.BingWeather','Microsoft.Advertising.Xaml','Microsoft.ZuneMusic','Microsoft.WindowsCalculator','Microsoft.WindowsAlarms','Microsoft.Microsoft3DViewer','Microsoft.ZuneVideo','Microsoft.WindowsFeedbackHub','Microsoft.StorePurchaseApp','Microsoft.MicrosoftStickyNotes');ForEach ($App in $AppsList){$Packages=Get-AppxPackage|Where-Object {$_.Name -eq $App};if($Packages){Write-Output \"Removing Appx Package: $App\";foreach ($Package in $Packages){Remove-AppxPackage -Package $Package.PackageFullName}}else{Write-Output \"Unable to find package: $App\"};$Provisioned=Get-AppxProvisionedPackage -Online|Where-Object {$_.DisplayName -eq $App};if($Provisioned){Write-Output \"Removing Appx Provisioned Package: $App\";Remove-AppxProvisionedPackage -Online -PackageName $Provisioned.PackageName}else{Write-Output \"Unable to find provisioned package: $App\"}}"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
powershell -Command "Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage"
powershell -Command "Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like '*Cortana*' | Remove-AppxProvisionedPackage -Online"

:: === Prevent OneDrive from starting for new users ===
reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT"
reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f
reg unload HKU\DefaultUser


:: === User Creation Block ===

SETLOCAL

:: === Rename Current User ===
set MY_USER=%USERNAME%
echo Renaming current user %USERNAME% to Admin...
wmic useraccount where name="%USERNAME%" rename "Admin"
net user "Admin" /fullname:"Admin"

:: === Create User: Preset1 ===
echo Creating user Preset1...
net user "Preset1" "Pass1" /add
net localgroup Administrators "Preset1" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Preset1 "cmd /c echo Profile initialized for Preset1"
timeout /t 1

:: === Remove Preset1 from Administrators ===
net localgroup Administrators "Preset1" /delete

:: === Create User: Preset2 ===
echo Creating user Preset2...
net user "Preset2" "Pass2" /add
net localgroup Administrators "Preset2" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Preset2 "cmd /c echo Profile initialized for Preset2"
timeout /t 1

:: === Remove Preset2 from Administrators ===
net localgroup Administrators "Preset2" /delete

ENDLOCAL

pause



:: === Folder Setup for Admin ===
IF EXIST C: (
    mkdir "C:\Admin"
    mkdir "C:\Admin\Randrom"
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

:: === Folder Setup for Preset1 ===
IF EXIST C: (
    mkdir "C:\Preset1"
    mkdir "C:\Preset1\PerfLogs"
    mkdir "C:\Preset1\Program Files"
    mkdir "C:\Preset1\Program Files (x86)"
    mkdir "C:\Preset1\Users"
    mkdir "C:\Preset1\Windows"
    mkdir "C:\Preset1\XboxGames"
    :: Set permissions for Preset1 and Admin
    icacls "C:\Preset1" /inheritance:r
    icacls "C:\Preset1" /grant Preset1:"(OI)(CI)F"
    icacls "C:\Preset1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Preset1"
    :: Set permissions for Preset1 and Admin
    icacls "D:\Preset1" /inheritance:r
    icacls "D:\Preset1" /grant Preset1:"(OI)(CI)F"
    icacls "D:\Preset1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Preset1"
    :: Set permissions for Preset1 and Admin
    icacls "E:\Preset1" /inheritance:r
    icacls "E:\Preset1" /grant Preset1:"(OI)(CI)F"
    icacls "E:\Preset1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)

:: === Folder Setup for Preset2 ===
IF EXIST C: (
    mkdir "C:\Preset2"
    mkdir "C:\Preset2\PerfLogs"
    mkdir "C:\Preset2\Program Files"
    mkdir "C:\Preset2\Program Files (x86)"
    mkdir "C:\Preset2\Users"
    mkdir "C:\Preset2\Windows"
    mkdir "C:\Preset2\XboxGames"
    :: Set permissions for Preset2 and Admin
    icacls "C:\Preset2" /inheritance:r
    icacls "C:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "C:\Preset2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Preset2"
    :: Set permissions for Preset2 and Admin
    icacls "D:\Preset2" /inheritance:r
    icacls "D:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "D:\Preset2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Preset2"
    :: Set permissions for Preset2 and Admin
    icacls "E:\Preset2" /inheritance:r
    icacls "E:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "E:\Preset2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)


:: === Global App Folders Setup ===
IF EXIST C: (
    mkdir "C:\Apps"
    mkdir "C:\Apps\Steam"
    mkdir "C:\Apps\Winrar"
    mkdir "C:\Apps\firefox"
    mkdir "C:\Apps\Chrome"
    mkdir "C:\Apps\vscode"
    mkdir "C:\Apps\notepad"
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
IF EXIST "C:\Apps\Steam" (
    choco install steam -y --ignore-checksums --params "/InstallDir=C:\Apps\Steam"
) ELSE (
    echo Folder C:\Apps\Steam not found. Skipping install for steam.
)
IF EXIST "C:\Apps\Winrar" (
    choco install winrar -y --ignore-checksums --params "/InstallDir=C:\Apps\Winrar"
) ELSE (
    echo Folder C:\Apps\Winrar not found. Skipping install for winrar.
)
IF EXIST "C:\Apps\firefox" (
    choco install FirefoxESR -y --ignore-checksums --params "/InstallDir=C:\Apps\firefox"
) ELSE (
    echo Folder C:\Apps\firefox not found. Skipping install for FirefoxESR.
)
IF EXIST "C:\Apps\Chrome" (
    choco install GoogleChrome -y --ignore-checksums --params "/InstallDir=C:\Apps\Chrome"
) ELSE (
    echo Folder C:\Apps\Chrome not found. Skipping install for GoogleChrome.
)
IF EXIST "C:\Apps\vscode" (
    choco install vscode -y --ignore-checksums --params "/InstallDir=C:\Apps\vscode"
) ELSE (
    echo Folder C:\Apps\vscode not found. Skipping install for vscode.
)
IF EXIST "C:\Apps\notepad" (
    choco install notepadplusplus -y --ignore-checksums --params "/InstallDir=C:\Apps\notepad"
) ELSE (
    echo Folder C:\Apps\notepad not found. Skipping install for notepadplusplus.
)
shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f