from PyQt6 import QtCore, QtWidgets, QtGui
import sys

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(800, 450)

        Form.setStyleSheet("""
    QWidget {
        background-color: #66A5AD;
        color: #002629;
        font-family: Segoe UI, Arial;
        font-size: 14px;
    }

    QLineEdit, QListView {
        border: 1px solid #e1ebf0;
        border-radius: 5px;
        padding: 6px;
        background-color: #e1ebf0;
        color: #002629;
    }

    QPushButton {
        background-color: #e1ebf0;
        color: #002629;
        border: none;
        padding: 6px 16px;
        border-radius: 8px;
        font-weight: bold;
    }

    QPushButton:hover {
        background-color: #B3DDE4;
    }

    QLabel {
        font-weight: bold;
        color: #002629;
    }
""")

        mainLayout = QtWidgets.QHBoxLayout(Form)

        formSide = QtWidgets.QVBoxLayout()

        # === Preset Name + status indicator ===
        presetRow = QtWidgets.QVBoxLayout()
        presetLabelRow = QtWidgets.QHBoxLayout()

        self.presetNameLabel = QtWidgets.QLabel("Preset")
        self.presetStatusLabel = QtWidgets.QLabel("⏳")
        self.presetStatusLabel.setToolTip("Preset's name must be unique")

        presetLabelRow.addWidget(self.presetNameLabel)
        presetLabelRow.addWidget(self.presetStatusLabel)
        presetLabelRow.addStretch()

        presetRow.addLayout(presetLabelRow)

        self.presetNameEdit = QtWidgets.QLineEdit()
        self.presetPasswordEdit = QtWidgets.QLineEdit()
        presetRowLineEditRow = QtWidgets.QHBoxLayout()
        presetRowLineEditRow.addWidget(self.presetNameEdit)
        presetRowLineEditRow.addWidget(self.presetPasswordEdit)

        presetRow.addLayout(presetRowLineEditRow)

        # === Administrator Profile Name + Lock ===
        adminRow = QtWidgets.QHBoxLayout()
        self.adminProfileLabel = QtWidgets.QLabel("Administrator Profile")
        self.lockButton = QtWidgets.QPushButton("Lock")
        adminRow.addWidget(self.adminProfileLabel)
        adminRow.addWidget(self.lockButton)

        self.adminProfileEdit = QtWidgets.QLineEdit()
        adminRowLineEditRow = QtWidgets.QHBoxLayout()
        adminRowLineEditRow.addWidget(self.adminProfileEdit)

        # === Windows Profile Name + Add Profile ===
        profileRow = QtWidgets.QHBoxLayout()
        self.profileNameLabel = QtWidgets.QLabel("Windows Profile")
        self.addFolderButton = QtWidgets.QPushButton("Add Profile")
        profileRow.addWidget(self.profileNameLabel)
        profileRow.addWidget(self.addFolderButton)

        self.profileNameEdit = QtWidgets.QLineEdit()
        self.profilePassEdit = QtWidgets.QLineEdit()
        profileRowLineEditRow = QtWidgets.QHBoxLayout()
        profileRowLineEditRow.addWidget(self.profileNameEdit)
        profileRowLineEditRow.addWidget(self.profilePassEdit)

        # === Butoane jos ===
        buttonRow = QtWidgets.QHBoxLayout()
        self.cancelButton = QtWidgets.QPushButton("Cancel")
        self.nextButton = QtWidgets.QPushButton("Next")
        buttonRow.addWidget(self.cancelButton)
        buttonRow.addWidget(self.nextButton)
        buttonRow.addStretch()

        # Adaugă componente în layoutul din stânga
        formSide.addLayout(presetRow)
        formSide.addSpacing(10)
        formSide.addLayout(adminRow)
        formSide.addLayout(adminRowLineEditRow)
        formSide.addSpacing(10)
        formSide.addLayout(profileRow)
        formSide.addLayout(profileRowLineEditRow)
        formSide.addStretch()
        formSide.addLayout(buttonRow)

        # Dreapta: lista de profile create
        sideLayout = QtWidgets.QVBoxLayout()
        self.createdProfilesLabel = QtWidgets.QLabel("Created Profiles")
        self.profilesList = QtWidgets.QListView()
        self.removeButton = QtWidgets.QPushButton("Remove")
        sideLayout.addWidget(self.createdProfilesLabel)
        sideLayout.addWidget(self.profilesList)
        sideLayout.addWidget(self.removeButton)

        mainLayout.addLayout(formSide, 2)
        mainLayout.addSpacing(20)
        mainLayout.addLayout(sideLayout, 1)

        # === Setări de obiecte și placeholdere ===
        self.presetNameEdit.setObjectName("presetNameEdit")
        self.presetStatusLabel.setObjectName("presetStatusLabel")
        self.profileNameEdit.setObjectName("profileNameEdit")
        self.addFolderButton.setObjectName("addFolderButton")
        self.adminProfileEdit.setObjectName("adminProfileEdit")
        self.lockButton.setObjectName("lockButton")
        self.profilesList.setObjectName("profilesList")
        self.removeButton.setObjectName("removeButton")
        self.cancelButton.setObjectName("cancelButton")
        self.nextButton.setObjectName("nextButton")

        self.presetNameEdit.setPlaceholderText("Name")
        self.presetPasswordEdit.setPlaceholderText("Password")
        self.adminProfileEdit.setPlaceholderText("Name")
        self.profileNameEdit.setPlaceholderText("Name")
        self.profilePassEdit.setPlaceholderText("Password")

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        Form.setWindowTitle("Preset Configurator")


# Testare rapidă UI
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())