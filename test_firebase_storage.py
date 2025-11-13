from firebase_uploads.firebase_setup import bucket

# Path către fișierul real pe disc
local_path = "JsonToCmd/all_profiles.cmd"  # sau cu backslash: "JsonToCmd\\all_profiles.cmd"

# Numele fișierului în Firebase Storage
remote_path = "all_profiles.cmd"

# Upload efectiv
blob = bucket.blob(remote_path)
blob.upload_from_filename(local_path)

print("✅ Fișier .cmd urcat cu succes în Firebase Storage")


