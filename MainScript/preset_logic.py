from PyQt6.QtWidgets import QWidget, QMessageBox
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QStandardItemModel, QStandardItem
from PyQt6 import QtWidgets

from UI.presetPage import Ui_Form
from MainScript.folder_logic import FolderLogic
from Objects.project_context import ProjectContext
from firebase_uploads.firebase_get import preset_exists_in_firestore
import re
from UI.areYouSure import Ui_Form as ConfirmUi

class PresetForm(QWidget):
    

    def __init__(self, project_context):
        super().__init__()
        self.context = project_context
        self.ui = Ui_Form()
        self.ui.setupUi(self)

        self.profile_data = {}
        self.model = QStandardItemModel()
        self.ui.profilesList.setModel(self.model)

        self.ui.addFolderButton.clicked.connect(self.add_profile)
        self.ui.removeButton.clicked.connect(self.remove_selected_profile)
        self.ui.cancelButton.clicked.connect(self.confirm_cancel)
        self.ui.nextButton.clicked.connect(self.go_to_next)
        self.ui.lockButton.clicked.connect(self.toggle_admin_lock)

        self.admin_locked = False
        self.admin_name = None

        self.last_checked_name = ""
        self.preset_check_timer = QTimer()
        self.preset_check_timer.setInterval(1000)
        self.preset_check_timer.setSingleShot(True)
        self.preset_check_timer.timeout.connect(self.verify_unique_preset_name)

        self.ui.presetNameEdit.textChanged.connect(self.schedule_preset_check)

    def is_valid_name(self, text):
        return bool(re.fullmatch(r"[A-Za-z0-9]{3,}", text))

    def schedule_preset_check(self):
        self.preset_check_timer.start()

    def verify_unique_preset_name(self):
        name = self.ui.presetNameEdit.text().strip()
        if not self.is_valid_name(name):
            self.ui.presetStatusLabel.setText("❌")
            self.ui.presetStatusLabel.setStyleSheet("color: red;")
            self.ui.nextButton.setEnabled(False)
            return

        if name != self.last_checked_name:
            exists = preset_exists_in_firestore(name)
            self.last_checked_name = name
            if exists:
                self.ui.presetStatusLabel.setText("❌")
                self.ui.presetStatusLabel.setStyleSheet("color: red;")
                self.ui.nextButton.setEnabled(False)
            else:
                self.ui.presetStatusLabel.setText("✅")
                self.ui.presetStatusLabel.setStyleSheet("color: green;")
                self.ui.nextButton.setEnabled(True)

    def add_profile(self):
        profile_name = self.ui.profileNameEdit.text().strip()
        password = self.ui.profilePassEdit.text().strip()

        if not self.is_valid_name(profile_name):
            QMessageBox.warning(self, "Warning", "Numele profilului trebuie să conțină doar litere sau cifre și să aibă cel puțin 3 caractere!")
            return

        if not self.is_valid_name(password):
            QMessageBox.warning(self, "Warning", "Parola trebuie să conțină doar litere sau cifre și să aibă cel puțin 3 caractere!")
            return

        if profile_name in self.profile_data:
            QMessageBox.warning(self, "Warning", f"Profilul '{profile_name}' există deja în listă!")
            return

        self.profile_data[profile_name] = password
        item = QStandardItem(profile_name)
        item.setToolTip(f'Pass: "{password}"')
        self.model.appendRow(item)

        self.ui.profileNameEdit.clear()
        self.ui.profilePassEdit.clear()

    def load_from_context(self):
        # === Nume preset și parolă
        self.ui.presetNameEdit.setText(self.context.get_preset_name())
        self.ui.presetPasswordEdit.setText(self.context.get_preset_password())

        # === Profiluri
        self.profile_data = self.context.get_profiles()
        self.model.clear()

        for name, password in self.profile_data.items():
            item = QStandardItem(name)
            item.setToolTip(f'Pass: "{password}"')
            self.model.appendRow(item)

        # === Setează automat primul profil ca administrator
        if self.profile_data:
            first_profile = next(iter(self.profile_data))
            self.set_admin_lock(first_profile)

    def remove_selected_profile(self):
        selected_indexes = self.ui.profilesList.selectedIndexes()
        if selected_indexes:
            for index in sorted(selected_indexes, reverse=True):
                key = self.model.item(index.row()).text()
                self.profile_data.pop(key)
                self.model.removeRow(index.row())
                if key == self.admin_name:
                    self.admin_locked = False
                    self.admin_name = None
                    self.ui.adminProfileEdit.setReadOnly(False)
                    self.ui.lockButton.setText("Lock")
        else:
            QMessageBox.information(self, "Info", "Selectează un profil de șters.")

    def go_to_next(self):
        preset_name = self.ui.presetNameEdit.text().strip()
        preset_password = self.ui.presetPasswordEdit.text().strip()

        if not self.is_valid_name(preset_name):
            QMessageBox.warning(self, "Warning", "Introduceți un nume valid pentru preset (minim 3 caractere, doar litere și cifre)!")
            return

        if self.ui.presetStatusLabel.text().strip() != "✅":
            QMessageBox.warning(self, "Warning", "Numele presetului există deja sau este invalid. Alegeți altul!")
            return

        if not self.profile_data:
            QMessageBox.warning(self, "Warning", "Adăugați cel puțin un profil!")
            return

        for profile, password in self.profile_data.items():
            if profile != self.admin_name and not self.is_valid_name(password):
                QMessageBox.warning(self, "Warning", f"Parola profilului '{profile}' nu este validă.")
                return

        context = ProjectContext(
            profile_data=self.profile_data,
            preset_name=preset_name,
            preset_password=preset_password
        )

        self.nextWindow = FolderLogic(project_context=context)
        self.nextWindow.show()
        self.close()

    def confirm_cancel(self):
        dialog = QtWidgets.QDialog(self)
        confirm_ui = ConfirmUi()
        confirm_ui.setupUi(dialog)

        confirm_ui.yesButton.clicked.connect(dialog.accept)
        confirm_ui.NoButton.clicked.connect(dialog.reject)

        if dialog.exec():
            self.close()


    def toggle_admin_lock(self):
        name = self.ui.adminProfileEdit.text().strip()

        if not self.admin_locked:
            if not self.is_valid_name(name):
                QMessageBox.warning(self, "Warning", "Numele administratorului trebuie să fie valid (minim 3 caractere, doar litere și cifre)!")
                return

            self.ui.adminProfileEdit.setReadOnly(True)
            self.ui.lockButton.setText("Unlock")

            # Adaugă în profile_data doar dacă nu e deja
            if name not in self.profile_data:
                self.profile_data[name] = ""

            # Verifică dacă deja există în model, și îl elimină ca să-l pună primul
            for i in range(self.model.rowCount()):
                if self.model.item(i).text() == name:
                    self.model.removeRow(i)
                    break

            item = QStandardItem(name)
            item.setToolTip(f'Pass: "{self.profile_data[name]}"')
            self.model.insertRow(0, item)  # ← Inserează pe prima poziție

            self.admin_locked = True
            self.admin_name = name
        else:
            self.ui.adminProfileEdit.setReadOnly(False)
            self.ui.lockButton.setText("Lock")

            if name in self.profile_data:
                self.profile_data.pop(name)

            for i in range(self.model.rowCount()):
                if self.model.item(i).text() == name:
                    self.model.removeRow(i)
                    break

            self.admin_locked = False
            self.admin_name = None
    
    def set_admin_lock(self, name: str):
        self.admin_name = name
        self.admin_locked = True
        self.ui.adminProfileEdit.setText(name)
        self.ui.adminProfileEdit.setReadOnly(True)
        self.ui.lockButton.setText("Unlock")

