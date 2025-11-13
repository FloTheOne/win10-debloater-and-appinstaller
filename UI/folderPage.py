from PyQt6 import QtCore, QtWidgets
import sys

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(900, 500)

        Form.setStyleSheet("""
        QWidget {
            background-color: #66A5AD;
            color: #002629;
            font-family: Segoe UI;
            font-size: 14px;
        }

        QLineEdit, QTreeWidget, QListView {
            border: 1px solid #e1ebf0;
            border-radius: 6px;
            padding: 6px;
            background-color: #e1ebf0;
            color: #002629;
        }

        QGroupBox, .profileSection, .pathSection {
            border: 1px solid #e1ebf0;
            border-radius: 8px;
            margin-top: 16px;
            padding: 8px;
            background-color: #e1ebf0;
            color: #002629;
        }

        QGroupBox::title {
            subcontrol-origin: margin;
            subcontrol-position: top left;
            padding: 4px 12px;
            color: #002629;
            border-bottom: 1px solid #e1ebf0;
            margin-bottom: 4px;
        }

        QPushButton {
            background-color: #e1ebf0;
            color: #002629;
            border: none;
            padding: 6px 12px;
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

        QLabel[class="darkLabel"] {
            color: #002629;
        }
    """)


        self.layout = QtWidgets.QHBoxLayout(Form)

        # === Left: Profiles ===
        profileContainer = QtWidgets.QWidget()
        profileContainer.setObjectName("profileSection")
        leftLayout = QtWidgets.QVBoxLayout(profileContainer)

        self.label_2 = QtWidgets.QLabel("Profiles")
        self.listView = QtWidgets.QListView()
        leftLayout.addWidget(self.label_2)
        leftLayout.addWidget(self.listView)
        leftLayout.addStretch()

        navLayout = QtWidgets.QHBoxLayout()
        self.cancelButton = QtWidgets.QPushButton("Cancel")
        self.backButton = QtWidgets.QPushButton("Back")
        self.nextButton = QtWidgets.QPushButton("Next")
        navLayout.addWidget(self.cancelButton)
        navLayout.addWidget(self.backButton)
        navLayout.addWidget(self.nextButton)
        leftLayout.addLayout(navLayout)

        # === Right: Folders and Controls ===
        pathContainer = QtWidgets.QWidget()
        pathContainer.setObjectName("pathSection")
        rightLayout = QtWidgets.QVBoxLayout(pathContainer)

        self.currentPathLabel = QtWidgets.QLabel("Folders")
        rightLayout.addWidget(self.currentPathLabel)

        # Widget-ul cu headerul dinamic pentru cale
        self.seeFolderWidget = QtWidgets.QTreeWidget()
        self.seeFolderWidget.setHeaderLabel("Current Path: ...")
        rightLayout.addWidget(self.seeFolderWidget)

        self.label = QtWidgets.QLabel("Folder/Drive Name")
        self.folderNameLineEdit = QtWidgets.QLineEdit()
        rightLayout.addWidget(self.label)
        rightLayout.addWidget(self.folderNameLineEdit)

        folderButtonsLayout = QtWidgets.QHBoxLayout()
        self.addFolderButton = QtWidgets.QPushButton("Add Folder")
        self.removeFolderButton = QtWidgets.QPushButton("Remove Folder")
        folderButtonsLayout.addWidget(self.addFolderButton)
        folderButtonsLayout.addWidget(self.removeFolderButton)
        rightLayout.addLayout(folderButtonsLayout)

        partitionButtonsLayout = QtWidgets.QHBoxLayout()
        self.addPartitionButton = QtWidgets.QPushButton("Add Drive")
        self.removePartitionButton = QtWidgets.QPushButton("Remove Drive")
        partitionButtonsLayout.addWidget(self.addPartitionButton)
        partitionButtonsLayout.addWidget(self.removePartitionButton)
        rightLayout.addLayout(partitionButtonsLayout)

        self.label_3 = QtWidgets.QLabel("Number of layers")
        self.layersNumberLineEdit = QtWidgets.QLineEdit()
        self.getCurrentStructureButton = QtWidgets.QPushButton("Get Current Structure")
        rightLayout.addWidget(self.label_3)
        rightLayout.addWidget(self.layersNumberLineEdit)
        rightLayout.addWidget(self.getCurrentStructureButton)

        self.layout.addWidget(profileContainer, 1)
        self.layout.addWidget(pathContainer, 2)

        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        Form.setWindowTitle("Folder Structure Configurator")

# === OPTIONAL: for test ===
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())
