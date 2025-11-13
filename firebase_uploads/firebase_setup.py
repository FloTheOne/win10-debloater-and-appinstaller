import firebase_admin
from firebase_admin import credentials, firestore, storage
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
cred_path = os.path.join(BASE_DIR, "IDSTORAGE")
cred = credentials.Certificate(cred_path)

firebase_admin.initialize_app(cred, {
    "storageBucket": "IDSTORAGE"  # <-- înlocuiește cu ID-ul tău corect
})

db = firestore.client()
bucket = storage.bucket()
