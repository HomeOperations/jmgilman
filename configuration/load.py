from jinja2 import Environment, StrictUndefined

import argparse
import consul
import json
import os
import yaml


def main(import_dir, root_path):
    # Load environment
    host, port = os.environ["CONSUL_HTTP_ADDR"].split(":")
    scheme = "https" if bool(os.environ["CONSUL_HTTP_SSL"]) else "http"
    token = os.environ["CONSUL_HTTP_TOKEN"]
    cert = os.environ["CONSUL_CACERT"]

    c = consul.Consul(
        host=host,
        port=port,
        token=token,
        scheme=scheme,
        verify=cert,
    )
    env = Environment(undefined=StrictUndefined)

    # Find YAML files
    import_files = []
    for root, dirs, files in os.walk(import_dir):
        for file in files:
            if file.endswith(".yml") or file.endswith(".yaml"):
                import_files.append(os.path.join(root, file))

    # Build import data structure
    data = {}
    for import_file in import_files:
        key = import_file.split(import_dir)[1].split(".")[0]
        data[key] = yaml.load(open(import_file), Loader=yaml.FullLoader)

    # Import as JSON
    for key, value in data.items():
        json_str = env.from_string(json.dumps(value)).render(data)
        c.kv.put(os.path.join(root_path, key), json_str)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Import YAML into Consul")
    parser.add_argument(
        "--import-dir",
        help="YAML directory to import",
        default="import/",
        required=False,
    )
    parser.add_argument(
        "--path",
        help="Root Consul path to import to",
        default="config",
        required=False,
    )

    args = parser.parse_args()
    main(args.import_dir, args.path)
