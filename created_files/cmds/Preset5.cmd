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
echo Renaming current user %USERNAME% to Preset1...
wmic useraccount where name="%USERNAME%" rename "Preset1"
net user "Preset1" /fullname:"Preset1"

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

:: === Create User: Admin ===
echo Creating user Admin...
net user "Admin" "" /add
net localgroup Administrators "Admin" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Admin "cmd /c echo Profile initialized for Admin"
timeout /t 1

:: === Remove Admin from Administrators ===
net localgroup Administrators "Admin" /delete

ENDLOCAL

pause



:: === Folder Setup for Preset1 ===
IF EXIST C: (
    mkdir "C:\Preset1"
    mkdir "C:\Preset1\Steam"
    mkdir "C:\Preset1\Winrar"
    mkdir "C:\Preset1\Firefox"
    :: Set permissions for Preset1 and Preset1
    icacls "C:\Preset1" /inheritance:r
    icacls "C:\Preset1" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Preset1"
    :: Set permissions for Preset1 and Preset1
    icacls "D:\Preset1" /inheritance:r
    icacls "D:\Preset1" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Preset1"
    :: Set permissions for Preset1 and Preset1
    icacls "E:\Preset1" /inheritance:r
    icacls "E:\Preset1" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)

:: === Folder Setup for Preset2 ===
IF EXIST C: (
    mkdir "C:\Preset2"
    mkdir "C:\Preset2\PerfLogs"
    mkdir "C:\Preset2\Program Files"
    mkdir "C:\Preset2\Program Files\Adobe"
    mkdir "C:\Preset2\Program Files\Common Files"
    mkdir "C:\Preset2\Program Files\EA"
    mkdir "C:\Preset2\Program Files\EA Games"
    mkdir "C:\Preset2\Program Files\Electronic Arts"
    mkdir "C:\Preset2\Program Files\FACEIT AC"
    mkdir "C:\Preset2\Program Files\Git"
    mkdir "C:\Preset2\Program Files\Google"
    mkdir "C:\Preset2\Program Files\Intel"
    mkdir "C:\Preset2\Program Files\Internet Explorer"
    mkdir "C:\Preset2\Program Files\Microsoft Office"
    mkdir "C:\Preset2\Program Files\Microsoft Office 15"
    mkdir "C:\Preset2\Program Files\Microsoft OneDrive"
    mkdir "C:\Preset2\Program Files\Microsoft Update Health Tools"
    mkdir "C:\Preset2\Program Files\ModifiableWindowsApps"
    mkdir "C:\Preset2\Program Files\MSBuild"
    mkdir "C:\Preset2\Program Files\NVIDIA Corporation"
    mkdir "C:\Preset2\Program Files\Parsec"
    mkdir "C:\Preset2\Program Files\Parsec Virtual Display Driver"
    mkdir "C:\Preset2\Program Files\Parsec Virtual USB Adapter Driver"
    mkdir "C:\Preset2\Program Files\Razer"
    mkdir "C:\Preset2\Program Files\Reference Assemblies"
    mkdir "C:\Preset2\Program Files\Riot Vanguard"
    mkdir "C:\Preset2\Program Files\RUXIM"
    mkdir "C:\Preset2\Program Files\Windows Defender"
    mkdir "C:\Preset2\Program Files\Windows Defender Advanced Threat Protection"
    mkdir "C:\Preset2\Program Files\Windows Mail"
    mkdir "C:\Preset2\Program Files\Windows Media Player"
    mkdir "C:\Preset2\Program Files\Windows Multimedia Platform"
    mkdir "C:\Preset2\Program Files\Windows NT"
    mkdir "C:\Preset2\Program Files\Windows Photo Viewer"
    mkdir "C:\Preset2\Program Files\Windows Portable Devices"
    mkdir "C:\Preset2\Program Files\Windows Security"
    mkdir "C:\Preset2\Program Files\WindowsPowerShell"
    mkdir "C:\Preset2\Program Files\WinRAR"
    mkdir "C:\Preset2\Program Files (x86)"
    mkdir "C:\Preset2\Program Files (x86)\Common Files"
    mkdir "C:\Preset2\Program Files (x86)\Google"
    mkdir "C:\Preset2\Program Files (x86)\Intel"
    mkdir "C:\Preset2\Program Files (x86)\Internet Explorer"
    mkdir "C:\Preset2\Program Files (x86)\Microsoft"
    mkdir "C:\Preset2\Program Files (x86)\Microsoft.NET"
    mkdir "C:\Preset2\Program Files (x86)\MSBuild"
    mkdir "C:\Preset2\Program Files (x86)\MSI"
    mkdir "C:\Preset2\Program Files (x86)\NVIDIA Corporation"
    mkdir "C:\Preset2\Program Files (x86)\Razer"
    mkdir "C:\Preset2\Program Files (x86)\Realtek"
    mkdir "C:\Preset2\Program Files (x86)\Reference Assemblies"
    mkdir "C:\Preset2\Program Files (x86)\Windows Defender"
    mkdir "C:\Preset2\Program Files (x86)\Windows Mail"
    mkdir "C:\Preset2\Program Files (x86)\Windows Media Player"
    mkdir "C:\Preset2\Program Files (x86)\Windows Multimedia Platform"
    mkdir "C:\Preset2\Program Files (x86)\Windows NT"
    mkdir "C:\Preset2\Program Files (x86)\Windows Photo Viewer"
    mkdir "C:\Preset2\Program Files (x86)\Windows Portable Devices"
    mkdir "C:\Preset2\Program Files (x86)\WindowsPowerShell"
    mkdir "C:\Preset2\Users"
    mkdir "C:\Preset2\Users\Alex"
    mkdir "C:\Preset2\Users\Public"
    mkdir "C:\Preset2\Windows"
    mkdir "C:\Preset2\Windows\addins"
    mkdir "C:\Preset2\Windows\appcompat"
    mkdir "C:\Preset2\Windows\apppatch"
    mkdir "C:\Preset2\Windows\AppReadiness"
    mkdir "C:\Preset2\Windows\assembly"
    mkdir "C:\Preset2\Windows\bcastdvr"
    mkdir "C:\Preset2\Windows\Boot"
    mkdir "C:\Preset2\Windows\Branding"
    mkdir "C:\Preset2\Windows\CbsTemp"
    mkdir "C:\Preset2\Windows\Containers"
    mkdir "C:\Preset2\Windows\CSC"
    mkdir "C:\Preset2\Windows\Cursors"
    mkdir "C:\Preset2\Windows\debug"
    mkdir "C:\Preset2\Windows\diagnostics"
    mkdir "C:\Preset2\Windows\DiagTrack"
    mkdir "C:\Preset2\Windows\DigitalLocker"
    mkdir "C:\Preset2\Windows\Downloaded Program Files"
    mkdir "C:\Preset2\Windows\en-US"
    mkdir "C:\Preset2\Windows\Fonts"
    mkdir "C:\Preset2\Windows\GameBarPresenceWriter"
    mkdir "C:\Preset2\Windows\Globalization"
    mkdir "C:\Preset2\Windows\Help"
    mkdir "C:\Preset2\Windows\IdentityCRL"
    mkdir "C:\Preset2\Windows\IME"
    mkdir "C:\Preset2\Windows\ImmersiveControlPanel"
    mkdir "C:\Preset2\Windows\InboxApps"
    mkdir "C:\Preset2\Windows\INF"
    mkdir "C:\Preset2\Windows\InputMethod"
    mkdir "C:\Preset2\Windows\L2Schemas"
    mkdir "C:\Preset2\Windows\LiveKernelReports"
    mkdir "C:\Preset2\Windows\Logs"
    mkdir "C:\Preset2\Windows\Media"
    mkdir "C:\Preset2\Windows\Microsoft.NET"
    mkdir "C:\Preset2\Windows\Migration"
    mkdir "C:\Preset2\Windows\ModemLogs"
    mkdir "C:\Preset2\Windows\OCR"
    mkdir "C:\Preset2\Windows\Offline Web Pages"
    mkdir "C:\Preset2\Windows\Panther"
    mkdir "C:\Preset2\Windows\Performance"
    mkdir "C:\Preset2\Windows\PLA"
    mkdir "C:\Preset2\Windows\PolicyDefinitions"
    mkdir "C:\Preset2\Windows\Prefetch"
    mkdir "C:\Preset2\Windows\PrintDialog"
    mkdir "C:\Preset2\Windows\Provisioning"
    mkdir "C:\Preset2\Windows\Registration"
    mkdir "C:\Preset2\Windows\RemotePackages"
    mkdir "C:\Preset2\Windows\rescache"
    mkdir "C:\Preset2\Windows\Resources"
    mkdir "C:\Preset2\Windows\ro-RO"
    mkdir "C:\Preset2\Windows\SchCache"
    mkdir "C:\Preset2\Windows\schemas"
    mkdir "C:\Preset2\Windows\security"
    mkdir "C:\Preset2\Windows\ServiceProfiles"
    mkdir "C:\Preset2\Windows\ServiceState"
    mkdir "C:\Preset2\Windows\servicing"
    mkdir "C:\Preset2\Windows\Setup"
    mkdir "C:\Preset2\Windows\ShellComponents"
    mkdir "C:\Preset2\Windows\ShellExperiences"
    mkdir "C:\Preset2\Windows\SKB"
    mkdir "C:\Preset2\Windows\SoftwareDistribution"
    mkdir "C:\Preset2\Windows\Speech"
    mkdir "C:\Preset2\Windows\Speech_OneCore"
    mkdir "C:\Preset2\Windows\System"
    mkdir "C:\Preset2\Windows\System32"
    mkdir "C:\Preset2\Windows\SystemApps"
    mkdir "C:\Preset2\Windows\SystemResources"
    mkdir "C:\Preset2\Windows\SystemTemp"
    mkdir "C:\Preset2\Windows\SysWOW64"
    mkdir "C:\Preset2\Windows\TAPI"
    mkdir "C:\Preset2\Windows\Tasks"
    mkdir "C:\Preset2\Windows\Temp"
    mkdir "C:\Preset2\Windows\tracing"
    mkdir "C:\Preset2\Windows\twain_32"
    mkdir "C:\Preset2\Windows\Vss"
    mkdir "C:\Preset2\Windows\WaaS"
    mkdir "C:\Preset2\Windows\Web"
    mkdir "C:\Preset2\Windows\WinSxS"
    mkdir "C:\Preset2\XboxGames"
    mkdir "C:\Preset2\XboxGames\GameSave"
    :: Set permissions for Preset2 and Preset1
    icacls "C:\Preset2" /inheritance:r
    icacls "C:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "C:\Preset2" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Preset2"
    :: Set permissions for Preset2 and Preset1
    icacls "D:\Preset2" /inheritance:r
    icacls "D:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "D:\Preset2" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Preset2"
    :: Set permissions for Preset2 and Preset1
    icacls "E:\Preset2" /inheritance:r
    icacls "E:\Preset2" /grant Preset2:"(OI)(CI)F"
    icacls "E:\Preset2" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)

:: === Folder Setup for Admin ===
IF EXIST C: (
    mkdir "C:\Admin"
    mkdir "C:\Admin\steam"
    :: Set permissions for Admin and Preset1
    icacls "C:\Admin" /inheritance:r
    icacls "C:\Admin" /grant Admin:"(OI)(CI)F"
    icacls "C:\Admin" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Admin"
    :: Set permissions for Admin and Preset1
    icacls "D:\Admin" /inheritance:r
    icacls "D:\Admin" /grant Admin:"(OI)(CI)F"
    icacls "D:\Admin" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Admin"
    :: Set permissions for Admin and Preset1
    icacls "E:\Admin" /inheritance:r
    icacls "E:\Admin" /grant Admin:"(OI)(CI)F"
    icacls "E:\Admin" /grant Preset1:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)


:: === Global App Folders Setup ===
IF EXIST C: (
    mkdir "C:\Apps"
    mkdir "C:\Apps\Stea"
    mkdir "C:\Apps\winrar"
    mkdir "C:\Apps\notepadplus"
    mkdir "C:\Apps\vscode"
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
IF EXIST "C:\Apps\Stea" (
    choco install steam -y --ignore-checksums --params "/InstallDir=C:\Apps\Stea"
) ELSE (
    echo Folder C:\Apps\Stea not found. Skipping install for steam.
)
IF EXIST "C:\Apps\winrar" (
    choco install winrar -y --ignore-checksums --params "/InstallDir=C:\Apps\winrar"
) ELSE (
    echo Folder C:\Apps\winrar not found. Skipping install for winrar.
)
IF EXIST "C:\Apps\notepadplus" (
    choco install notepadplusplus -y --ignore-checksums --params "/InstallDir=C:\Apps\notepadplus"
) ELSE (
    echo Folder C:\Apps\notepadplus not found. Skipping install for notepadplusplus.
)
IF EXIST "C:\Apps\vscode" (
    choco install vscode -y --ignore-checksums --params "/InstallDir=C:\Apps\vscode"
) ELSE (
    echo Folder C:\Apps\vscode not found. Skipping install for vscode.
)
shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f