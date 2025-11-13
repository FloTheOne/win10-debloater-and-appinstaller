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
        powershell -Command "Start-Process '%~f0' -Verb runAs"
        exit /b
    ) ELSE (
        echo Failed to install Chocolatey.
        powershell -Command "Start-Process '%~f0' -Verb runAs"
        exit /b
    )
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

:: === Create User: Name1 ===
echo Creating user Name1...
net user "Name1" "Pass1" /add
net localgroup Administrators "Name1" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Name1 "cmd /c echo Profile initialized for Name1"
timeout /t 1

:: === Remove Name1 from Administrators ===
net localgroup Administrators "Name1" /delete

:: === Create User: Name2 ===
echo Creating user Name2...
net user "Name2" "Pass2" /add
net localgroup Administrators "Name2" /add
timeout /t 1

:: === Trigger profile creation ===
runas /user:Name2 "cmd /c echo Profile initialized for Name2"
timeout /t 1

:: === Remove Name2 from Administrators ===
net localgroup Administrators "Name2" /delete

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

:: === Folder Setup for Name1 ===
IF EXIST C: (
    mkdir "C:\Name1"
    mkdir "C:\Name1\PerfLogs"
    mkdir "C:\Name1\Program Files"
    mkdir "C:\Name1\Program Files\Adobe"
    mkdir "C:\Name1\Program Files\Common Files"
    mkdir "C:\Name1\Program Files\EA"
    mkdir "C:\Name1\Program Files\EA Games"
    mkdir "C:\Name1\Program Files\Electronic Arts"
    mkdir "C:\Name1\Program Files\FACEIT AC"
    mkdir "C:\Name1\Program Files\Git"
    mkdir "C:\Name1\Program Files\Google"
    mkdir "C:\Name1\Program Files\Intel"
    mkdir "C:\Name1\Program Files\Internet Explorer"
    mkdir "C:\Name1\Program Files\Microsoft Office"
    mkdir "C:\Name1\Program Files\Microsoft Office 15"
    mkdir "C:\Name1\Program Files\Microsoft OneDrive"
    mkdir "C:\Name1\Program Files\Microsoft Update Health Tools"
    mkdir "C:\Name1\Program Files\ModifiableWindowsApps"
    mkdir "C:\Name1\Program Files\MSBuild"
    mkdir "C:\Name1\Program Files\NVIDIA Corporation"
    mkdir "C:\Name1\Program Files\Oracle"
    mkdir "C:\Name1\Program Files\Parsec"
    mkdir "C:\Name1\Program Files\Parsec Virtual Display Driver"
    mkdir "C:\Name1\Program Files\Parsec Virtual USB Adapter Driver"
    mkdir "C:\Name1\Program Files\Razer"
    mkdir "C:\Name1\Program Files\Reference Assemblies"
    mkdir "C:\Name1\Program Files\Riot Vanguard"
    mkdir "C:\Name1\Program Files\RUXIM"
    mkdir "C:\Name1\Program Files\Windows Defender"
    mkdir "C:\Name1\Program Files\Windows Defender Advanced Threat Protection"
    mkdir "C:\Name1\Program Files\Windows Mail"
    mkdir "C:\Name1\Program Files\Windows Media Player"
    mkdir "C:\Name1\Program Files\Windows Multimedia Platform"
    mkdir "C:\Name1\Program Files\Windows NT"
    mkdir "C:\Name1\Program Files\Windows Photo Viewer"
    mkdir "C:\Name1\Program Files\Windows Portable Devices"
    mkdir "C:\Name1\Program Files\Windows Security"
    mkdir "C:\Name1\Program Files\WindowsPowerShell"
    mkdir "C:\Name1\Program Files\WinRAR"
    mkdir "C:\Name1\Program Files (x86)"
    mkdir "C:\Name1\Program Files (x86)\Common Files"
    mkdir "C:\Name1\Program Files (x86)\EasyAntiCheat_EOS"
    mkdir "C:\Name1\Program Files (x86)\Google"
    mkdir "C:\Name1\Program Files (x86)\Intel"
    mkdir "C:\Name1\Program Files (x86)\Internet Explorer"
    mkdir "C:\Name1\Program Files (x86)\Microsoft"
    mkdir "C:\Name1\Program Files (x86)\Microsoft.NET"
    mkdir "C:\Name1\Program Files (x86)\MSBuild"
    mkdir "C:\Name1\Program Files (x86)\MSI"
    mkdir "C:\Name1\Program Files (x86)\NVIDIA Corporation"
    mkdir "C:\Name1\Program Files (x86)\Razer"
    mkdir "C:\Name1\Program Files (x86)\Realtek"
    mkdir "C:\Name1\Program Files (x86)\Reference Assemblies"
    mkdir "C:\Name1\Program Files (x86)\Windows Defender"
    mkdir "C:\Name1\Program Files (x86)\Windows Mail"
    mkdir "C:\Name1\Program Files (x86)\Windows Media Player"
    mkdir "C:\Name1\Program Files (x86)\Windows Multimedia Platform"
    mkdir "C:\Name1\Program Files (x86)\Windows NT"
    mkdir "C:\Name1\Program Files (x86)\Windows Photo Viewer"
    mkdir "C:\Name1\Program Files (x86)\Windows Portable Devices"
    mkdir "C:\Name1\Program Files (x86)\WindowsPowerShell"
    mkdir "C:\Name1\Users"
    mkdir "C:\Name1\Users\Alex"
    mkdir "C:\Name1\Users\Public"
    mkdir "C:\Name1\Windows"
    mkdir "C:\Name1\Windows\addins"
    mkdir "C:\Name1\Windows\appcompat"
    mkdir "C:\Name1\Windows\apppatch"
    mkdir "C:\Name1\Windows\AppReadiness"
    mkdir "C:\Name1\Windows\assembly"
    mkdir "C:\Name1\Windows\bcastdvr"
    mkdir "C:\Name1\Windows\Boot"
    mkdir "C:\Name1\Windows\Branding"
    mkdir "C:\Name1\Windows\CbsTemp"
    mkdir "C:\Name1\Windows\Containers"
    mkdir "C:\Name1\Windows\CSC"
    mkdir "C:\Name1\Windows\Cursors"
    mkdir "C:\Name1\Windows\debug"
    mkdir "C:\Name1\Windows\diagnostics"
    mkdir "C:\Name1\Windows\DiagTrack"
    mkdir "C:\Name1\Windows\DigitalLocker"
    mkdir "C:\Name1\Windows\Downloaded Program Files"
    mkdir "C:\Name1\Windows\en-US"
    mkdir "C:\Name1\Windows\Fonts"
    mkdir "C:\Name1\Windows\GameBarPresenceWriter"
    mkdir "C:\Name1\Windows\Globalization"
    mkdir "C:\Name1\Windows\Help"
    mkdir "C:\Name1\Windows\IdentityCRL"
    mkdir "C:\Name1\Windows\IME"
    mkdir "C:\Name1\Windows\ImmersiveControlPanel"
    mkdir "C:\Name1\Windows\InboxApps"
    mkdir "C:\Name1\Windows\INF"
    mkdir "C:\Name1\Windows\InputMethod"
    mkdir "C:\Name1\Windows\L2Schemas"
    mkdir "C:\Name1\Windows\LiveKernelReports"
    mkdir "C:\Name1\Windows\Logs"
    mkdir "C:\Name1\Windows\Media"
    mkdir "C:\Name1\Windows\Microsoft.NET"
    mkdir "C:\Name1\Windows\Migration"
    mkdir "C:\Name1\Windows\ModemLogs"
    mkdir "C:\Name1\Windows\OCR"
    mkdir "C:\Name1\Windows\Offline Web Pages"
    mkdir "C:\Name1\Windows\Panther"
    mkdir "C:\Name1\Windows\Performance"
    mkdir "C:\Name1\Windows\PLA"
    mkdir "C:\Name1\Windows\PolicyDefinitions"
    mkdir "C:\Name1\Windows\Prefetch"
    mkdir "C:\Name1\Windows\PrintDialog"
    mkdir "C:\Name1\Windows\Provisioning"
    mkdir "C:\Name1\Windows\Registration"
    mkdir "C:\Name1\Windows\RemotePackages"
    mkdir "C:\Name1\Windows\rescache"
    mkdir "C:\Name1\Windows\Resources"
    mkdir "C:\Name1\Windows\ro-RO"
    mkdir "C:\Name1\Windows\SchCache"
    mkdir "C:\Name1\Windows\schemas"
    mkdir "C:\Name1\Windows\security"
    mkdir "C:\Name1\Windows\ServiceProfiles"
    mkdir "C:\Name1\Windows\ServiceState"
    mkdir "C:\Name1\Windows\servicing"
    mkdir "C:\Name1\Windows\Setup"
    mkdir "C:\Name1\Windows\ShellComponents"
    mkdir "C:\Name1\Windows\ShellExperiences"
    mkdir "C:\Name1\Windows\SKB"
    mkdir "C:\Name1\Windows\SoftwareDistribution"
    mkdir "C:\Name1\Windows\Speech"
    mkdir "C:\Name1\Windows\Speech_OneCore"
    mkdir "C:\Name1\Windows\System"
    mkdir "C:\Name1\Windows\System32"
    mkdir "C:\Name1\Windows\SystemApps"
    mkdir "C:\Name1\Windows\SystemResources"
    mkdir "C:\Name1\Windows\SystemTemp"
    mkdir "C:\Name1\Windows\SysWOW64"
    mkdir "C:\Name1\Windows\TAPI"
    mkdir "C:\Name1\Windows\Tasks"
    mkdir "C:\Name1\Windows\Temp"
    mkdir "C:\Name1\Windows\tracing"
    mkdir "C:\Name1\Windows\twain_32"
    mkdir "C:\Name1\Windows\Vss"
    mkdir "C:\Name1\Windows\WaaS"
    mkdir "C:\Name1\Windows\Web"
    mkdir "C:\Name1\Windows\WinSxS"
    mkdir "C:\Name1\XboxGames"
    mkdir "C:\Name1\XboxGames\GameSave"
    :: Set permissions for Name1 and Admin
    icacls "C:\Name1" /inheritance:r
    icacls "C:\Name1" /grant Name1:"(OI)(CI)F"
    icacls "C:\Name1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Name1"
    :: Set permissions for Name1 and Admin
    icacls "D:\Name1" /inheritance:r
    icacls "D:\Name1" /grant Name1:"(OI)(CI)F"
    icacls "D:\Name1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Name1"
    :: Set permissions for Name1 and Admin
    icacls "E:\Name1" /inheritance:r
    icacls "E:\Name1" /grant Name1:"(OI)(CI)F"
    icacls "E:\Name1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)
IF EXIST F: (
    mkdir "F:\Name1"
    :: Set permissions for Name1 and Admin
    icacls "F:\Name1" /inheritance:r
    icacls "F:\Name1" /grant Name1:"(OI)(CI)F"
    icacls "F:\Name1" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive F: not found. Skipping folder creation.
)

:: === Folder Setup for Name2 ===
IF EXIST C: (
    mkdir "C:\Name2"
    :: Set permissions for Name2 and Admin
    icacls "C:\Name2" /inheritance:r
    icacls "C:\Name2" /grant Name2:"(OI)(CI)F"
    icacls "C:\Name2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive C: not found. Skipping folder creation.
)
IF EXIST D: (
    mkdir "D:\Name2"
    mkdir "D:\Name2\EA"
    mkdir "D:\Name2\EA\Battlefield V"
    mkdir "D:\Name2\EA\EA SPORTS FC 25"
    mkdir "D:\Name2\Licenta"
    mkdir "D:\Name2\LOL"
    mkdir "D:\Name2\LOL\Riot Games"
    mkdir "D:\Name2\Metin2"
    mkdir "D:\Name2\Metin2\Janes"
    mkdir "D:\Name2\Metin2\Janes - Ninha"
    mkdir "D:\Name2\Program Files"
    mkdir "D:\Name2\Program Files\ModifiableWindowsApps"
    mkdir "D:\Name2\Steam"
    mkdir "D:\Name2\Steam\appcache"
    mkdir "D:\Name2\Steam\bin"
    mkdir "D:\Name2\Steam\clientui"
    mkdir "D:\Name2\Steam\config"
    mkdir "D:\Name2\Steam\controller_base"
    mkdir "D:\Name2\Steam\depotcache"
    mkdir "D:\Name2\Steam\dumps"
    mkdir "D:\Name2\Steam\friends"
    mkdir "D:\Name2\Steam\graphics"
    mkdir "D:\Name2\Steam\logs"
    mkdir "D:\Name2\Steam\package"
    mkdir "D:\Name2\Steam\public"
    mkdir "D:\Name2\Steam\resource"
    mkdir "D:\Name2\Steam\steam"
    mkdir "D:\Name2\Steam\steamapps"
    mkdir "D:\Name2\Steam\steamui"
    mkdir "D:\Name2\Steam\tenfoot"
    mkdir "D:\Name2\Steam\userdata"
    mkdir "D:\Name2\WindowsApps"
    mkdir "D:\Name2\WpSystem"
    mkdir "D:\Name2\WpSystem\S-1-5-21-2965706820-3364756290-1559334052-1001"
    mkdir "D:\Name2\XBOX"
    mkdir "D:\Name2\XBOX\Cities- Skylines II - PC Edition"
    :: Set permissions for Name2 and Admin
    icacls "D:\Name2" /inheritance:r
    icacls "D:\Name2" /grant Name2:"(OI)(CI)F"
    icacls "D:\Name2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive D: not found. Skipping folder creation.
)
IF EXIST E: (
    mkdir "E:\Name2"
    :: Set permissions for Name2 and Admin
    icacls "E:\Name2" /inheritance:r
    icacls "E:\Name2" /grant Name2:"(OI)(CI)F"
    icacls "E:\Name2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive E: not found. Skipping folder creation.
)
IF EXIST F: (
    mkdir "F:\Name2"
    :: Set permissions for Name2 and Admin
    icacls "F:\Name2" /inheritance:r
    icacls "F:\Name2" /grant Name2:"(OI)(CI)F"
    icacls "F:\Name2" /grant Admin:"(OI)(CI)F"
) ELSE (
    echo Drive F: not found. Skipping folder creation.
)


:: === Global App Folders Setup ===
IF EXIST C: (
    mkdir "C:\Apps"
    mkdir "C:\Apps\Steam"
    mkdir "C:\Apps\WinRar"
    mkdir "C:\Apps\NotePad"
    mkdir "C:\Apps\MozilaFirefox"
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
IF EXIST "C:\Apps\WinRar" (
    choco install winrar -y --ignore-checksums --params "/InstallDir=C:\Apps\WinRar"
) ELSE (
    echo Folder C:\Apps\WinRar not found. Skipping install for winrar.
)
IF EXIST "C:\Apps\NotePad" (
    choco install notepadplusplus -y --ignore-checksums --params "/InstallDir=C:\Apps\NotePad"
) ELSE (
    echo Folder C:\Apps\NotePad not found. Skipping install for notepadplusplus.
)
IF EXIST "C:\Apps\MozilaFirefox" (
    choco install Firefox -y --ignore-checksums --params "/InstallDir=C:\Apps\MozilaFirefox"
) ELSE (
    echo Folder C:\Apps\MozilaFirefox not found. Skipping install for Firefox.
)
shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f