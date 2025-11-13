import os
import requests
from PyQt6.QtWidgets import (
    QWidget, QMessageBox, QListWidgetItem
)
from PyQt6 import QtWidgets
from PyQt6.QtCore import QRunnable, QThreadPool, pyqtSignal, QObject, Qt
from UI.appsPage import Ui_Form
from MainScript.quick_page_logic import QuickPage
from MainScript.cancel_logic import CancelConfirmDialog\



class WorkerSignals(QObject):
    result = pyqtSignal(list)
    error = pyqtSignal(str)


class SearchWorker(QRunnable):
    def __init__(self, query):
        super().__init__()
        self.query = query
        self.signals = WorkerSignals()

    def run(self):
        try:
            results = AppsLogic.search_choco_packages_static(self.query)
            self.signals.result.emit(results)
        except Exception as e:
            self.signals.error.emit(str(e))


class AppsLogic(QWidget):
    def __init__(self, project_context):
        super().__init__()
        self.ui = Ui_Form()
        self.ui.setupUi(self)

        self.context = project_context
        self.current_profile = "Apps Structure"

        self.folder_structure = self.context.get_apps_structure()
        self.app_paths = self.context.get_apps_global()

        self.selected_folder = None
        self.current_structure = self.folder_structure
        self.folder_stack = []
        self.backward_stack = []
        self.forward_stack = []

        self.ui.profileCombo.clear()
        self.ui.profileCombo.addItem("Apps Structure")
        self.ui.profileCombo.setCurrentIndex(0)
        self.ui.profileCombo.setEnabled(False)

        self.ui.foldersList.itemClicked.connect(self.handle_folder_click)
        self.ui.cancelButton_2.setText("Back")
        self.ui.cancelButton_2.clicked.connect(self.go_back_to_folder_selection)
        self.ui.searchBar.textChanged.connect(self.search_choco_apps)
        self.ui.availableAppsList.itemClicked.connect(self.handle_app_selection)
        self.ui.cancelButton.clicked.connect(self.confirm_cancel)
        self.ui.nextButton.clicked.connect(self.open_quick_page)
        self.ui.removeAppButton.clicked.connect(self.remove_selected_app)

        self.ui.backButton.clicked.connect(self.go_back_folder)
        self.ui.forwardButton.clicked.connect(self.go_forward_folder)

        self.show_root_folders()
        self.reload_added_apps()

    def reload_added_apps(self):
        self.ui.addedApps.clear()
        for app_name, path in self.app_paths.items():
            item = QListWidgetItem(app_name)
            item.setToolTip(f"Install path: {path}")
            self.ui.addedApps.addItem(item)

    def open_quick_page(self):
        self.context.set_apps_structure(self.folder_structure)
        self.context.set_apps_global(self.app_paths)
        self.quick_window = QuickPage(project_context=self.context)
        self.quick_window.show()
        self.close()
    
    def remove_selected_app(self):
        selected_items = self.ui.addedApps.selectedItems()
        if not selected_items:
            QMessageBox.warning(self, "Warning", "No app selected to remove.")
            return

        for item in selected_items:
            app_name = item.text()
            self.app_paths.pop(app_name, None)
            self.ui.addedApps.takeItem(self.ui.addedApps.row(item))


    def confirm_cancel(self):
        dialog = CancelConfirmDialog()
        if dialog.exec() == QtWidgets.QDialog.DialogCode.Accepted:
            self.close()

    def show_root_folders(self):
        self.ui.foldersList.clear()
        self.folder_stack.clear()
        self.backward_stack.clear()
        self.forward_stack.clear()
        self.current_structure = self.folder_structure
        self.ui.pathDisplay.setText("")
        for item in self.folder_structure:
            list_item = QListWidgetItem(item["name"])
            self.ui.foldersList.addItem(list_item)
        self.selected_folder = None

    def load_from_context(self):
        # Reîncarcă structura de directoare și aplicațiile
        self.folder_structure = self.context.get_apps_structure()
        self.app_paths = self.context.get_apps_global()

        # Reset stive și selecții
        self.selected_folder = None
        self.current_structure = self.folder_structure
        self.folder_stack = []
        self.backward_stack = []
        self.forward_stack = []

        # Reîncarcă UI-ul
        self.show_root_folders()
        self.reload_added_apps()
        self.ui.pathDisplay.setText("")

    def handle_folder_click(self, item):
        clicked_name = item.text().strip()
        if not self.folder_stack:
            for struct in self.folder_structure:
                if struct["name"] == clicked_name:
                    self.backward_stack.append((self.folder_structure, None))
                    self.forward_stack.clear()
                    self.folder_stack.append((self.folder_structure, None))
                    self.current_structure = struct.get("children", [])
                    self.selected_folder = struct["name"]
                    self.load_subfolders(self.current_structure, self.selected_folder)
                    return
        else:
            for child in self.current_structure:
                if child["name"] == clicked_name:
                    if self.selected_folder is None:
                        new_path = clicked_name
                    else:
                        new_path = os.path.join(self.selected_folder, clicked_name)
                    self.backward_stack.append((self.current_structure, self.selected_folder))
                    self.forward_stack.clear()
                    self.folder_stack.append((self.current_structure, self.selected_folder))
                    self.current_structure = child.get("children", [])
                    self.selected_folder = new_path
                    self.load_subfolders(self.current_structure, self.selected_folder)
                    return

    def load_subfolders(self, children_list, full_path):
        self.ui.foldersList.clear()
        self.ui.pathDisplay.setText(full_path)
        for child in children_list:
            item = QListWidgetItem(child['name'])
            self.ui.foldersList.addItem(item)
        self.selected_folder = full_path

    def go_back_to_folder_selection(self):
        from MainScript.folder_logic import FolderLogic  # evită import circular

        self.context.set_apps_structure(self.folder_structure)
        self.context.set_apps_global(self.app_paths)

        self.folder_window = FolderLogic(project_context=self.context)
        self.folder_window.load_from_context()  # ← încarcă starea anterioară
        self.folder_window.show()
        self.close()



    def go_back_folder(self):
        if not self.backward_stack:
            return
        self.forward_stack.append((self.current_structure, self.selected_folder))
        self.current_structure, self.selected_folder = self.backward_stack.pop()
        self.load_subfolders(self.current_structure, self.selected_folder)

    def go_forward_folder(self):
        if not self.forward_stack:
            return
        self.backward_stack.append((self.current_structure, self.selected_folder))
        self.current_structure, self.selected_folder = self.forward_stack.pop()
        self.load_subfolders(self.current_structure, self.selected_folder)

    def search_choco_apps(self):
        query = self.ui.searchBar.text().strip()
        if not query:
            self.ui.availableAppsList.clear()
            return
        worker = SearchWorker(query)
        worker.signals.result.connect(self.display_results)
        worker.signals.error.connect(lambda e: QMessageBox.critical(self, "Error", e))
        QThreadPool.globalInstance().start(worker)

    def display_results(self, apps):
        self.ui.availableAppsList.clear()
        for app in apps:
            item = QListWidgetItem(f"{app['title']} ({app['id']})")
            item.setData(Qt.ItemDataRole.UserRole, app['id'])
            self.ui.availableAppsList.addItem(item)

    def handle_app_selection(self, item):
        text = item.text()
        app_id = item.data(Qt.ItemDataRole.UserRole)
        self.add_selected_app(text, app_id)

    def add_selected_app(self, text, app_id):
        if not self.selected_folder:
            QMessageBox.warning(self, "Warning", "Select a folder first.")
            return
        for i in range(self.ui.addedApps.count()):
            if self.ui.addedApps.item(i).text() == text:
                return
        item = QListWidgetItem(text)
        item.setToolTip(f"Install path: {self.selected_folder}")
        self.ui.addedApps.addItem(item)
        self.app_paths[text] = self.selected_folder

    @staticmethod
    def search_choco_packages_static(query, top=30):
        url = "https://community.chocolatey.org/api/v2/Search()"
        params = {
            "searchTerm": f"'{query}'",
            "$top": top,
            "$skip": 0,
            "$filter": "IsLatestVersion",
            "includePrerelease": "false",
            "targetFramework": ""
        }
        headers = {"Accept": "application/json"}
        try:
            response = requests.get(url, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            results = []
            for entry in data.get("d", {}).get("results", []):
                results.append({
                    "id": entry.get("Id", ""),
                    "title": entry.get("Title", entry.get("Id", "")),
                    "version": entry.get("Version", ""),
                    "summary": entry.get("Summary", "")
                })
            return results
        except Exception as e:
            print(f"Error: {e}")
            return []
