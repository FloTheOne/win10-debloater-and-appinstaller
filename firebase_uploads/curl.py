from firebase_uploads.firebase_setup import bucket
from datetime import timedelta
import requests


# Creează referința către fișierul urcat
blob = bucket.blob("all_profiles.cmd")

# Generează link semnat valabil 1 oră
signed_url = blob.generate_signed_url(expiration=timedelta(hours=1))

# Afișează comanda curl
print(f'curl -o install.cmd "{signed_url}"')



