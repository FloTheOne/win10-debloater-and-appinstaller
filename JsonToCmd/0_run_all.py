import subprocess
from pathlib import Path

def run_all_scripts():
    base_dir = Path(__file__).resolve().parent
    ordered_scripts = [
        "1_create_choco.py",
        "2_telemetry_off.py",
        "3_power_high.py",
        "4_remove_background_apps.py",
        "5_remove_bing_search_taskbar.py",
        "6_remove_preinstalled_apps.py",
        "7_generate_user.py",
        "8_update_profile_with_folders.py",
        "9_update_profiles_with_apps.py"
    ]

    for script_name in ordered_scripts:
        script_path = base_dir / script_name
        if script_path.exists():
            print(f"▶ Running: {script_name}")
            result = subprocess.run(["python", str(script_path)], shell=True)
            if result.returncode != 0:
                print(f"❌ Error running {script_name}")
                break
        else:
            print(f"⚠️ Not found: {script_name}")

if __name__ == "__main__":
    run_all_scripts()
