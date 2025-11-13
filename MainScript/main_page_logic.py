from PyQt6.QtCore import QStringListModel, QTimer
from PyQt6.QtWidgets import QMainWindow, QTreeWidgetItem, QFileDialog
from UI.mainWindow import Ui_MainWindow
from firebase_uploads.firebase_get import (
    get_latest_public_presets,
    get_preset_json,
    search_presets_by_name,
    search_all_presets_by_name,
    download_cmd_file,
    get_signed_cmd_url
)
from MainScript.curl_link_logic import CurlLinkDialog

class MainPageLogic(QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.presets = []
        self.current_preset_data = {}
        self.last_search_text = ""

        # Debounce: căutare doar după pauză de tastare
        self.search_timer = QTimer()
        self.search_timer.setSingleShot(True)
        self.search_timer.setInterval(2000)  # 2 secunde
        self.search_timer.timeout.connect(self.perform_search)

        self.ui.searchBar.textChanged.connect(self.schedule_search)
        self.ui.viewPresets.clicked.connect(self.handle_preset_clicked)
        self.ui.profileSelector.currentTextChanged.connect(self.refresh_folder_tree)
        self.ui.folderTree.itemClicked.connect(self.update_path_display)

        self.ui.downloadButton.clicked.connect(self.download_cmd)
        self.ui.curlButton.clicked.connect(self.show_curl_link)

        self.load_presets()

    def schedule_search(self):
        self.search_timer.start()

    def perform_search(self):
        text = self.ui.searchBar.text().strip()
        if text == self.last_search_text:
            return

        self.last_search_text = text

        if text == "":
            self.presets = search_presets_by_name("")  # ← doar cele fără parolă
        else:
            self.presets = search_all_presets_by_name(text)

        model = QStringListModel(self.presets)
        self.ui.viewPresets.setModel(model)

    def load_presets(self):
        self.presets = get_latest_public_presets()
        model = QStringListModel(self.presets)
        self.ui.viewPresets.setModel(model)

    def handle_preset_clicked(self, index):
        preset_name = self.presets[index.row()]
        data = get_preset_json(preset_name)
        if data:
            self.current_preset_data = data
            self.selected_preset_name = preset_name
            self.populate_apps(data.get("apps_global", {}))
            self.populate_optimizations(data.get("optimizations_global", []))
            self.populate_profiles(data.get("profiles", {}))
            self.populate_folder_tree(data.get("profiles", {}))

    def populate_apps(self, apps_global: dict):
        self.ui.appList.clear()
        for app in apps_global.keys():
            self.ui.appList.addItem(app)

    def populate_optimizations(self, optimizations: list):
        self.ui.optimList.clear()
        for opt in optimizations:
            self.ui.optimList.addItem(opt)

    def populate_profiles(self, profiles: dict):
        self.ui.profileSelector.clear()
        self.ui.profileSelector.addItems(profiles.keys())

    def refresh_folder_tree(self):
        profiles = self.current_preset_data.get("profiles", {})
        self.populate_folder_tree(profiles)

    def populate_folder_tree(self, profiles: dict):
        self.ui.folderTree.clear()
        profile = self.ui.profileSelector.currentText()
        if not profile or profile not in profiles:
            return

        folders = profiles[profile].get("folders", [])
        for root_folder in folders:
            root_item = QTreeWidgetItem([root_folder["name"]])
            root_item.setData(0, 1, root_folder["name"])
            self.ui.folderTree.addTopLevelItem(root_item)
            self.add_children_recursive(root_item, root_folder.get("children", []), root_folder["name"])

    def add_children_recursive(self, parent_item, children, parent_path):
        for child in children:
            full_path = f"{parent_path}\\{child['name']}"
            item = QTreeWidgetItem([child["name"]])
            item.setData(0, 1, full_path)
            parent_item.addChild(item)
            self.add_children_recursive(item, child.get("children", []), full_path)

    def update_path_display(self, item):
        full_path = item.data(0, 1)
        self.ui.pathDisplay.setText(full_path or "")

    def download_cmd(self):
        if not hasattr(self, "selected_preset_name"):
            return
        preset = self.selected_preset_name
        save_path, _ = QFileDialog.getSaveFileName(self, "Save .cmd", f"{preset}.cmd", "CMD files (*.cmd)")
        if save_path:
            download_cmd_file(preset, save_path)

    def show_curl_link(self):
        if not hasattr(self, "selected_preset_name"):
            return
        dlg = CurlLinkDialog(self.selected_preset_name, self)
        dlg.exec()
