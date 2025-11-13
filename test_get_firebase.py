from firebase_uploads.firebase_setup import db

def get_and_display_preset():
    # === 1. Listează toate preseturile existente
    presets = db.collection("presets").stream()
    preset_names = []

    print("📋 Preseturi disponibile:")
    for doc in presets:
        preset_names.append(doc.id)
        print(f" - {doc.id}")

    if not preset_names:
        print("⚠️ Nu există preseturi salvate.")
        return

    # === 2. Alege unul
    selected = input("🔍 Introdu numele presetului pe care vrei să-l accesezi: ").strip()
    if selected not in preset_names:
        print("❌ Presetul nu există.")
        return

    # === 3. Obține documentul complet
    doc = db.collection("presets").document(selected).get()
    if not doc.exists:
        print("❌ Eroare: presetul nu a fost găsit.")
        return

    data = doc.to_dict()
    preset_password = data.get("preset_password", "")

    # === 4. Verifică parola
    if preset_password:
        user_password = input("🔐 Introdu parola presetului: ").strip()
        if user_password != preset_password:
            print("❌ Parolă incorectă.")
            return

    # === 5. Afișează structura presetului
    import json
    print("\n✅ Structura presetului:")
    print(json.dumps(data, indent=2))


# Apel
if __name__ == "__main__":
    get_and_display_preset()
