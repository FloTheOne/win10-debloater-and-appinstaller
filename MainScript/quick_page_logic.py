from PyQt6.QtWidgets import QWidget
from UI.quickPage import Ui_Form
from MainScript.preview_page_logic import PreviewPage
from MainScript.cancel_logic import CancelConfirmDialog
from PyQt6.QtWidgets import QDialog

class QuickPage(QWidget):
    def __init__(self, project_context):
        super().__init__()
        self.ui = Ui_Form()
        self.ui.setupUi(self)

        self.context = project_context

        # Setări globale aplicate pentru toate profilele
        self.selected_options = []

        # Populate UI
        self.populate_labels()

        # Butoane
        self.ui.saveButton.clicked.connect(self.save)
        self.ui.cancelButton.clicked.connect(self.confirm_cancel)
        self.ui.cancelButton_2.clicked.connect(self.go_back)

    def populate_labels(self):
        self.ui.label.setText("Disable Telemetry")                   # checkbox 1
        self.ui.label_2.setText("Enable High Performance Mode")      # checkbox 2
        self.ui.label_3.setText("Disable Background Apps")           # checkbox 3
        self.ui.label_4.setText("Disable Bing Search & Ads")         # checkbox 4
        self.ui.label_5.setText("Remove Preinstalled Apps")          # checkbox 5

        for checkbox in [
            self.ui.checkBox, self.ui.checkBox_2,
            self.ui.checkBox_3, self.ui.checkBox_4, self.ui.checkBox_5
        ]:
            checkbox.setChecked(False)

    def get_selected_options(self):
        opts = []
        if self.ui.checkBox.isChecked():
            opts.append("Disable Telemetry")
        if self.ui.checkBox_2.isChecked():
            opts.append("Enable High Performance Mode")
        if self.ui.checkBox_3.isChecked():
            opts.append("Disable Background Apps")
        if self.ui.checkBox_4.isChecked():
            opts.append("Disable Bing Search & Ads")
        if self.ui.checkBox_5.isChecked():
            opts.append("Remove Preinstalled Apps")
        return opts

    def go_back(self):
        from MainScript.apps_logic import AppsLogic
        self.apps_window = AppsLogic(project_context=self.context)
        self.apps_window.load_from_context()  # ← readuce starea anterioară
        self.apps_window.show()
        self.close()

    def save(self):
        # Salvează opțiunile bifate la nivel global
        self.selected_options = self.get_selected_options()
        self.context.set_optimizations_global(self.selected_options)

        # Deschide pagina de preview
        self.preview_window = PreviewPage(project_context=self.context)
        self.preview_window.show()
        self.close()

    def confirm_cancel(self):
        dialog = CancelConfirmDialog()
        if dialog.exec() == QDialog.DialogCode.Accepted:
            self.close()