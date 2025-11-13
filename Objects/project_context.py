class ProjectContext:
    def __init__(self, profile_data=None, preset_name="", preset_password=""):
        # profile_data: dict cu format {"nume_profil": "parola"}
        self.preset_name = preset_name
        self.preset_password = preset_password
        self.profiles = profile_data or {}
        self.data = {
            name: {
                "folders": []
            } for name in self.profiles
        }

        self.apps_structure = []       # Structură globală de directoare pentru aplicații
        self.apps_global = {}          # Aplicații globale (app_name → path)
        self.optimizations_global = [] # Optimizări globale

    def add_profile(self, profile_name, password):
        self.profiles[profile_name] = password
        self.data[profile_name] = {"folders": []}

    def set_folders(self, profile, folders):
        if profile in self.data:
            self.data[profile]["folders"] = folders

    def set_apps_structure(self, folder_structure):
        self.apps_structure = folder_structure

    def set_apps_global(self, apps_dict):
        self.apps_global = apps_dict

    def set_optimizations_global(self, optimizations_list):
        self.optimizations_global = optimizations_list

    def get_apps_structure(self):
        return self.apps_structure

    def get_apps_global(self):
        return self.apps_global

    def get_optimizations_global(self):
        return self.optimizations_global

    def get_profile_data(self, profile):
        return self.data.get(profile, {})

    def get_all(self):
        return self.data

    def get_profiles(self):
        return self.profiles

    def check_profile_password(self, profile_name, password):
        return self.profiles.get(profile_name) == password

    def get_preset_name(self):
        return self.preset_name

    def set_preset_name(self, name):
        self.preset_name = name

    def get_preset_password(self):
        return self.preset_password

    def set_preset_password(self, password):
        self.preset_password = password

    def to_dict(self):
        return {
            "preset_name": self.preset_name,
            "preset_password": self.preset_password,
            "profiles": {
                name: {
                    "password": self.profiles[name],
                    "folders": self.data[name]["folders"]
                } for name in self.profiles
            },
            "apps_structure": self.apps_structure,
            "apps_global": self.apps_global,
            "optimizations_global": self.optimizations_global
        }