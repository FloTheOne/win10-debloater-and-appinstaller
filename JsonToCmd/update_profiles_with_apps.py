import json
from pathlib import Path

def generate_folder_creation_cmds(apps_structure):
    cmds = ["\n:: === Global App Folders Setup ==="]
    for folder in apps_structure:
        drive = folder["name"][0].upper() + ":"
        apps_root = f"{drive}\\Apps"
        cmds.append(f'IF EXIST {drive} (')
        cmds.append(f'    mkdir "{apps_root}"')
        cmds += generate_subfolders(folder.get("children", []), apps_root)
        cmds.append(') ELSE (')
        cmds.append(f'    echo Drive {drive} not found. Skipping folder creation.')
        cmds.append(')')
    return cmds

def generate_subfolders(children, parent_path):
    cmds = []
    for child in children:
        full_path = f"{parent_path}\\{child['name']}"
        cmds.append(f'    mkdir "{full_path}"')
        cmds += generate_subfolders(child.get("children", []), full_path)
    return cmds

def extract_choco_id(app_name):
    if "(" in app_name and ")" in app_name:
        return app_name.split("(")[-1].replace(")", "").strip()
    return app_name.strip()

def generate_app_install_cmds(apps_global):
    cmds = ["\n:: === Global App Install ==="]
    for app_name, path in apps_global.items():
        if not path[1:3] == ':\\':
            raise ValueError(f"Calea '{path}' din apps_global nu este validă. Trebuie să fie în forma X:\\...")

        choco_id = extract_choco_id(app_name)

        drive = path[0].upper() + ":"
        sub_path = Path(path[3:])  # elimină "X:\\"
        new_path = f"{drive}\\Apps\\{sub_path}"
        normalized_path = str(Path(new_path)).replace("/", "\\")

        cmds.append(f'IF EXIST "{normalized_path}" (')
        cmds.append(f'    choco install {choco_id} -y --ignore-checksums --params "/InstallDir={normalized_path}"')
        cmds.append(') ELSE (')
        cmds.append(f'    echo Folder {normalized_path} not found. Skipping install for {choco_id}.')
        cmds.append(')')
    cmds.append('shutdown /r /t 5 /c "System will restart in 5 seconds to apply changes." /f')
    return cmds

def append_global_apps_from_json(json_path: Path, cmd_path: Path):
    with open(json_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    apps_structure = config.get("apps_structure", [])
    apps_global = config.get("apps_global", {})

    folder_cmds = generate_folder_creation_cmds(apps_structure)
    install_cmds = generate_app_install_cmds(apps_global)

    with open(cmd_path, "a", encoding="utf-8") as f:
        f.write("\n\n" + "\n".join(folder_cmds + install_cmds))

    print(f"✅ {cmd_path.name} actualizat cu directoare în Apps\\ și comenzi de instalare aplicații.")


# === Entry point ===
if __name__ == "__main__":
    current_script_path = Path(__file__).resolve()
    script_dir = current_script_path.parent
    root_dir = script_dir.parent

    json_path = root_dir / "preset_config.json"
    cmd_path = script_dir / "all_profiles.cmd"

    append_global_apps_from_json(json_path, cmd_path)
