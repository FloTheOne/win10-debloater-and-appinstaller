import json
from pathlib import Path

def generate_rename_cmd(old_name, new_name):
    return f"""
:: === Rename Current User ===
set MY_USER=%USERNAME%
echo Renaming current user {old_name} to {new_name}...
wmic useraccount where name="{old_name}" rename "{new_name}"
net user "{new_name}" /fullname:"{new_name}"
"""

def generate_user_cmd(username, password):
    runas_cmd = f'runas /user:{username} "cmd /c echo Profile initialized for {username}"'
    return f"""
:: === Create User: {username} ===
echo Creating user {username}...
net user "{username}" "{password}" /add
net localgroup Administrators "{username}" /add
timeout /t 1

:: === Trigger profile creation ===
{runas_cmd}
timeout /t 1

:: === Remove {username} from Administrators ===
net localgroup Administrators "{username}" /delete
"""

def generate_users_cmd_from_json(json_path: Path, output_cmd_path: Path):
    with open(json_path, "r", encoding="utf-8") as f:
        full_config = json.load(f)

    profile_data = full_config.get("profiles", {})
    profile_names = list(profile_data.keys())

    user_cmds = ["\n:: === User Creation Block ===", "SETLOCAL"]

    if profile_names:
        current_user_var = "%USERNAME%"
        first_profile = profile_names[0]
        rename_cmd = generate_rename_cmd(old_name=current_user_var, new_name=first_profile)
        user_cmds.append(rename_cmd.strip())

        for username in profile_names[1:]:
            info = profile_data.get(username, {})
            password = info.get("password", "Temp1234")
            cmd_block = generate_user_cmd(username, password)
            user_cmds.append(cmd_block.strip())

    user_cmds.append("ENDLOCAL")

    with open(output_cmd_path, "a", encoding="utf-8") as f:
        f.write("\n\n".join(user_cmds) + "\n")

    print(f"✅ Script generat în: {output_cmd_path}")

# === Entry point ===
if __name__ == "__main__":
    current_script_path = Path(__file__).resolve()
    root_dir = current_script_path.parent.parent
    json_file = root_dir / "preset_config.json"
    output_cmd = current_script_path.parent / "all_profiles.cmd"
    generate_users_cmd_from_json(json_file, output_cmd)
