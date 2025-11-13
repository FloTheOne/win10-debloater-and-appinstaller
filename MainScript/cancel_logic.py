from PyQt6 import QtWidgets
from UI.areYouSure import Ui_Form    

class CancelConfirmDialog(QtWidgets.QDialog):
        def __init__(self):
            super().__init__()
            self.ui = Ui_Form()
            self.ui.setupUi(self)

            # Conectare funcționalități
            self.ui.yesButton.clicked.connect(self.accept)  # închide cu accept
            self.ui.NoButton.clicked.connect(self.reject)   # închide cu reject