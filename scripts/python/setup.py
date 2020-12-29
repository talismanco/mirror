import os
import json
import jsonmerge
import re
import sys
import yaml

import files as sfiles
import env as senv

# The full path directory that the `tasks.py` file is
# contained in.
rootdir = sys.argv[1]

# The current stage of the project, either: 'development', 'staging', or
# 'production'
stage = sys.argv[2]

# Frequently accessed directories
configdir = os.path.join(rootdir, "config")
settingsdir = os.path.join(configdir, "settings")
targetdir = os.path.join(rootdir, "target")

# Combine the active project stage configuration settings
# with the default `default.json` configuration settings via
# via `.env.json`. We'll use this file as our base source of truth
# for generating other configuration file types (.yaml, .env, etc.)
default_settings_path = os.path.join(settingsdir, "default.json")
default_settings_str = sfiles.get(default_settings_path)
default_settings_json = json.loads(default_settings_str)

stage_settings_path = os.path.join(settingsdir, "{}.json".format(stage))
stage_settings_str = sfiles.get(stage_settings_path)
stage_settings_json = json.loads(stage_settings_str)

settings_json = jsonmerge.merge(default_settings_json, stage_settings_json)
settings_json_str = json.dumps(settings_json, indent=4, sort_keys=True)
sfiles.write(".env.json", settings_json_str)

# Create `.env.yaml` and write content
settings_yaml = yaml.load(settings_json_str, Loader=yaml.SafeLoader)
settings_yaml_str = yaml.dump(settings_yaml)
sfiles.write(".env.yaml", settings_yaml_str)

# Create `.env` and write content
settings_env_str = senv.json2env(settings_json_str)
sfiles.write(".env", settings_env_str)

# Create `.tool-versions.env` and write content
tool_versions_path = os.path.join(rootdir, ".tool-versions")
tool_versions_str = sfiles.get(tool_versions_path)
tool_versions_env_str = senv.toolversions2env(tool_versions_str)
sfiles.write(".tool-versions.env", tool_versions_env_str)
