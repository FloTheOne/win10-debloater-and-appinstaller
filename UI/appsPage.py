from PyQt6 import QtCore, QtWidgets
import sys

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(1100, 650)
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

    QLineEdit, QListWidget {
        border: 1px solid #e1ebf0;
        border-radius: 5px;
        padding: 6px;
        background-color: #e1ebf0;  /* mai deschis decât #66A5AD */
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
        color: #e1ebf0;
    }
""")

        layout = QtWidgets.QVBoxLayout(Form)

        # Profile Selector
        # === PROFILE SELECTOR ===
        self.profileGroup = QtWidgets.QGroupBox("Select Profile")
        profileRowLayout = QtWidgets.QHBoxLayout(self.profileGroup)

        # 1. ComboBox (same width as folderGroup)
        self.profileCombo = QtWidgets.QComboBox()
        # self.profileCombo.addItems(["Default", "Gaming", "Work", "Minimal"])
        self.profileCombo.setMinimumWidth(250)

        # 2. Spacer (pentru coloana Search)
        self.searchSpacer = QtWidgets.QWidget()
        self.searchSpacer.setSizePolicy(QtWidgets.QSizePolicy.Policy.Expanding, QtWidgets.QSizePolicy.Policy.Preferred)

        # 3. Placeholder (same width as addedGroup)
        self.addedPlaceholder = QtWidgets.QLineEdit()
        self.addedPlaceholder.setPlaceholderText("Some apps could not be added to the selected folders")
        self.addedPlaceholder.setReadOnly(True)
        self.addedPlaceholder.setMinimumWidth(250)

        # Adaugă elementele în ordine
        profileRowLayout.addWidget(self.profileCombo)
        profileRowLayout.addWidget(self.searchSpacer)
        profileRowLayout.addWidget(self.addedPlaceholder)

        # Adaugă tot grupul în layout-ul principal (imediat sub QVBoxLayout)
        layout.addWidget(self.profileGroup)

        # === Splitter Principal: vertical (sus + jos) ===
        self.verticalSplitter = QtWidgets.QSplitter(QtCore.Qt.Orientation.Vertical)
        layout.addWidget(self.verticalSplitter)

        # === Splitter Orizontal (sus): 3 coloane ===
        self.topSplitter = QtWidgets.QSplitter(QtCore.Qt.Orientation.Horizontal)
        self.topSplitter.setSizePolicy(QtWidgets.QSizePolicy.Policy.Expanding, QtWidgets.QSizePolicy.Policy.Expanding)

        # === FOLDERS ===
        self.folderGroup = QtWidgets.QGroupBox("Folders")
        folderLayout = QtWidgets.QVBoxLayout(self.folderGroup)
        self.folderGroup.setMinimumWidth(250)

        navWidget = QtWidgets.QWidget()
        navLayout = QtWidgets.QHBoxLayout(navWidget)
        navLayout.setContentsMargins(0, 0, 0, 0)
        self.backButton = QtWidgets.QPushButton("◀")
        self.forwardButton = QtWidgets.QPushButton("▶")
        self.pathDisplay = QtWidgets.QLineEdit()
        self.pathDisplay.setReadOnly(True)
        navLayout.addWidget(self.backButton)
        navLayout.addWidget(self.forwardButton)
        navLayout.addWidget(self.pathDisplay)

        self.foldersList = QtWidgets.QListWidget()
        folderLayout.addWidget(navWidget)
        folderLayout.addWidget(self.foldersList)

        # === SEARCH ===
        self.searchGroup = QtWidgets.QGroupBox("Search for Apps")
        self.searchGroup.setMinimumWidth(250)
        searchLayout = QtWidgets.QVBoxLayout(self.searchGroup)
        self.searchBar = QtWidgets.QLineEdit()
        self.searchBar.setPlaceholderText("Search...")
        self.availableAppsList = QtWidgets.QListWidget()
        searchLayout.addWidget(self.searchBar)
        searchLayout.addWidget(self.availableAppsList)

        # === ADDED APPS ===
        self.addedGroup = QtWidgets.QGroupBox("Added Apps")
        self.addedGroup.setMinimumWidth(250)
        addedLayout = QtWidgets.QVBoxLayout(self.addedGroup)

        self.addedApps = QtWidgets.QListWidget()
        self.removeAppButton = QtWidgets.QPushButton("Remove Selected")

        addedLayout.addWidget(self.addedApps)
        addedLayout.addWidget(self.removeAppButton)

        # === Adăugare în splitter orizontal
        self.topSplitter.addWidget(self.folderGroup)
        self.topSplitter.addWidget(self.searchGroup)
        self.topSplitter.addWidget(self.addedGroup)

        # === Zona de butoane jos
        self.bottomWidget = QtWidgets.QWidget()
        self.bottomLayout = QtWidgets.QHBoxLayout(self.bottomWidget)
        self.bottomLayout.setContentsMargins(10, 10, 10, 10)
        

        self.cancelButton = QtWidgets.QPushButton("Cancel")
        self.cancelButton_2 = QtWidgets.QPushButton("Back")
        self.nextButton = QtWidgets.QPushButton("Next")

        self.bottomLayout.addWidget(self.cancelButton)
        self.bottomLayout.addWidget(self.cancelButton_2)
        self.bottomLayout.addWidget(self.nextButton)
        self.bottomLayout.addStretch()

        # === Adăugare în splitter vertical (sus + jos)
        self.verticalSplitter.addWidget(self.topSplitter)
        self.verticalSplitter.addWidget(self.bottomWidget)
        self.verticalSplitter.setStretchFactor(0, 1)  # partea de sus extinsă implicit

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        _translate = QtCore.QCoreApplication.translate
        Form.setWindowTitle(_translate("Form", "Applications Manager"))

# === MAIN ===
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())
