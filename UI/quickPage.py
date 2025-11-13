from PyQt6 import QtCore, QtWidgets
import sys

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(575, 430)

        # === STYLE ===
        Form.setStyleSheet("""
            QWidget {
                background-color: #66A5AD;
                color: #002629;
                font-family: Segoe UI;
                font-size: 14px;
            }

            QCheckBox {
                spacing: 8px;
                color: #002629;
            }

            QLabel {
                font-weight: bold;
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

            QComboBox {
                background-color: #e1ebf0;
                border: 1px solid #002629;
                border-radius: 5px;
                padding: 4px;
            }
        """)

        # === GROUPBOX PROFILURI ===
        self.profileGroup = QtWidgets.QGroupBox("Select Profile", Form)
        self.profileGroup.setGeometry(QtCore.QRect(150, 10, 275, 60))
        profileLayout = QtWidgets.QHBoxLayout(self.profileGroup)

        self.profileCombo = QtWidgets.QLabel()
        self.profileCombo.setObjectName("Optimizations")
        profileLayout.addWidget(self.profileCombo)

        # === LAYOUT FORMULAR ===
        self.formLayoutWidget = QtWidgets.QWidget(parent=Form)
        self.formLayoutWidget.setGeometry(QtCore.QRect(150, 80, 275, 200))
        self.formLayout = QtWidgets.QFormLayout(self.formLayoutWidget)
        self.formLayout.setContentsMargins(0, 0, 0, 0)

        # === CHECKBOX + LABELS EXPLICITE ===
        self.checkBox = QtWidgets.QCheckBox("Enable", parent=self.formLayoutWidget)
        self.label = QtWidgets.QLabel("Option 1", parent=self.formLayoutWidget)
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.ItemRole.LabelRole, self.checkBox)
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.ItemRole.FieldRole, self.label)

        self.checkBox_2 = QtWidgets.QCheckBox("Enable", parent=self.formLayoutWidget)
        self.label_2 = QtWidgets.QLabel("Option 2", parent=self.formLayoutWidget)
        self.formLayout.setWidget(1, QtWidgets.QFormLayout.ItemRole.LabelRole, self.checkBox_2)
        self.formLayout.setWidget(1, QtWidgets.QFormLayout.ItemRole.FieldRole, self.label_2)

        self.checkBox_3 = QtWidgets.QCheckBox("Enable", parent=self.formLayoutWidget)
        self.label_3 = QtWidgets.QLabel("Option 3", parent=self.formLayoutWidget)
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.ItemRole.LabelRole, self.checkBox_3)
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.ItemRole.FieldRole, self.label_3)

        self.checkBox_4 = QtWidgets.QCheckBox("Enable", parent=self.formLayoutWidget)
        self.label_4 = QtWidgets.QLabel("Option 4", parent=self.formLayoutWidget)
        self.formLayout.setWidget(3, QtWidgets.QFormLayout.ItemRole.LabelRole, self.checkBox_4)
        self.formLayout.setWidget(3, QtWidgets.QFormLayout.ItemRole.FieldRole, self.label_4)

        self.checkBox_5 = QtWidgets.QCheckBox("Enable", parent=self.formLayoutWidget)
        self.label_5 = QtWidgets.QLabel("Option 5", parent=self.formLayoutWidget)
        self.formLayout.setWidget(4, QtWidgets.QFormLayout.ItemRole.LabelRole, self.checkBox_5)
        self.formLayout.setWidget(4, QtWidgets.QFormLayout.ItemRole.FieldRole, self.label_5)

        # === BUTOANE JOS ===
        self.saveButton = QtWidgets.QPushButton("Save", parent=Form)
        self.saveButton.setGeometry(QtCore.QRect(370, 310, 75, 32))
        self.saveButton.setObjectName("saveButton")

        self.cancelButton = QtWidgets.QPushButton("Cancel", parent=Form)
        self.cancelButton.setGeometry(QtCore.QRect(130, 310, 75, 32))
        self.cancelButton.setObjectName("cancelButton")

        self.cancelButton_2 = QtWidgets.QPushButton("Back", parent=Form)
        self.cancelButton_2.setGeometry(QtCore.QRect(250, 310, 75, 32))
        self.cancelButton_2.setObjectName("cancelButton_2")

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        _translate = QtCore.QCoreApplication.translate
        Form.setWindowTitle(_translate("Form", "Quick Options"))

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())
