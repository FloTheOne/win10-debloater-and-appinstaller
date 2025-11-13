from PyQt6.QtWidgets import QWidget, QMessageBox
from UI.previewPage import Ui_Form
import json
import threading
from pathlib import Path
from PyQt6 import QtWidgets
from firebase_uploads.firebase_upload import upload_preset_json_without_password, upload_preset_password
from MainScript.create_cmd import generate_full_cmd_script


class PreviewPage(QWidget):
    def __init__(self, project_context):
        super().__init__()
        self.ui = Ui_Form()
        self.ui.setupUi(self)

        self.context = project_context
        self.data = self.context.get_all()

        # Build preview content
        self.populate_preview()

        # Connect save button
        self.ui.saveButton.clicked.connect(self.save_config)

    def populate_preview(self):
        # === Nume și parolă preset
        self.ui.presetNameLabel.setText(f"Preset: {self.context.get_preset_name()}")
        password = self.context.get_preset_password()
        self.ui.presetPasswordLabel.setText(f"Password: {password if password else '—'}")

        # === Lista aplicațiilor
        self.ui.appList.clear()
        for app_name in self.context.get_apps_global().keys():
            self.ui.appList.addItem(app_name)

        # === Lista optimizărilor
        self.ui.optimList.clear()
        for opt in self.context.get_optimizations_global():
            self.ui.optimList.addItem(opt)

        # === Selector profil + parole
        self.ui.profileSelector.blockSignals(True)  # evită declanșarea prematură
        self.ui.profileSelector.clear()
        self.profile_data = self.context.get_all()  # {"profil": {"folders": [...]}, ...}

        for profile in self.context.get_profiles().keys():
            self.ui.profileSelector.addItem(profile)
        self.ui.profileSelector.blockSignals(False)

        # === Legare logică și afișare pentru primul profil
        self.ui.profileSelector.currentTextChanged.connect(self.update_folder_view)

        first_profile = self.ui.profileSelector.currentText()
        if first_profile:
            self.update_folder_view(first_profile)

        # === Path general aplicații
        self.ui.pathDisplay.setText("Structură aplicații detectată.")


    def update_folder_view(self, profile_name):
        if not profile_name:
            return

        folders = self.context.get_profile_data(profile_name).get("folders", [])
        password = self.context.get_profiles().get(profile_name, "")
        self.ui.folderTree.itemClicked.connect(self.update_path_display)

        self.ui.profilePasswordLabel.setText(f"Parolă: {password}")
        self.ui.folderTree.clear()

        def add_items(parent, children):
            for child in children:
                item = QtWidgets.QTreeWidgetItem([child["name"]])
                parent.addChild(item)
                add_items(item, child.get("children", []))

        for folder in folders:
            top_item = QtWidgets.QTreeWidgetItem([folder["name"]])
            self.ui.folderTree.addTopLevelItem(top_item)
            add_items(top_item, folder.get("children", []))

    def update_path_display(self, item):
        parts = []
        while item:
            parts.insert(0, item.text(0))
            item = item.parent()
        full_path = "\\".join(parts)
        self.ui.pathDisplay.setText(full_path)

    def save_config(self):
        try:
            preset_name = self.context.preset_name
            preset_password = self.context.preset_password

            full_json = {
                "preset_name": preset_name,
                "preset_password": preset_password,
                "profiles": {
                    name: {
                        "password": self.context.profiles[name],
                        "folders": self.data[name]["folders"]
                    } for name in self.context.profiles
                },
                "apps_structure": self.context.get_apps_structure(),
                "apps_global": self.context.get_apps_global(),
                "optimizations_global": self.context.get_optimizations_global()
            }

            json_no_password = full_json.copy()
            json_no_password.pop("preset_password")

            # === Salvare locală ===
            local_json_dir = Path("created_files/Json")
            local_json_dir.mkdir(parents=True, exist_ok=True)
            json_path = local_json_dir / f"{preset_name}.json"
            with open(json_path, "w", encoding="utf-8") as f:
                json.dump(full_json, f, indent=4)

            cmd_output_path = Path("created_files/cmds") / f"{preset_name}.cmd"

            # === Threading ===
            t1 = threading.Thread(target=upload_preset_json_without_password, args=(preset_name, json_no_password))
            t2 = threading.Thread(target=upload_preset_password, args=(preset_name, preset_password))
            t3 = threading.Thread(target=generate_full_cmd_script, args=(json_path, cmd_output_path))
            t1.start()
            t2.start()
            t3.start()

            QMessageBox.information(self, "Success", f"Config '{preset_name}' saved and uploaded to Firebase!")

        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to save config: {str(e)}")