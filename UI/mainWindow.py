from PyQt6 import QtCore, QtGui, QtWidgets

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1000, 700)

        MainWindow.setStyleSheet("""
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

        QStatusBar {
            background-color: transparent;
            border: none;
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

        QMenuBar {
            background-color: #e1ebf0;
            color: #002629;
        }

        QMenuBar::item:selected {
            background: #B3DDE4;
        }
        """)

        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        mainLayout = QtWidgets.QVBoxLayout(self.centralwidget)

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
        self.pathDisplay = QtWidgets.QLineEdit()
        self.pathDisplay.setReadOnly(True)

        self.profileSelector.setMinimumWidth(150)
        self.pathDisplay.setMinimumWidth(300)

        folderHeaderLayout.addWidget(QtWidgets.QLabel("Profil:"))
        folderHeaderLayout.addWidget(self.profileSelector)
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

        splitLayout.addLayout(leftLayout, 3)

        # === DREAPTA ===
        rightLayout = QtWidgets.QVBoxLayout()

        self.groupBoxSetup = QtWidgets.QGroupBox("Setups")
        setupLayout = QtWidgets.QVBoxLayout(self.groupBoxSetup)

        self.searchBar = QtWidgets.QLineEdit()
        self.searchBar.setPlaceholderText("Search presets...")
        setupLayout.addWidget(self.searchBar)

        self.viewPresets = QtWidgets.QListView()
        setupLayout.addWidget(self.viewPresets)

        buttonGrid = QtWidgets.QGridLayout()
        self.downloadButton = QtWidgets.QPushButton("Download")
        self.editButton = QtWidgets.QPushButton("Edit")
        self.curlButton = QtWidgets.QPushButton("Curl")
        self.deleteButton = QtWidgets.QPushButton("Delete")

        buttonGrid.addWidget(self.downloadButton, 0, 0)
        buttonGrid.addWidget(self.editButton, 0, 1)
        buttonGrid.addWidget(self.curlButton, 1, 0)
        buttonGrid.addWidget(self.deleteButton, 1, 1)

        setupLayout.addLayout(buttonGrid)
        rightLayout.addWidget(self.groupBoxSetup)

        splitLayout.addLayout(rightLayout, 2)
        mainLayout.addLayout(splitLayout)

        # === Bottom Buttons ===
        bottomLayout = QtWidgets.QHBoxLayout()
        self.createNewPreset = QtWidgets.QPushButton("Create")
        self.quickSettingsButton = QtWidgets.QPushButton("Quick Settings")
        bottomLayout.addStretch()
        bottomLayout.addWidget(self.createNewPreset)
        bottomLayout.addSpacing(20)
        bottomLayout.addWidget(self.quickSettingsButton)
        bottomLayout.addStretch()

        mainLayout.addSpacing(20)
        mainLayout.addLayout(bottomLayout)

        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Setup Manager"))
