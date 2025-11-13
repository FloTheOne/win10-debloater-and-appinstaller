from PyQt6 import QtCore, QtGui, QtWidgets

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(400, 220)
        Form.setStyleSheet("""
            QWidget {
                background-color: #e8f0f2;
                font-family: 'Segoe UI', sans-serif;
                font-size: 14px;
                color: #1a1a1a;
            }

            QPushButton {
                background-color: #66A5AD;
                color: white;
                border: none;
                padding: 8px 16px;
                border-radius: 8px;
                font-weight: bold;
            }

            QPushButton:hover {
                background-color: #558d95;
            }

            QLabel {
                font-size: 16px;
                font-weight: bold;
            }
        """)

        # === Label ===
        self.label = QtWidgets.QLabel(parent=Form)
        self.label.setGeometry(QtCore.QRect(0, 40, 400, 40))
        self.label.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        self.label.setObjectName("label")

        # === Yes Button ===
        self.yesButton = QtWidgets.QPushButton(parent=Form)
        self.yesButton.setGeometry(QtCore.QRect(90, 130, 100, 32))
        self.yesButton.setObjectName("yesButton")

        # === No Button ===
        self.NoButton = QtWidgets.QPushButton(parent=Form)
        self.NoButton.setGeometry(QtCore.QRect(210, 130, 100, 32))
        self.NoButton.setObjectName("NoButton")

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)
    


    def retranslateUi(self, Form):
        _translate = QtCore.QCoreApplication.translate
        Form.setWindowTitle(_translate("Form", "Confirmation"))
        self.label.setText(_translate("Form", "Are you sure you want to cancel?"))
        self.yesButton.setText(_translate("Form", "Yes"))
        self.NoButton.setText(_translate("Form", "No"))


if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    Form = QtWidgets.QWidget()
    ui = Ui_Form()
    ui.setupUi(Form)
    Form.show()
    sys.exit(app.exec())
