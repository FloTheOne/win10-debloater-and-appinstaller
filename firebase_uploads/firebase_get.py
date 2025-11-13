from firebase_uploads.firebase_setup import db
from firebase_uploads.firebase_setup import bucket
import datetime

def get_latest_public_presets(limit=10):
    docs = (
        db.collection("presets_name")
        .where("password", "==", "")
        .order_by("created_at", direction="DESCENDING")
        .limit(limit)
        .stream()
    )
    return [doc.id for doc in docs]  # doar numele

def get_preset_json(preset_name: str):
    doc = db.collection("presets").document(preset_name).get()
    if doc.exists:
        return doc.to_dict()
    return None

def search_presets_by_name(search_text: str):
    docs = (
        db.collection("presets_name")
        .where("password", "==", "")
        .order_by("created_at", direction="DESCENDING")
        .limit(30)  # mai multe ca să putem filtra local
        .stream()
    )

    return [
        doc.id for doc in docs
        if search_text.lower() in doc.id.lower()
    ]

def search_all_presets_by_name(search_text: str, limit=30):
    """
    Caută preseturi după nume, fără filtru pe parolă.
    Returnează preset_name-uri care conțin textul căutat.
    """
    docs = (
        db.collection("presets_name")
        .order_by("created_at", direction="DESCENDING")
        .limit(limit)
        .stream()
    )

    return [
        doc.id for doc in docs
        if search_text.lower() in doc.id.lower()
    ]

def download_cmd_file(preset_name: str, destination_path: str):
    """
    Descarcă fișierul .cmd corespunzător presetului din Firebase Storage.
    """
    remote_path = f"{preset_name}.cmd"
    blob = bucket.blob(remote_path)
    blob.download_to_filename(destination_path)
    print(f"✅ {remote_path} a fost descărcat în {destination_path}")

def get_signed_cmd_url(preset_name: str, expiration_minutes: int = 60) -> str:
    blob = bucket.blob(f"{preset_name}.cmd")

    url = blob.generate_signed_url(
        version="v4",
        expiration=datetime.timedelta(minutes=expiration_minutes),
        method="GET"
    )
    return url

def preset_exists_in_firestore(preset_name: str) -> bool:
    """
    Returnează True dacă documentul cu numele presetului există în colecția 'presets_name'.
    """
    doc_ref = db.collection("presets_name").document(preset_name)
    return doc_ref.get().exists

