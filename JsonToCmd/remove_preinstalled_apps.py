from pathlib import Path


def add_bulk_app_removal_script(cmd_file_path: Path):
    if not cmd_file_path.exists():
        print(f"❌ File not found: {cmd_file_path}")
        return

    powershell_script = r'''
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

'''

    content = cmd_file_path.read_text(encoding="utf-8")
    if powershell_script.strip() not in content:
        with open(cmd_file_path, "a", encoding="utf-8") as f:
            f.write("\n" + powershell_script)
        print(f"✅ PowerShell UWP removal block added to: {cmd_file_path}")
    else:
        print(f"ℹ️ PowerShell block already exists in: {cmd_file_path}")

# === Main entry point ===
if __name__ == "__main__":
    script_path = Path(__file__).resolve().parent / "all_profiles.cmd"  # ajustează dacă e în alt folder
    add_bulk_app_removal_script(script_path)
