import json
from firebase_uploads.firebase_setup import db
from datetime import datetime

def upload_preset_json_without_password(preset_name: str, json_data: dict):
    """
    Trimite JSON-ul presetului fără câmpul 'preset_password' în colecția 'presets'.
    """
    doc_ref = db.collection("presets").document(preset_name)
    doc_ref.set(json_data)
    print(f"✅ Preset '{preset_name}' (fără parolă) încărcat în Firestore -> presets/{preset_name}")


def upload_preset_password(preset_name: str, password: str):
    """
    Trimite parola + data/ora în colecția 'presets_name'.
    """
    timestamp = datetime.utcnow().isoformat() + "Z"  # ex: "2024-06-10T20:22:45Z"
    doc_ref = db.collection("presets_name").document(preset_name)
    doc_ref.set({
        "password": password,
        "created_at": timestamp
    })
    print(f"✅ Presetul '{preset_name}' salvat cu parolă și timestamp în Firestore.")