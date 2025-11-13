from PyQt6.QtWidgets import QDialog, QVBoxLayout, QLabel, QLineEdit, QPushButton
from firebase_uploads.firebase_get import get_signed_cmd_url

class CurlLinkDialog(QDialog):
    def __init__(self, preset_name: str, parent=None):
        super().__init__(parent)
        self.setWindowTitle("CURL Link")

        layout = QVBoxLayout()
        label = QLabel("Use this curl command to download the .cmd:")
        url = get_signed_cmd_url(preset_name)
        curl = f'curl -o {preset_name}.cmd "{url}"'

        self.curlField = QLineEdit(curl)
        self.curlField.setReadOnly(True)

        copy_button = QPushButton("Copy to Clipboard")
        copy_button.clicked.connect(lambda: self.copy_to_clipboard(curl))

        layout.addWidget(label)
        layout.addWidget(self.curlField)
        layout.addWidget(copy_button)
        self.setLayout(layout)

    def copy_to_clipboard(self, text):
        from PyQt6.QtGui import QGuiApplication
        QGuiApplication.clipboard().setText(text)
