from PyQt6 import QtCore, QtGui, QtWidgets
import sys

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(900, 500)

        Form.setStyleSheet("""
        QWidget {
            background-color: #66A5AD;
            color: #002629;
            font-family: Segoe UI, Arial;
            font-size: 14px;
        }

        QGroupBox {
            border: 1px solid #e1ebf0;
            border-radius: 8px;
            margin-top: 24px;
            font-weight: bold;
            color: #e1ebf0;
        }

        QGroupBox::title {
            subcontrol-origin: margin;
            subcontrol-position: top left;
            padding: 4px 12px;
            color: #002629;
            margin-bottom: 4px;
        }

        QPushButton {
            background-color: #e1ebf0;
            color: #002629;
            border: none;
            padding: 8px 20px;
            border-radius: 10px;
            font-weight: bold;
            min-width: 100px;
        }

        QPushButton:hover {
            background-color: #B3DDE4;
        }

        QListView, QListWidget, QTreeWidget {
            background-color: #e1ebf0;
            border: 1px solid #e1ebf0;
            border-radius: 6px;
            padding: 4px;
        }

        QLineEdit {
            background-color: #e1ebf0;
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 6px;
        }
        """)

        self.mainLayout = QtWidgets.QVBoxLayout(Form)

        # === Header: Preset Name și Password ===
        presetHeaderLayout = QtWidgets.QHBoxLayout()
        self.presetNameLabel = QtWidgets.QLabel("Preset: ExamplePreset")
        self.presetPasswordLabel = QtWidgets.QLabel("Password: ********")

        self.presetNameLabel.setStyleSheet("font-weight: bold; font-size: 16px;")
        self.presetPasswordLabel.setStyleSheet("font-weight: bold; font-size: 16px;")

        presetHeaderLayout.addWidget(self.presetNameLabel)
        presetHeaderLayout.addStretch()
        presetHeaderLayout.addWidget(self.presetPasswordLabel)
        self.mainLayout.addLayout(presetHeaderLayout)

        # === Structura generală: stânga + dreapta ===
        splitLayout = QtWidgets.QHBoxLayout()

        # === STÂNGA ===
        leftLayout = QtWidgets.QVBoxLayout()

        # Aplicații
        self.appList = QtWidgets.QListWidget()
        appBox = QtWidgets.QGroupBox("📦 Aplicații")
        appLayout = QtWidgets.QVBoxLayout()
        appLayout.addWidget(self.appList)
        appBox.setLayout(appLayout)

        # Optimizări
        self.optimList = QtWidgets.QListWidget()
        optimBox = QtWidgets.QGroupBox("⚙️ Optimizări")
        optimLayout = QtWidgets.QVBoxLayout()
        optimLayout.addWidget(self.optimList)
        optimBox.setLayout(optimLayout)

        # Aplicații + Optimizări pe același rând
        appsAndOptsLayout = QtWidgets.QHBoxLayout()
        appsAndOptsLayout.addWidget(appBox)
        appsAndOptsLayout.addWidget(optimBox)
        leftLayout.addLayout(appsAndOptsLayout)

        # Structură foldere
        self.folderTree = QtWidgets.QTreeWidget()
        self.folderTree.setHeaderHidden(True)

        # === Selector profil + path display
        folderHeaderLayout = QtWidgets.QHBoxLayout()
        self.profileSelector = QtWidgets.QComboBox()
        self.profilePasswordLabel = QtWidgets.QLabel("Parolă:")
        self.pathDisplay = QtWidgets.QLineEdit()
        self.pathDisplay.setReadOnly(True)

        self.profileSelector.setMinimumWidth(150)
        self.pathDisplay.setMinimumWidth(300)

        folderHeaderLayout.addWidget(QtWidgets.QLabel("Profil:"))
        folderHeaderLayout.addWidget(self.profileSelector)
        folderHeaderLayout.addWidget(self.profilePasswordLabel)
        folderHeaderLayout.addStretch()
        folderHeaderLayout.addWidget(QtWidgets.QLabel("Path:"))
        folderHeaderLayout.addWidget(self.pathDisplay)

        # === Grupare completă în folderBox
        folderBox = QtWidgets.QGroupBox("📁 Structură Foldere")
        folderLayout = QtWidgets.QVBoxLayout()
        folderLayout.addLayout(folderHeaderLayout)
        folderLayout.addWidget(self.folderTree)
        folderBox.setLayout(folderLayout)
        leftLayout.addWidget(folderBox, stretch=2)

        # === Buton Save jos ===
        self.saveButton = QtWidgets.QPushButton("Save Preset")
        leftLayout.addWidget(self.saveButton)

        splitLayout.addLayout(leftLayout, 1)
        self.mainLayout.addLayout(splitLayout)

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        _translate = QtCore.QCoreApplication.translate
        Form.setWindowTitle(_translate("Form", "Preview Preset"))


# === Testare rapidă ===
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())
