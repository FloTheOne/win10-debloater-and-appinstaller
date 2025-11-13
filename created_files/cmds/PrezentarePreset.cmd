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
    exit /b   
)
ENDLOCAL


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

:: === Create User: Nume1 ===
echo Creating user Nume1...
net user "Nume1" "Pass1" /add
net localgroup Administrators "Nume1" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Nume1 "cmd /c echo Profile initialized for Nume1"
timeout /t 1

:: === Remove Nume1 from Administrators ===
net localgroup Administrators "Nume1" /delete

:: === Create User: Nume2 ===
echo Creating user Nume2...
net user "Nume2" "Pass2" /add
net localgroup Administrators "Nume2" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Nume2 "cmd /c echo Profile initialized for Nume2"
timeout /t 1

:: === Remove Nume2 from Administrators ===
net localgroup Administrators "Nume2" /delete

ENDLOCAL



:: === Folder Setup for Admin ===
IF EXIST C: (
    mkdir "C:\Admin"
    mkdir "C:\Admin\PerfLogs"
    mkdir "C:\Admin\Program Files"
    mkdir "C:\Admin\Program Files\Adobe"
    mkdir "C:\Admin\Program Files\Common Files"
    mkdir "C:\Admin\Program Files\EA"
    mkdir "C:\Admin\Program Files\EA Games"
    mkdir "C:\Admin\Program Files\Electronic Arts"
    mkdir "C:\Admin\Program Files\FACEIT AC"
    mkdir "C:\Admin\Program Files\Git"
    mkdir "C:\Admin\Program Files\Google"
    mkdir "C:\Admin\Program Files\Intel"
    mkdir "C:\Admin\Program Files\Internet Explorer"
    mkdir "C:\Admin\Program Files\Microsoft Office"
    mkdir "C:\Admin\Program Files\Microsoft Office 15"
    mkdir "C:\Admin\Program Files\Microsoft OneDrive"
    mkdir "C:\Admin\Program Files\Microsoft Update Health Tools"
    mkdir "C:\Admin\Program Files\ModifiableWindowsApps"
    mkdir "C:\Admin\Program Files\MSBuild"
    mkdir "C:\Admin\Program Files\NVIDIA Corporation"
    mkdir "C:\Admin\Program Files\Oracle"
    mkdir "C:\Admin\Program Files\Parsec"
    mkdir "C:\Admin\Program Files\Parsec Virtual Display Driver"
    mkdir "C:\Admin\Program Files\Parsec Virtual USB Adapter Driver"
    mkdir "C:\Admin\Program Files\Razer"
    mkdir "C:\Admin\Program Files\Reference Assemblies"
    mkdir "C:\Admin\Program Files\Riot Vanguard"
    mkdir "C:\Admin\Program Files\RUXIM"
    mkdir "C:\Admin\Program Files\Windows Defender"
    mkdir "C:\Admin\Program Files\Windows Defender Advanced Threat Protection"
    mkdir "C:\Admin\Program Files\Windows Mail"
    mkdir "C:\Admin\Program Files\Windows Media Player"
    mkdir "C:\Admin\Program Files\Windows Multimedia Platform"
    mkdir "C:\Admin\Program Files\Windows NT"
    mkdir "C:\Admin\Program Files\Windows Photo Viewer"
    mkdir "C:\Admin\Program Files\Windows Portable Devices"
    mkdir "C:\Admin\Program Files\Windows Security"
    mkdir "C:\Admin\Program Files\WindowsPowerShell"
    mkdir "C:\Admin\Program Files\WinRAR"
    mkdir "C:\Admin\Program Files (x86)"
    mkdir "C:\Admin\Program Files (x86)\Common Files"
    mkdir "C:\Admin\Program Files (x86)\EasyAntiCheat_EOS"
    mkdir "C:\Admin\Program Files (x86)\Google"
    mkdir "C:\Admin\Program Files (x86)\Intel"
    mkdir "C:\Admin\Program Files (x86)\Internet Explorer"
    mkdir "C:\Admin\Program Files (x86)\Microsoft"
    mkdir "C:\Admin\Program Files (x86)\Microsoft.NET"
    mkdir "C:\Admin\Program Files (x86)\MSBuild"
    mkdir "C:\Admin\Program Files (x86)\MSI"
    mkdir "C:\Admin\Program Files (x86)\NVIDIA Corporation"
    mkdir "C:\Admin\Program Files (x86)\Razer"
    mkdir "C:\Admin\Program Files (x86)\Realtek"
    mkdir "C:\Admin\Program Files (x86)\Reference Assemblies"
    mkdir "C:\Admin\Program Files (x86)\Windows Defender"
    mkdir "C:\Admin\Program Files (x86)\Windows Mail"
    mkdir "C:\Admin\Program Files (x86)\Windows Media Player"
    mkdir "C:\Admin\Program Files (x86)\Windows Multimedia Platform"
    mkdir "C:\Admin\Program Files (x86)\Windows NT"
    mkdir "C:\Admin\Program Files (x86)\Windows Photo Viewer"
    mkdir "C:\Admin\Program Files (x86)\Windows Portable Devices"
    mkdir "C:\Admin\Program Files (x86)\WindowsPowerShell"
    mkdir "C:\Admin\Users"
    mkdir "C:\Admin\Users\Alex"
    mkdir "C:\Admin\Users\Public"
    mkdir "C:\Admin\Windows"
    mkdir "C:\Admin\Windows\addins"
    mkdir "C:\Admin\Windows\appcompat"
    mkdir "C:\Admin\Windows\apppatch"
    mkdir "C:\Admin\Windows\AppReadiness"
    mkdir "C:\Admin\Windows\assembly"
    mkdir "C:\Admin\Windows\bcastdvr"
    mkdir "C:\Admin\Windows\Boot"
    mkdir "C:\Admin\Windows\Branding"
    mkdir "C:\Admin\Windows\CbsTemp"
    mkdir "C:\Admin\Windows\Containers"
    mkdir "C:\Admin\Windows\CSC"
    mkdir "C:\Admin\Windows\Cursors"
    mkdir "C:\Admin\Windows\debug"
    mkdir "C:\Admin\Windows\diagnostics"
    mkdir "C:\Admin\Windows\DiagTrack"
    mkdir "C:\Admin\Windows\DigitalLocker"
    mkdir "C:\Admin\Windows\Downloaded Program Files"
    mkdir "C:\Admin\Windows\en-US"
    mkdir "C:\Admin\Windows\Fonts"
    mkdir "C:\Admin\Windows\GameBarPresenceWriter"
    mkdir "C:\Admin\Windows\Globalization"
    mkdir "C:\Admin\Windows\Help"
    mkdir "C:\Admin\Windows\IdentityCRL"
    mkdir "C:\Admin\Windows\IME"
    mkdir "C:\Admin\Windows\ImmersiveControlPanel"
    mkdir "C:\Admin\Windows\InboxApps"
    mkdir "C:\Admin\Windows\INF"
    mkdir "C:\Admin\Windows\InputMethod"
    mkdir "C:\Admin\Windows\L2Schemas"
    mkdir "C:\Admin\Windows\LiveKernelReports"
    mkdir "C:\Admin\Windows\Logs"
    mkdir "C:\Admin\Windows\Media"
    mkdir "C:\Admin\Windows\Microsoft.NET"
    mkdir "C:\Admin\Windows\Migration"
    mkdir "C:\Admin\Windows\ModemLogs"
    mkdir "C:\Admin\Windows\OCR"
    mkdir "C:\Admin\Windows\Offline Web Pages"
    mkdir "C:\Admin\Windows\Panther"
    mkdir "C:\Admin\Windows\Performance"
    mkdir "C:\Admin\Windows\PLA"
    mkdir "C:\Admin\Windows\PolicyDefinitions"
    mkdir "C:\Admin\Windows\Prefetch"
    mkdir "C:\Admin\Windows\PrintDialog"
    mkdir "C:\Admin\Windows\Provisioning"
    mkdir "C:\Admin\Windows\Registration"
    mkdir "C:\Admin\Windows\RemotePackages"
    mkdir "C:\Admin\Windows\rescache"
    mkdir "C:\Admin\Windows\Resources"
    mkdir "C:\Admin\Windows\ro-RO"
    mkdir "C:\Admin\Windows\SchCache"
    mkdir "C:\Admin\Windows\schemas"
    mkdir "C:\Admin\Windows\security"
    mkdir "C:\Admin\Windows\ServiceProfiles"
    mkdir "C:\Admin\Windows\ServiceState"
    mkdir "C:\Admin\Windows\servicing"
    mkdir "C:\Admin\Windows\Setup"
    mkdir "C:\Admin\Windows\ShellComponents"
    mkdir "C:\Admin\Windows\ShellExperiences"
    mkdir "C:\Admin\Windows\SKB"
    mkdir "C:\Admin\Windows\SoftwareDistribution"
    mkdir "C:\Admin\Windows\Speech"
    mkdir "C:\Admin\Windows\Speech_OneCore"
    mkdir "C:\Admin\Windows\System"
    mkdir "C:\Admin\Windows\System32"
    mkdir "C:\Admin\Windows\SystemApps"
    mkdir "C:\Admin\Windows\SystemResources"
    mkdir "C:\Admin\Windows\SystemTemp"
    mkdir "C:\Admin\Windows\SysWOW64"
    mkdir "C:\Admin\Windows\TAPI"
    mkdir "C:\Admin\Windows\Tasks"
    mkdir "C:\Admin\Windows\Temp"
    mkdir "C:\Admin\Windows\tracing"
    mkdir "C:\Admin\Windows\twain_32"
    mkdir "C:\Admin\Windows\Vss"
    mkdir "C:\Admin\Windows\WaaS"
    mkdir "C:\Admin\Windows\Web"
    mkdir "C:\Admin\Windows\WinSxS"
    mkdir "C:\Admin\XboxGames"
    mkdir "C:\Admin\XboxGames\GameSave"
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
IF EXIST F: (
    mkdir "F:\Admin"
    :: Set permissions for Admin and Admin
    icacls "F:\Admin" /inheritance:r
    icacls "F:\Admin" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive F: not found. Skipping folder creation.
)

:: === Folder Setup for Nume1 ===
IF EXIST C: (
    mkdir "C:\Nume1"
    mkdir "C:\Nume1\PerfLogs"
    mkdir "C:\Nume1\Program Files"
    mkdir "C:\Nume1\Program Files\Adobe"
    mkdir "C:\Nume1\Program Files\Common Files"
    mkdir "C:\Nume1\Program Files\EA"
    mkdir "C:\Nume1\Program Files\EA Games"
    mkdir "C:\Nume1\Program Files\Electronic Arts"
    mkdir "C:\Nume1\Program Files\FACEIT AC"
    mkdir "C:\Nume1\Program Files\Git"
    mkdir "C:\Nume1\Program Files\Google"
    mkdir "C:\Nume1\Program Files\Intel"
    mkdir "C:\Nume1\Program Files\Internet Explorer"
    mkdir "C:\Nume1\Program Files\Microsoft Office"
    mkdir "C:\Nume1\Program Files\Microsoft Office 15"
    mkdir "C:\Nume1\Program Files\Microsoft OneDrive"
    mkdir "C:\Nume1\Program Files\Microsoft Update Health Tools"
    mkdir "C:\Nume1\Program Files\ModifiableWindowsApps"
    mkdir "C:\Nume1\Program Files\MSBuild"
    mkdir "C:\Nume1\Program Files\NVIDIA Corporation"
    mkdir "C:\Nume1\Program Files\Oracle"
    mkdir "C:\Nume1\Program Files\Parsec"
    mkdir "C:\Nume1\Program Files\Parsec Virtual Display Driver"
    mkdir "C:\Nume1\Program Files\Parsec Virtual USB Adapter Driver"
    mkdir "C:\Nume1\Program Files\Razer"
    mkdir "C:\Nume1\Program Files\Reference Assemblies"
    mkdir "C:\Nume1\Program Files\Riot Vanguard"
    mkdir "C:\Nume1\Program Files\RUXIM"
    mkdir "C:\Nume1\Program Files\Windows Defender"
    mkdir "C:\Nume1\Program Files\Windows Defender Advanced Threat Protection"
    mkdir "C:\Nume1\Program Files\Windows Mail"
    mkdir "C:\Nume1\Program Files\Windows Media Player"
    mkdir "C:\Nume1\Program Files\Windows Multimedia Platform"
    mkdir "C:\Nume1\Program Files\Windows NT"
    mkdir "C:\Nume1\Program Files\Windows Photo Viewer"
    mkdir "C:\Nume1\Program Files\Windows Portable Devices"
    mkdir "C:\Nume1\Program Files\Windows Security"
    mkdir "C:\Nume1\Program Files\WindowsPowerShell"
    mkdir "C:\Nume1\Program Files\WinRAR"
    mkdir "C:\Nume1\Program Files (x86)"
    mkdir "C:\Nume1\Program Files (x86)\Common Files"
    mkdir "C:\Nume1\Program Files (x86)\EasyAntiCheat_EOS"
    mkdir "C:\Nume1\Program Files (x86)\Google"
    mkdir "C:\Nume1\Program Files (x86)\Intel"
    mkdir "C:\Nume1\Program Files (x86)\Internet Explorer"
    mkdir "C:\Nume1\Program Files (x86)\Microsoft"
    mkdir "C:\Nume1\Program Files (x86)\Microsoft.NET"
    mkdir "C:\Nume1\Program Files (x86)\MSBuild"
    mkdir "C:\Nume1\Program Files (x86)\MSI"
    mkdir "C:\Nume1\Program Files (x86)\NVIDIA Corporation"
    mkdir "C:\Nume1\Program Files (x86)\Razer"
    mkdir "C:\Nume1\Program Files (x86)\Realtek"
    mkdir "C:\Nume1\Program Files (x86)\Reference Assemblies"
    mkdir "C:\Nume1\Program Files (x86)\Windows Defender"
    mkdir "C:\Nume1\Program Files (x86)\Windows Mail"
    mkdir "C:\Nume1\Program Files (x86)\Windows Media Player"
    mkdir "C:\Nume1\Program Files (x86)\Windows Multimedia Platform"
    mkdir "C:\Nume1\Program Files (x86)\Windows NT"
    mkdir "C:\Nume1\Program Files (x86)\Windows Photo Viewer"
    mkdir "C:\Nume1\Program Files (x86)\Windows Portable Devices"
    mkdir "C:\Nume1\Program Files (x86)\WindowsPowerShell"
    mkdir "C:\Nume1\Users"
    mkdir "C:\Nume1\Users\Alex"
    mkdir "C:\Nume1\Users\Public"
    mkdir "C:\Nume1\Windows"
    mkdir "C:\Nume1\Windows\addins"
    mkdir "C:\Nume1\Windows\appcompat"
    mkdir "C:\Nume1\Windows\apppatch"
    mkdir "C:\Nume1\Windows\AppReadiness"
    mkdir "C:\Nume1\Windows\assembly"
    mkdir "C:\Nume1\Windows\bcastdvr"
    mkdir "C:\Nume1\Windows\Boot"
    mkdir "C:\Nume1\Windows\Branding"
    mkdir "C:\Nume1\Windows\CbsTemp"
    mkdir "C:\Nume1\Windows\Containers"
    mkdir "C:\Nume1\Windows\CSC"
    mkdir "C:\Nume1\Windows\Cursors"
    mkdir "C:\Nume1\Windows\debug"
    mkdir "C:\Nume1\Windows\diagnostics"
    mkdir "C:\Nume1\Windows\DiagTrack"
    mkdir "C:\Nume1\Windows\DigitalLocker"
    mkdir "C:\Nume1\Windows\Downloaded Program Files"
    mkdir "C:\Nume1\Windows\en-US"
    mkdir "C:\Nume1\Windows\Fonts"
    mkdir "C:\Nume1\Windows\GameBarPresenceWriter"
    mkdir "C:\Nume1\Windows\Globalization"
    mkdir "C:\Nume1\Windows\Help"
    mkdir "C:\Nume1\Windows\IdentityCRL"
    mkdir "C:\Nume1\Windows\IME"
    mkdir "C:\Nume1\Windows\ImmersiveControlPanel"
    mkdir "C:\Nume1\Windows\InboxApps"
    mkdir "C:\Nume1\Windows\INF"
    mkdir "C:\Nume1\Windows\InputMethod"
    mkdir "C:\Nume1\Windows\L2Schemas"
    mkdir "C:\Nume1\Windows\LiveKernelReports"
    mkdir "C:\Nume1\Windows\Logs"
    mkdir "C:\Nume1\Windows\Media"
    mkdir "C:\Nume1\Windows\Microsoft.NET"
    mkdir "C:\Nume1\Windows\Migration"
    mkdir "C:\Nume1\Windows\ModemLogs"
    mkdir "C:\Nume1\Windows\OCR"
    mkdir "C:\Nume1\Windows\Offline Web Pages"
    mkdir "C:\Nume1\Windows\Panther"
    mkdir "C:\Nume1\Windows\Performance"
    mkdir "C:\Nume1\Windows\PLA"
    mkdir "C:\Nume1\Windows\PolicyDefinitions"
    mkdir "C:\Nume1\Windows\Prefetch"
    mkdir "C:\Nume1\Windows\PrintDialog"
    mkdir "C:\Nume1\Windows\Provisioning"
    mkdir "C:\Nume1\Windows\Registration"
    mkdir "C:\Nume1\Windows\RemotePackages"
    mkdir "C:\Nume1\Windows\rescache"
    mkdir "C:\Nume1\Windows\Resources"
    mkdir "C:\Nume1\Windows\ro-RO"
    mkdir "C:\Nume1\Windows\SchCache"
    mkdir "C:\Nume1\Windows\schemas"
    mkdir "C:\Nume1\Windows\security"
    mkdir "C:\Nume1\Windows\ServiceProfiles"
    mkdir "C:\Nume1\Windows\ServiceState"
    mkdir "C:\Nume1\Windows\servicing"
    mkdir "C:\Nume1\Windows\Setup"
    mkdir "C:\Nume1\Windows\ShellComponents"
    mkdir "C:\Nume1\Windows\ShellExperiences"
    mkdir "C:\Nume1\Windows\SKB"
    mkdir "C:\Nume1\Windows\SoftwareDistribution"
    mkdir "C:\Nume1\Windows\Speech"
    mkdir "C:\Nume1\Windows\Speech_OneCore"
    mkdir "C:\Nume1\Windows\System"
    mkdir "C:\Nume1\Windows\System32"
    mkdir "C:\Nume1\Windows\SystemApps"
    mkdir "C:\Nume1\Windows\SystemResources"
    mkdir "C:\Nume1\Windows\SystemTemp"
    mkdir "C:\Nume1\Windows\SysWOW64"
    mkdir "C:\Nume1\Windows\TAPI"
    mkdir "C:\Nume1\Windows\Tasks"
    mkdir "C:\Nume1\Windows\Temp"
    mkdir "C:\Nume1\Windows\tracing"
    mkdir "C:\Nume1\Windows\twain_32"
    mkdir "C:\Nume1\Windows\Vss"
    mkdir "C:\Nume1\Windows\WaaS"
    mkdir "C:\Nume1\Windows\Web"
    mkdir "C:\Nume1\Windows\WinSxS"
    mkdir "C:\Nume1\XboxGames"
    mkdir "C:\Nume1\XboxGames\GameSave"
    :: Set permissions for Nume1 and Admin
    icacls "C:\Nume1" /inheritance:r
    icacls "C:\Nume1" /grant Nume1:"(OI)(CI)F"
    icacls "C:\Nume1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Nume1"
    :: Set permissions for Nume1 and Admin
    icacls "E:\Nume1" /inheritance:r
    icacls "E:\Nume1" /grant Nume1:"(OI)(CI)F"
    icacls "E:\Nume1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)
IF EXIST F: (
    mkdir "F:\Nume1"
    :: Set permissions for Nume1 and Admin
    icacls "F:\Nume1" /inheritance:r
    icacls "F:\Nume1" /grant Nume1:"(OI)(CI)F"
    icacls "F:\Nume1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive F: not found. Skipping folder creation.
)

:: === Folder Setup for Nume2 ===
IF EXIST C: (
    mkdir "C:\Nume2"
    mkdir "C:\Nume2\PerfLogs"
    mkdir "C:\Nume2\Program Files"
    mkdir "C:\Nume2\Program Files\Adobe"
    mkdir "C:\Nume2\Program Files\Common Files"
    mkdir "C:\Nume2\Program Files\EA"
    mkdir "C:\Nume2\Program Files\EA Games"
    mkdir "C:\Nume2\Program Files\Electronic Arts"
    mkdir "C:\Nume2\Program Files\FACEIT AC"
    mkdir "C:\Nume2\Program Files\Git"
    mkdir "C:\Nume2\Program Files\Google"
    mkdir "C:\Nume2\Program Files\Intel"
    mkdir "C:\Nume2\Program Files\Internet Explorer"
    mkdir "C:\Nume2\Program Files\Microsoft Office"
    mkdir "C:\Nume2\Program Files\Microsoft Office 15"
    mkdir "C:\Nume2\Program Files\Microsoft OneDrive"
    mkdir "C:\Nume2\Program Files\Microsoft Update Health Tools"
    mkdir "C:\Nume2\Program Files\ModifiableWindowsApps"
    mkdir "C:\Nume2\Program Files\MSBuild"
    mkdir "C:\Nume2\Program Files\NVIDIA Corporation"
    mkdir "C:\Nume2\Program Files\Oracle"
    mkdir "C:\Nume2\Program Files\Parsec"
    mkdir "C:\Nume2\Program Files\Parsec Virtual Display Driver"
    mkdir "C:\Nume2\Program Files\Parsec Virtual USB Adapter Driver"
    mkdir "C:\Nume2\Program Files\Razer"
    mkdir "C:\Nume2\Program Files\Reference Assemblies"
    mkdir "C:\Nume2\Program Files\Riot Vanguard"
    mkdir "C:\Nume2\Program Files\RUXIM"
    mkdir "C:\Nume2\Program Files\Windows Defender"
    mkdir "C:\Nume2\Program Files\Windows Defender Advanced Threat Protection"
    mkdir "C:\Nume2\Program Files\Windows Mail"
    mkdir "C:\Nume2\Program Files\Windows Media Player"
    mkdir "C:\Nume2\Program Files\Windows Multimedia Platform"
    mkdir "C:\Nume2\Program Files\Windows NT"
    mkdir "C:\Nume2\Program Files\Windows Photo Viewer"
    mkdir "C:\Nume2\Program Files\Windows Portable Devices"
    mkdir "C:\Nume2\Program Files\Windows Security"
    mkdir "C:\Nume2\Program Files\WindowsPowerShell"
    mkdir "C:\Nume2\Program Files\WinRAR"
    mkdir "C:\Nume2\Program Files (x86)"
    mkdir "C:\Nume2\Program Files (x86)\Common Files"
    mkdir "C:\Nume2\Program Files (x86)\EasyAntiCheat_EOS"
    mkdir "C:\Nume2\Program Files (x86)\Google"
    mkdir "C:\Nume2\Program Files (x86)\Intel"
    mkdir "C:\Nume2\Program Files (x86)\Internet Explorer"
    mkdir "C:\Nume2\Program Files (x86)\Microsoft"
    mkdir "C:\Nume2\Program Files (x86)\Microsoft.NET"
    mkdir "C:\Nume2\Program Files (x86)\MSBuild"
    mkdir "C:\Nume2\Program Files (x86)\MSI"
    mkdir "C:\Nume2\Program Files (x86)\NVIDIA Corporation"
    mkdir "C:\Nume2\Program Files (x86)\Razer"
    mkdir "C:\Nume2\Program Files (x86)\Realtek"
    mkdir "C:\Nume2\Program Files (x86)\Reference Assemblies"
    mkdir "C:\Nume2\Program Files (x86)\Windows Defender"
    mkdir "C:\Nume2\Program Files (x86)\Windows Mail"
    mkdir "C:\Nume2\Program Files (x86)\Windows Media Player"
    mkdir "C:\Nume2\Program Files (x86)\Windows Multimedia Platform"
    mkdir "C:\Nume2\Program Files (x86)\Windows NT"
    mkdir "C:\Nume2\Program Files (x86)\Windows Photo Viewer"
    mkdir "C:\Nume2\Program Files (x86)\Windows Portable Devices"
    mkdir "C:\Nume2\Program Files (x86)\WindowsPowerShell"
    mkdir "C:\Nume2\Users"
    mkdir "C:\Nume2\Users\Alex"
    mkdir "C:\Nume2\Users\Public"
    mkdir "C:\Nume2\Windows"
    mkdir "C:\Nume2\Windows\addins"
    mkdir "C:\Nume2\Windows\appcompat"
    mkdir "C:\Nume2\Windows\apppatch"
    mkdir "C:\Nume2\Windows\AppReadiness"
    mkdir "C:\Nume2\Windows\assembly"
    mkdir "C:\Nume2\Windows\bcastdvr"
    mkdir "C:\Nume2\Windows\Boot"
    mkdir "C:\Nume2\Windows\Branding"
    mkdir "C:\Nume2\Windows\CbsTemp"
    mkdir "C:\Nume2\Windows\Containers"
    mkdir "C:\Nume2\Windows\CSC"
    mkdir "C:\Nume2\Windows\Cursors"
    mkdir "C:\Nume2\Windows\debug"
    mkdir "C:\Nume2\Windows\diagnostics"
    mkdir "C:\Nume2\Windows\DiagTrack"
    mkdir "C:\Nume2\Windows\DigitalLocker"
    mkdir "C:\Nume2\Windows\Downloaded Program Files"
    mkdir "C:\Nume2\Windows\en-US"
    mkdir "C:\Nume2\Windows\Fonts"
    mkdir "C:\Nume2\Windows\GameBarPresenceWriter"
    mkdir "C:\Nume2\Windows\Globalization"
    mkdir "C:\Nume2\Windows\Help"
    mkdir "C:\Nume2\Windows\IdentityCRL"
    mkdir "C:\Nume2\Windows\IME"
    mkdir "C:\Nume2\Windows\ImmersiveControlPanel"
    mkdir "C:\Nume2\Windows\InboxApps"
    mkdir "C:\Nume2\Windows\INF"
    mkdir "C:\Nume2\Windows\InputMethod"
    mkdir "C:\Nume2\Windows\L2Schemas"
    mkdir "C:\Nume2\Windows\LiveKernelReports"
    mkdir "C:\Nume2\Windows\Logs"
    mkdir "C:\Nume2\Windows\Media"
    mkdir "C:\Nume2\Windows\Microsoft.NET"
    mkdir "C:\Nume2\Windows\Migration"
    mkdir "C:\Nume2\Windows\ModemLogs"
    mkdir "C:\Nume2\Windows\OCR"
    mkdir "C:\Nume2\Windows\Offline Web Pages"
    mkdir "C:\Nume2\Windows\Panther"
    mkdir "C:\Nume2\Windows\Performance"
    mkdir "C:\Nume2\Windows\PLA"
    mkdir "C:\Nume2\Windows\PolicyDefinitions"
    mkdir "C:\Nume2\Windows\Prefetch"
    mkdir "C:\Nume2\Windows\PrintDialog"
    mkdir "C:\Nume2\Windows\Provisioning"
    mkdir "C:\Nume2\Windows\Registration"
    mkdir "C:\Nume2\Windows\RemotePackages"
    mkdir "C:\Nume2\Windows\rescache"
    mkdir "C:\Nume2\Windows\Resources"
    mkdir "C:\Nume2\Windows\ro-RO"
    mkdir "C:\Nume2\Windows\SchCache"
    mkdir "C:\Nume2\Windows\schemas"
    mkdir "C:\Nume2\Windows\security"
    mkdir "C:\Nume2\Windows\ServiceProfiles"
    mkdir "C:\Nume2\Windows\ServiceState"
    mkdir "C:\Nume2\Windows\servicing"
    mkdir "C:\Nume2\Windows\Setup"
    mkdir "C:\Nume2\Windows\ShellComponents"
    mkdir "C:\Nume2\Windows\ShellExperiences"
    mkdir "C:\Nume2\Windows\SKB"
    mkdir "C:\Nume2\Windows\SoftwareDistribution"
    mkdir "C:\Nume2\Windows\Speech"
    mkdir "C:\Nume2\Windows\Speech_OneCore"
    mkdir "C:\Nume2\Windows\System"
    mkdir "C:\Nume2\Windows\System32"
    mkdir "C:\Nume2\Windows\SystemApps"
    mkdir "C:\Nume2\Windows\SystemResources"
    mkdir "C:\Nume2\Windows\SystemTemp"
    mkdir "C:\Nume2\Windows\SysWOW64"
    mkdir "C:\Nume2\Windows\TAPI"
    mkdir "C:\Nume2\Windows\Tasks"
    mkdir "C:\Nume2\Windows\Temp"
    mkdir "C:\Nume2\Windows\tracing"
    mkdir "C:\Nume2\Windows\twain_32"
    mkdir "C:\Nume2\Windows\Vss"
    mkdir "C:\Nume2\Windows\WaaS"
    mkdir "C:\Nume2\Windows\Web"
    mkdir "C:\Nume2\Windows\WinSxS"
    mkdir "C:\Nume2\XboxGames"
    mkdir "C:\Nume2\XboxGames\GameSave"
    :: Set permissions for Nume2 and Admin
    icacls "C:\Nume2" /inheritance:r
    icacls "C:\Nume2" /grant Nume2:"(OI)(CI)F"
    icacls "C:\Nume2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)


:: === Global App Folders Setup ===
IF EXIST C: (
    mkdir "C:\Apps"
    mkdir "C:\Apps\Steam"
    mkdir "C:\Apps\Notepad"
    mkdir "C:\Apps\Winrar"
    mkdir "C:\Apps\Chrome"
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
IF EXIST F: (
    mkdir "F:\Apps"
) ELSE (
    echo Drive F: not found. Skipping folder creation.
)

:: === Global App Install ===
IF EXIST "C:\Apps\Steam" (
    choco install steam -y --ignore-checksums --params "/InstallDir=C:\Apps\Steam"
) ELSE (
    echo Folder C:\Apps\Steam not found. Skipping install for steam.
)
IF EXIST "C:\Apps\Notepad" (
    choco install notepadplusplus -y --ignore-checksums --params "/InstallDir=C:\Apps\Notepad"
) ELSE (
    echo Folder C:\Apps\Notepad not found. Skipping install for notepadplusplus.
)
IF EXIST "C:\Apps\Winrar" (
    choco install winrar -y --ignore-checksums --params "/InstallDir=C:\Apps\Winrar"
) ELSE (
    echo Folder C:\Apps\Winrar not found. Skipping install for winrar.
)
IF EXIST "C:\Apps\Chrome" (
    choco install GoogleChrome -y --ignore-checksums --params "/InstallDir=C:\Apps\Chrome"
) ELSE (
    echo Folder C:\Apps\Chrome not found. Skipping install for GoogleChrome.
)
shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f