from pathlib import Path

def add_disable_bing_search_block(cmd_file_path: Path):
    if not cmd_file_path.exists():
        print(f"❌ File not found: {cmd_file_path}")
        return

    block = r"""
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

"""

    content = cmd_file_path.read_text(encoding="utf-8")
    if block.strip() not in content:
        with open(cmd_file_path, "a", encoding="utf-8") as f:
            f.write("\n" + block.strip() + "\n")
        print(f"✅ Bing Search + Start Ads disable block added to: {cmd_file_path}")
    else:
        print(f"ℹ️ Bing Search block already exists in: {cmd_file_path}")


# === Run update on all_profiles.cmd ===
if __name__ == "__main__":
    script_path = Path(__file__).resolve().parent / "all_profiles.cmd"
    add_disable_bing_search_block(script_path)
