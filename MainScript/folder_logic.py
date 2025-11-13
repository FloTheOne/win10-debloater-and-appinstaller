import os
import sys
import ctypes
import string
from PyQt6.QtWidgets import QWidget, QMessageBox, QTreeWidgetItem, QAbstractItemView
from PyQt6.QtCore import QStringListModel
from PyQt6 import QtWidgets
from UI.folderPage import Ui_Form
from MainScript.apps_logic import AppsLogic
from MainScript.cancel_logic import CancelConfirmDialog



class FolderLogic(QWidget):
    def __init__(self, project_context):
        super().__init__()
        self.ui = Ui_Form()
        self.ui.setupUi(self)

        self.context = project_context
        self.profile_names = list(self.context.profiles.keys()) + ["Apps Structure"]  # modificat aici
        self.profile_model = QStringListModel(self.profile_names)
        self.ui.listView.setModel(self.profile_model)
        self.ui.listView.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)

        self.folder_structures = {}
        self.current_profile = None
        self.has_custom_structure = set()

        self.ui.seeFolderWidget.itemClicked.connect(self.update_current_path)
        self.ui.addFolderButton.clicked.connect(self.add_folder)
        self.ui.backButton.clicked.connect(self.go_back)
        self.ui.getCurrentStructureButton.clicked.connect(self.load_real_structure)
        self.ui.addPartitionButton.clicked.connect(self.add_fake_partition)
        self.ui.removePartitionButton.clicked.connect(self.remove_selected_folder_or_partition)
        self.ui.cancelButton.clicked.connect(self.show_cancel_confirmation)
        self.ui.listView.clicked.connect(self.switch_profile)
        self.ui.nextButton.clicked.connect(self.go_to_next)
        self.ui.removeFolderButton.clicked.connect(self.remove_selected_folder_or_partition)


        if self.profile_names:
            self.switch_profile(self.profile_model.index(0))

    def get_available_partitions(self):
        return [f"{disk}:\\" for disk in string.ascii_uppercase if os.path.exists(f"{disk}:\\")]

    def populate_partitions(self):
        self.ui.seeFolderWidget.clear()
        for partition in self.get_available_partitions():
            item = QTreeWidgetItem([partition])
            self.ui.seeFolderWidget.addTopLevelItem(item)

    
    def add_fake_partition(self):
        partition_name = self.ui.folderNameLineEdit.text().strip().upper()
        if not partition_name.endswith(":\\"):
            if partition_name.endswith(":"):
                partition_name += "\\"
            else:
                partition_name += ":\\"

        # Verificare duplicat
        for i in range(self.ui.seeFolderWidget.topLevelItemCount()):
            existing = self.ui.seeFolderWidget.topLevelItem(i).text(0).upper()
            if existing == partition_name:
                QMessageBox.warning(self, "Warning", "Partition already exists.")
                return

        item = QTreeWidgetItem([partition_name])
        self.ui.seeFolderWidget.addTopLevelItem(item)
        self.ui.folderNameLineEdit.clear()
        self._save_structure()

    def show_cancel_confirmation(self):
        dialog = CancelConfirmDialog()
        if dialog.exec() == QtWidgets.QDialog.DialogCode.Accepted:
            self.close()

    def update_current_path(self, item):
        self.ui.seeFolderWidget.headerItem().setText(0, self.get_full_path(item))

    def get_full_path(self, item):
        parts = []
        while item is not None:
            parts.insert(0, item.text(0).rstrip("\\"))
            item = item.parent()
        return "\\".join(parts)

    def add_folder(self):
        folder_name = self.ui.folderNameLineEdit.text().strip()
        if not folder_name:
            QMessageBox.warning(self, "Warning", "Enter a folder name.")
            return

        selected = self.ui.seeFolderWidget.selectedItems()
        parent = selected[0] if selected else self.ui.seeFolderWidget.invisibleRootItem()

        item = QTreeWidgetItem([folder_name])
        parent.addChild(item)
        self.ui.folderNameLineEdit.clear()
        self._save_structure()
        self.has_custom_structure.add(self.current_profile)

    def remove_selected_folder_or_partition(self):
        selected = self.ui.seeFolderWidget.selectedItems()
        if not selected:
            QMessageBox.information(self, "Info", "Select something to remove.")
            return

        for item in selected:
            parent = item.parent()
            if parent:
                parent.removeChild(item)
            else:
                index = self.ui.seeFolderWidget.indexOfTopLevelItem(item)
                self.ui.seeFolderWidget.takeTopLevelItem(index)

        self.ui.currentPathLabel.setText("")
        self._save_structure()
        self.has_custom_structure.add(self.current_profile)

    def load_real_structure(self):
        selected_items = self.ui.seeFolderWidget.selectedItems()
        if not selected_items:
            QMessageBox.information(self, "Info", "Select a folder or partition to load.")
            return

        try:
            max_depth = int(self.ui.layersNumberLineEdit.text().strip())
        except ValueError:
            QMessageBox.warning(self, "Warning", "Invalid number of layers.")
            return

        root_item = selected_items[0]
        base_path = self.get_full_path(root_item)
        self.add_folders_recursively(root_item, base_path, 0, max_depth)
        self._save_structure()
        self.has_custom_structure.add(self.current_profile)

    def add_folders_recursively(self, parent_item, path, depth, max_depth):
        if depth >= max_depth:
            return

        try:
            for entry in os.listdir(path):
                if entry in ["$RECYCLE.BIN", "System Volume Information"]:
                    continue

                full_path = os.path.join(path, entry)
                if not os.path.isdir(full_path) or self.is_hidden(full_path):
                    continue

                if any(parent_item.child(i).text(0) == entry for i in range(parent_item.childCount())):
                    continue

                new_item = QTreeWidgetItem([entry])
                parent_item.addChild(new_item)
                self.add_folders_recursively(new_item, full_path, depth + 1, max_depth)
        except Exception as e:
            print(f"Error reading {path}: {e}")
    
    def load_from_context(self):
        self.folder_structures = {}

        for profile_name in self.context.get_profiles():
            folders = self.context.get_profile_data(profile_name).get("folders", [])
            self.folder_structures[profile_name] = folders
            self.has_custom_structure.add(profile_name)

        apps_structure = self.context.get_apps_structure()
        self.folder_structures["Apps Structure"] = apps_structure
        self.has_custom_structure.add("Apps Structure")

        # Reafișează profilul curent (sau primul)
        index = self.profile_model.index(0)
        self.ui.listView.setCurrentIndex(index)
        self.switch_profile(index)

    def is_hidden(self, filepath):
        if sys.platform == "win32":
            try:
                attrs = ctypes.windll.kernel32.GetFileAttributesW(str(filepath))
                if attrs == -1:
                    return False
                return bool(attrs & 0x02)
            except Exception:
                return False
        return False

    def switch_profile(self, index):
        selected_profile = self.profile_model.stringList()[index.row()]
        self.ui.seeFolderWidget.clear()
        self.current_profile = selected_profile

        if selected_profile == "Apps Structure":
            structure = self.folder_structures.get(selected_profile)
            if structure:
                self._load_structure(structure)
            else:
                self.populate_partitions()
        elif selected_profile in self.folder_structures:
            self._load_structure(self.folder_structures[selected_profile])
        elif selected_profile not in self.has_custom_structure:
            self.populate_partitions()
        else:
            self.folder_structures[selected_profile] = []

    def go_to_next(self):
        for profile in self.profile_names:
            if profile == "Apps Structure":
                structure = self.folder_structures.get(profile, [])
                self.context.set_apps_structure(structure)
            else:
                structure = self.folder_structures.get(profile, [])
                self.context.set_folders(profile, structure)

        self.apps_window = AppsLogic(project_context=self.context)
        self.apps_window.show()
        self.close()
    
    def go_back(self):
        from MainScript.preset_logic import PresetForm
        self.prev_window = PresetForm(project_context=self.context)
        self.prev_window.load_from_context()
        self.prev_window.show()
        self.close()

    def _save_structure(self):
        if self.current_profile:
            structure = []
            for i in range(self.ui.seeFolderWidget.topLevelItemCount()):
                structure.append(self._serialize_tree(self.ui.seeFolderWidget.topLevelItem(i)))
            self.folder_structures[self.current_profile] = structure

    def _load_structure(self, structure_data):
        self.ui.seeFolderWidget.clear()
        for item_data in structure_data:
            self.ui.seeFolderWidget.addTopLevelItem(self._deserialize_tree(item_data))

    def _serialize_tree(self, item):
        return {
            "name": item.text(0),
            "children": [self._serialize_tree(item.child(i)) for i in range(item.childCount())]
        }

    def _deserialize_tree(self, data):
        item = QTreeWidgetItem([data["name"]])
        for child_data in data["children"]:
            item.addChild(self._deserialize_tree(child_data))
        return item
