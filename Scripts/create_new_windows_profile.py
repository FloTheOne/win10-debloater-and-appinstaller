import tkinter as tk
from tkinter import ttk, messagebox

def generate_create_user_cmd(username, password, group="Users", filename="create_user.cmd"):
    if not username or not password:
        messagebox.showerror("Input Error", "Username and password are required.")
        return

    cmd_content = f"""@echo off
SETLOCAL

:: === Configuration ===
set "USERNAME={username}"
set "PASSWORD={password}"
set "GROUP={group}"

:: === Create User ===
echo Creating user %USERNAME%...
net user "%USERNAME%" "%PASSWORD%" /add
if %errorlevel% neq 0 (
    echo Failed to create user. Make sure you run this as administrator.
    goto :eof
)

:: === Add to group ===
echo Adding %USERNAME% to group %GROUP%...
net localgroup "%GROUP%" "%USERNAME%" /add
if %errorlevel% neq 0 (
    echo Failed to add user to group.
    goto :eof
)

echo User %USERNAME% created and added to %GROUP% successfully.
ENDLOCAL
pause
"""
    with open(filename, "w") as f:
        f.write(cmd_content)

    messagebox.showinfo("Success", f"Script saved as '{filename}'")

def create_gui():
    root = tk.Tk()
    root.title("Create User CMD Generator")
    root.geometry("300x200")

    # Username
    ttk.Label(root, text="Username:").pack(pady=(10, 0))
    username_entry = ttk.Entry(root)
    username_entry.pack(pady=5)

    # Password
    ttk.Label(root, text="Password:").pack(pady=(10, 0))
    password_entry = ttk.Entry(root, show="*")
    password_entry.pack(pady=5)

    # Generate Button
    def on_generate():
        username = username_entry.get().strip()
        password = password_entry.get().strip()
        generate_create_user_cmd(username, password)

    ttk.Button(root, text="Generate CMD Script", command=on_generate).pack(pady=15)

    root.mainloop()

if __name__ == "__main__":
    create_gui()
