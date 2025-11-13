from firebase_uploads.firebase_setup import bucket
from pathlib import Path

def upload_cmd_to_storage(local_path: Path, remote_path: str = None):
    if not local_path.exists():
        raise FileNotFoundError(f"❌ Fișierul nu există: {local_path}")

    blob_name = remote_path if remote_path else local_path.name
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(str(local_path))

    print(f"✅ Fișierul {blob_name} a fost urcat în Firebase Storage.")
    return blob.public_url  # sau .generate_signed_url() dacă vrei link temporar
