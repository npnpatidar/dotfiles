import os
import json
import re
from pathlib import Path

class RcFile:
    GROUP_BLOCK_LIST = [
        re.compile(r'^(ConfigDialog|FileDialogSize|ViewPropertiesDialog|KPropertiesDialog)$'),
        re.compile(r'^\$Version$'),
        re.compile(r'^ColorEffects:'),
        re.compile(r'^Colors:'),
        re.compile(r'^DoNotDisturb$'),
        re.compile(r'^LegacySession:'),
        re.compile(r'^MainWindow$'),
        re.compile(r'^PlasmaViews$'),
        re.compile(r'^ScreenConnectors$'),
        re.compile(r'^Session:'),
    ]

    KEY_BLOCK_LIST = [
        re.compile(r'^activate widget \d+$'),
        re.compile(r'^ColorScheme(Hash)?$'),
        re.compile(r'^History Items'),
        re.compile(r'^LookAndFeelPackage$'),
        re.compile(r'^Recent (Files|URLs)'),
        re.compile(r'^Theme$', re.IGNORECASE),
        re.compile(r'^Version$'),
        re.compile(r'State$'),
        re.compile(r'Timestamp$'),
    ]

    BLOCK_LIST_LAMBDA = [
        lambda group, key: group == 'org.kde.kdecoration2' and key == 'library'
    ]

    def __init__(self, file_name):
        self.file_name = file_name
        self.settings = {}
        self.last_group = None

    def parse(self):
        with open(self.file_name) as file:
            for line in file:
                line = line.strip()
                if not line:
                    continue
                elif re.match(r'^\s*\[[^\]]+\]\s*$', line):
                    self.last_group = self.parse_group(line)
                elif re.match(r'^\s*([^=]+)=?(.*)\s*$', line):
                    key, val = re.match(r'^\s*([^=]+)=?(.*)\s*$', line).groups()
                    if self.last_group is None:
                        raise ValueError(f"{self.file_name}: setting outside of group: {line}")
                    if any(pattern.match(self.last_group) for pattern in self.GROUP_BLOCK_LIST):
                        continue
                    if any(pattern.match(key) for pattern in self.KEY_BLOCK_LIST):
                        continue
                    if any(fn(self.last_group, key) for fn in self.BLOCK_LIST_LAMBDA):
                        continue
                    if os.path.basename(self.file_name) == 'plasmanotifyrc' and key == 'Seen':
                        continue
                    self.settings.setdefault(self.last_group, {})
                    self.settings[self.last_group][key] = val
                else:
                    raise ValueError(f"{self.file_name}: can't parse line: {line}")

    def parse_group(self, line):
        return re.sub(r'\s*\[([^\]]+)\]\s*', r'\1.', line).rstrip('.')

class App:
    KNOWN_FILES = [
        "kcminputrc",
        "kglobalshortcutsrc",
        # ... (other file names)
        "kiorc",
    ]

    def __init__(self, folder_path):
        self.folder_path = folder_path
        self.files = [os.path.join(self.folder_path, file) for file in self.KNOWN_FILES]

    def run(self):
        settings = {}

        for file in self.files:
            if os.path.exists(file):
                rc = RcFile(file)
                rc.parse()

                path = Path(file).relative_to(self.folder_path)
                settings[str(path)] = rc.settings

        print("{")
        print("  programs.plasma = {")
        print("    enable = true;")
        print("    shortcuts = {")
        self.pp_shortcuts(settings["kglobalshortcutsrc"], 6)
        print("    };")
        print("    configFile = {")
        self.pp_settings(settings, 6)
        print("    };")
        print("  };")
        print("}")

    def pp_settings(self, settings, indent):
        for file in sorted(settings.keys()):
            for group in sorted(settings[file].keys()):
                for key in sorted(settings[file][group].keys()):
                    if file == "kglobalshortcutsrc" and key != "_k_friendly_name":
                        continue
                    print(" " * indent, end="")
                    print(f'"{file}".', end="")
                    print(f'"{group}".', end="")
                    print(f'"{key}" = {self.nix_val(settings[file][group][key])};')

    def pp_shortcuts(self, groups, indent):
        if groups is None:
            return

        for group in sorted(groups.keys()):
            for action in sorted(groups[group].keys()):
                if action == "_k_friendly_name":
                    continue
                print(" " * indent, end="")
                print(f'"{group}".', end="")
                print(f'"{action}" = ', end="")

                keys = re.split(r'(?<!\\),', groups[group][action])[0].replace('\\t', '\t').split('\t')

                if not keys:
                    print("[ ]")
                elif len(keys) > 1:
                    print("[" + " ".join(self.nix_val(k) for k in keys) + "]")
                elif keys[0] == "none":
                    print("[ ]")
                else:
                    print(self.nix_val(keys[0]))

                print(";")

    def nix_val(self, value):
        if value is None:
            return "null"
        elif re.match(r'^true|false$', value, re.IGNORECASE):
            return value.lower()
        elif re.match(r'^[0-9]+(\.[0-9]+)?$', value):
            return value
        else:
            return '"{}".format(value.replace(\'"\', \'\\\\\'))'


# Example usage:
folder_path = "~/.config"
app = App(folder_path)
app.run()
