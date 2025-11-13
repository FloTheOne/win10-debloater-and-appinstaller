from pathlib import Path


def add_high_performance_block(file_path: Path):
    block = r"""
:: === Set High Performance Power Plan ===
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
"""
    content = file_path.read_text(encoding="utf-8")
    if block.strip() not in content:
        with open(file_path, "a", encoding="utf-8") as f:
            f.write(block)
        print(f"✅ High Performance block added to: {file_path}")
    else:
        print(f"ℹ️ High Performance block already exists in: {file_path}")

# === Main Execution ===
if __name__ == "__main__":
    script_path = Path(__file__).resolve().parent / "all_profiles.cmd"
    add_high_performance_block(script_path)

