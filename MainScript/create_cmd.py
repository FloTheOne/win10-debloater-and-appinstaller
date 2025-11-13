from pathlib import Path
import json

from JsonToCmd.create_choco import write_choco_block_to_file
from JsonToCmd.generate_user import generate_users_cmd_from_json
from JsonToCmd.update_profile_with_folders import append_private_folders_from_json
from JsonToCmd.update_profiles_with_apps import append_global_apps_from_json
from JsonToCmd.telemetry_off import append_local_optimizations_block, append_global_telemetry_block
from JsonToCmd.power_high import add_high_performance_block
from JsonToCmd.remove_background_apps import add_disable_background_apps_block
from JsonToCmd.remove_bing_search_taskbar import add_disable_bing_search_block
from JsonToCmd.remove_preinstalled_apps import add_bulk_app_removal_script
from firebase_uploads.firebase_storage_upload import upload_cmd_to_storage

def generate_full_cmd_script(json_path: Path, output_cmd_path: Path):
    output_cmd_path.parent.mkdir(parents=True, exist_ok=True)

    # 1. Creează fișierul cu Chocolatey + verificare admin
    write_choco_block_to_file(output_cmd_path)

    # 2. Încarcă jsonul presetului
    with open(json_path, "r", encoding="utf-8") as f:
        full_config = json.load(f)

    optim_list = full_config.get("optimizations_global", [])

    # (opțional) validare
    ALLOWED_OPTIMIZATIONS = {
        "Disable Telemetry",
        "Enable High Performance Mode",
        "Disable Background Apps",
        "Disable Bing Search & Ads",
        "Remove Preinstalled Apps"
    }
    for opt in optim_list:
        if opt not in ALLOWED_OPTIMIZATIONS:
            raise ValueError(f"Unknown optimization option: {opt}")

    # 3. Adaugă optimizări doar dacă sunt bifate
    if "Disable Telemetry" in optim_list:
        append_local_optimizations_block(output_cmd_path)
        append_global_telemetry_block(output_cmd_path)

    if "Enable High Performance Mode" in optim_list:
        add_high_performance_block(output_cmd_path)

    if "Disable Background Apps" in optim_list:
        add_disable_background_apps_block(output_cmd_path)

    if "Disable Bing Search & Ads" in optim_list:
        add_disable_bing_search_block(output_cmd_path)

    if "Remove Preinstalled Apps" in optim_list:
        add_bulk_app_removal_script(output_cmd_path)

    # 4. Secțiuni logice (users, folders, apps)
    generate_users_cmd_from_json(json_path, output_cmd_path)
    append_private_folders_from_json(json_path, output_cmd_path)
    append_global_apps_from_json(json_path, output_cmd_path)

    upload_cmd_to_storage(output_cmd_path)

    print(f"✅ Script complet generat la: {output_cmd_path}")
