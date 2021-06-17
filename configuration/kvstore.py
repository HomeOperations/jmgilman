#!/usr/bin/env python
# coding=utf-8

__author__ = "alexandruast"
YAML_EXTENSIONS = (".yml", ".yaml")
IMPORT_PATH_KEY = "import_path"
CONSUL_SERVERS_KEY = "consul"

import re
import os
import argparse
import yaml
import json
import consul


def to_consul(c_consul, d_import):
    for item in d_import:
        c_consul.kv.put(item["key"], item["value"])


def is_valid_key(key):
    text = key

    # Non-compliant: leading or trailing dots on path elements
    text = "/".join([s.lstrip(".").rstrip(".") for s in text.split("/")])

    # Non-compliant: leading or trailing slashes on full path
    text = text.lstrip("/").rstrip("/")

    if text != key:
        return False

    return bool(re.match("^[A-Za-z0-9\_\.\/-]*$", text))


# Converts a dict into consul format list: [{"key": k, "value": base64e(v)}]
def to_entries(dict):
    a = []
    for key, value in dict.items():
        item = {}
        item["key"] = key

        # We accept nested blocks, do we have a valid JSON object?
        s_json = (
            str(value)
            .replace("'", '"')
            .replace("True", '"true"')
            .replace("False", '"false"')
            .replace("None", '""')
        )

        try:
            json.loads(s_json)
            value = s_json
        except ValueError:
            print("Failed to parse JSON string")
            pass

        item["value"] = str(value)
        a.append(item)
    return a


# Converts a path to it's absolute equivalent, in relation to current directory
def to_absolute(path):
    if os.path.isabs(path):
        return path
    else:
        return os.path.join(os.path.dirname(__file__), path)


def dict_insertpath(dict, import_path_key, import_path_value):
    d = {}
    for key, value in dict.items():
        if key != import_path_key:
            key_path = import_path_value + "/" + key
            if not is_valid_key(key_path):
                raise ValueError("Invalid key path {}".format(key_path))
            d[key_path] = value
    return d


def yaml_filelist(dir, yaml_extensions):

    files = [
        os.path.join(root, file)
        for root, dirs, files in os.walk(dir)
        for file in files
        if file.lower().endswith(yaml_extensions)
    ]

    if len(files) == 0:
        raise ValueError(" No YAML files found in {}".format(dir))

    return files


def parse_yaml(files):
    yaml_list = []
    for file in files:
        try:
            f_dict = yaml.load(open(file))
            yaml_list.append(f_dict)
        except Exception as e:
            e.args += (file,)
            raise
    return yaml_list


def consul_format(yaml_list):

    dict = {}
    for f_dict in yaml_list:
        f_dict = dict_insertpath(
            f_dict, IMPORT_PATH_KEY, f_dict[IMPORT_PATH_KEY]
        )
        duplicates = set(dict).intersection(f_dict)
        if len(duplicates) > 0:
            raise ValueError(
                "Duplicate keys found: {}".format(str(duplicates))
            )
        dict.update(f_dict)
    dict = to_entries(dict)
    return dict


def main():
    parser = argparse.ArgumentParser(description="Import YAML into Consul")

    parser.add_argument(
        "--config-dir",
        help="Config directory",
        default="config",
        required=False,
    )
    parser.add_argument(
        "--import-dir",
        help="YAML directory to import",
        default="import",
        required=False,
    )

    args = parser.parse_args()

    print("[info] Parsing config/export YAML files...")

    d_config = parse_yaml(
        yaml_filelist(to_absolute(args.config_dir), YAML_EXTENSIONS)
    )

    d_import = consul_format(
        parse_yaml(
            yaml_filelist(to_absolute(args.import_dir), YAML_EXTENSIONS)
        )
    )

    # j_import = json.dumps(d_import, indent=2, sort_keys=True)

    print("[info] Processing {} records...".format(len(d_import)))

    for config in d_config:
        for c_server in config[CONSUL_SERVERS_KEY]:
            c_consul = consul.Consul(
                host=c_server["host"],
                port=c_server["port"],
                token=None
                if c_server["token"] == "None"
                else c_server["token"],
                scheme=c_server["scheme"],
                consistency=c_server["consistency"],
                dc=None if c_server["dc"] == "None" else c_server["dc"],
                verify=c_server["verify"],
                cert=None if c_server["cert"] == "None" else c_server["cert"],
            )

            index, d_export = c_consul.kv.get(c_server["path"], recurse=True)

            # Items to delete
            to_delete = []

            # add all exported pairs in items to_delete list
            if d_export is not None:
                for content in d_export:
                    to_delete.append(content["Key"])

            # remove imported pairs from to_delete list
            for content in d_import:
                try:
                    to_delete.remove(content["key"])
                except ValueError:
                    pass

            # remove items with placeholders from import list
            for content in d_import:
                if content["value"] == "%%NOREPLACE%%":
                    d_import.remove(content)

            # delete items
            if c_server["clear"] is True and len(to_delete) != 0:
                print(
                    "[info] Deleting records from {}...".format(
                        str(c_server["host"]) + ":" + str(c_server["port"])
                    )
                )
                for key in to_delete:
                    print("[info] {} deleted".format(key))
                    c_consul.kv.delete(key)

            # import items
            print(
                "[info] Importing {} records into {}...".format(
                    len(d_import),
                    str(c_server["host"]) + ":" + str(c_server["port"]),
                )
            )

            to_consul(c_consul, d_import)

    print("[info] Done importing records into Consul")


if __name__ == "__main__":
    main()
