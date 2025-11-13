import sys
from PyQt6.QtWidgets import QApplication
from MainScript.main_page_logic import MainPageLogic  # <-- noua logică
from MainScript.preset_logic import PresetForm
from Objects.project_context import ProjectContext        # deja ai

class MainApp(MainPageLogic):  # extinde MainPageLogic, care e deja QMainWindow
    def __init__(self):
        super().__init__()
        self.project_context = ProjectContext()
        self.last_search_text = ""
        self.ui.createNewPreset.clicked.connect(self.open_preset_form)

    def open_preset_form(self):
        self.preset_window = PresetForm(project_context=self.project_context)
        self.preset_window.show()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainApp()
    window.show()
    sys.exit(app.exec())
