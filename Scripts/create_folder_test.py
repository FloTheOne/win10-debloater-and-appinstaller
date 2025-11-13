import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import os
import string
import pprint

class FolderBuilderApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Folder Structure Builder")

        self.structure = {}
        self.path_stack = []

        self.build_ui()

    def build_ui(self):
        # Disk selector
        self.disk_label = ttk.Label(self.root, text="Select Disk:")
        self.disk_label.pack()

        self.disk_combo = ttk.Combobox(self.root, values=self.get_available_drives())
        self.disk_combo.pack()

        # Current path display
        self.path_label = ttk.Label(self.root, text="Current Path: /")
        self.path_label.pack()

        # Buttons
        self.add_button = ttk.Button(self.root, text="Add Folder", command=self.add_folder)
        self.add_button.pack(pady=5)

        self.back_button = ttk.Button(self.root, text="Go Up", command=self.go_up)
        self.back_button.pack(pady=5)

        self.generate_button = ttk.Button(self.root, text="Create CMD", command=self.generate_cmd)
        self.generate_button.pack(pady=10)

        self.print_button = ttk.Button(self.root, text="Print Config", command=self.print_config)
        self.print_button.pack(pady=5)

        self.load_button = ttk.Button(self.root, text="Load Existing Disk Structure", command=self.load_existing_structure)
        self.load_button.pack(pady=5)

    def get_available_drives(self):
        drives = []
        for letter in string.ascii_uppercase:
            if os.path.exists(f"{letter}:\\"):
                drives.append(f"{letter}:")
        return drives

    def get_current_node(self):
        node = self.structure
        for folder in self.path_stack:
            node = node.setdefault(folder, {})
        return node

    def update_path_label(self):
        if self.path_stack:
            path = "\\".join(self.path_stack)
            self.path_label.config(text=f"Current Path: {path}")
        else:
            disk = self.disk_combo.get()
            self.path_label.config(text=f"Current Path: {disk}\\" if disk else "Current Path: /")

    def add_folder(self):
        folder_name = simpledialog.askstring("Folder Name", "Enter folder name:")
        if not folder_name:
            return

        disk = self.disk_combo.get()
        if not disk:
            messagebox.showerror("Error", "Please select a disk first.")
            return

        if not self.structure:
            self.structure[disk] = {}

        if not self.path_stack:
            self.path_stack.append(disk)

        node = self.get_current_node()
        node[folder_name] = {}
        self.path_stack.append(folder_name)
        self.update_path_label()

    def go_up(self):
        if self.path_stack:
            self.path_stack.pop()
            self.update_path_label()

    def generate_cmd(self):
        disk = self.disk_combo.get()
        if not disk:
            messagebox.showerror("Error", "Please select a disk.")
            return

        folder_paths = []

        def traverse(path_list, subtree):
            current_path = "\\".join(path_list)
            if current_path:
                folder_paths.append(current_path)
            for subfolder in subtree:
                traverse(path_list + [subfolder], subtree[subfolder])

        if disk in self.structure:
            traverse([disk], self.structure[disk])

        # Save CMD
        with open("create_folders.cmd", "w") as f:
            f.write("@echo off\n")
            f.write(f"cd /d {disk}\n")
            for path in folder_paths:
                relative_path = path[len(disk) + 1:]  # remove "D:\"
                f.write(f"mkdir \"{relative_path}\"\n")

        messagebox.showinfo("Success", "CMD script saved as 'create_folders.cmd'!")

    def get_current_configuration(self):
        disk = self.disk_combo.get()
        if not disk or disk not in self.structure:
            return {}
        return {disk: self.structure[disk]}

    def print_config(self):
        pprint.pprint(self.get_current_configuration())

    def get_existing_disk_structure(self, root_path, max_depth=5):
        def build_tree(path, depth):
            if depth == 0:
                return {}
            tree = {}
            try:
                for entry in os.scandir(path):
                    if entry.is_dir(follow_symlinks=False):  # DOAR directoare
                        tree[entry.name] = build_tree(os.path.join(path, entry.name), depth - 1)
            except (PermissionError, FileNotFoundError):
                pass
            return tree

        return build_tree(root_path, max_depth)


    def load_existing_structure(self):
        disk = self.disk_combo.get()
        if not disk:
            messagebox.showerror("Error", "Please select a disk.")
            return

        full_path = f"{disk}\\"
        self.structure[disk] = self.get_existing_disk_structure(full_path, max_depth=5)
        self.path_stack = [disk]
        self.update_path_label()
        messagebox.showinfo("Done", f"Loaded folder structure from {disk}\\")

if __name__ == "__main__":
    root = tk.Tk()
    app = FolderBuilderApp(root)
    root.mainloop()
