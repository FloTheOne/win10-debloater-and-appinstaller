from pathlib import Path

def add_disable_background_apps_block(cmd_file_path: Path):
    if not cmd_file_path.exists():
        print(f"🔧 Creating new file: {cmd_file_path}")
        cmd_file_path.write_text("@echo off\n\n", encoding="utf-8")

    block = r"""
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
"""

    with open(cmd_file_path, "a", encoding="utf-8") as f:
        f.write(block)

    print(f"✅ Background apps block appended to: {cmd_file_path}")

# === Example usage ===
if __name__ == "__main__":
    target_file = Path(__file__).resolve().parent / "all_profiles.cmd"
    add_disable_background_apps_block(target_file)
