import json
from pathlib import Path

def generate_folder_commands(profile_name, folders, admin_name):
    cmds = [f"\n:: === Folder Setup for {profile_name} ==="]
    for folder in folders:
        root_drive = folder["name"][0].upper() + ":"
        base_path = f"{root_drive}\\{profile_name}"
        cmds.append(f'IF EXIST {root_drive} (')
        cmds.append(f'    mkdir "{base_path}"')
        cmds += generate_subfolders(folder.get("children", []), base_path)
        cmds.append(f'    :: Set permissions for {profile_name} and {admin_name}')
        cmds.append(f'    icacls "{base_path}" /inheritance:r')
        cmds.append(f'    icacls "{base_path}" /grant {profile_name}:"(OI)(CI)F"')
        if profile_name.lower() != admin_name.lower():
            cmds.append(f'    icacls "{base_path}" /grant {admin_name}:"(OI)(CI)F"')
        cmds.append(') ELSE (')
        cmds.append(f'    echo Drive {root_drive} not found. Skipping folder creation.')
        cmds.append(')')
    return cmds

def generate_subfolders(children, parent_path):
    cmds = []
    for child in children:
        full_path = Path(parent_path) / child["name"]
        cmds.append(f'    mkdir "{full_path}"')
        cmds += generate_subfolders(child.get("children", []), str(full_path))
    return cmds

def append_private_folders_from_json(json_path: Path, cmd_path: Path):
    with open(json_path, "r", encoding="utf-8") as f:
        full_config = json.load(f)

    profiles = full_config.get("profiles", {})
    profile_names = list(profiles.keys())
    admin_name = profile_names[0] if profile_names else "admin"

    new_lines = []
    for profile_name, config in profiles.items():
        folder_cmds = generate_folder_commands(profile_name, config.get("folders", []), admin_name)
        new_lines.extend(folder_cmds)

    with open(cmd_path, "a", encoding="utf-8") as f:
        f.write("\n\n" + "\n".join(new_lines))

    print(f"✅ Fișierul {cmd_path.name} a fost actualizat cu permisiuni private pentru utilizator + admin.")

# === Entry point ===
if __name__ == "__main__":
    current_script_path = Path(__file__).resolve()
    script_dir = current_script_path.parent
    root_dir = script_dir.parent

    json_path = root_dir / "preset_config.json"
    cmd_path = script_dir / "all_profiles.cmd"

    append_private_folders_from_json(json_path, cmd_path)
