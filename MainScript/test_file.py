import os
import ctypes
import sys

def is_hidden(filepath):
    if sys.platform == "win32":
        try:
            attrs = ctypes.windll.kernel32.GetFileAttributesW(str(filepath))
            if attrs == -1:
                return False
            return bool(attrs & 0x02)
        except Exception:
            return False
    return False

def add_folders_recursively(path, depth, max_depth):
    if depth >= max_depth:
        return []

    result = []
    try:
        for entry in os.listdir(path):
            if entry in ["$RECYCLE.BIN", "System Volume Information"]:
                continue

            full_path = os.path.join(path, entry)
            if not os.path.isdir(full_path) or is_hidden(full_path):
                continue

            children = add_folders_recursively(full_path, depth + 1, max_depth)
            result.append({
                "name": entry,
                "children": children
            })
    except Exception as e:
        print(f"⚠️ Eroare la citirea {path}: {e}")

    return result

def print_structure(structure, indent=0):
    for item in structure:
        print(" " * indent + f"- {item['name']}")
        print_structure(item['children'], indent + 2)

if __name__ == "__main__":
    # Exemplu de utilizare
    base_path = "E:\\"  # Poți schimba în orice cale validă
    max_depth = 1      # Numărul de nivele de adâncime

    print(f"🔍 Scanare structură în: {base_path} (max_depth={max_depth})\n")
    folder_tree = add_folders_recursively(base_path, 0, max_depth)
    print_structure(folder_tree)
