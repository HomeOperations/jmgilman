import ansible
import boto3
import botocore
import hvac
import os

from botocore.exceptions import ClientError


def convert_secrets(data):
    if type(data) is dict:
        data = handle_dict(data)
    elif type(data) is list:
        data = handle_list(data)

    return data


def handle_dict(data):
    for key, value in data.items():
        if is_secret(value):
            data[key] = handle_secret(value)
        else:
            data[key] = convert_secrets(value)
    return data


def handle_list(data):
    for value in data:
        if is_secret(value):
            data[data.index(value)] = handle_secret(value)
        else:
            data[data.index(value)] = convert_secrets(value)
    return data


def handle_secret(secret_str):
    if secret_str.startswith("vault/"):
        return handle_vault_secret(secret_str)
    elif secret_str.startswith("aws/"):
        return handle_aws_secret(secret_str)


def is_secret(value):
    if (
        type(value) is ansible.utils.unsafe_proxy.AnsibleUnsafeText
        or type(value) is str
    ):
        if value.startswith("vault/"):
            return True
        elif value.startswith("aws/"):
            return True

    return False


def handle_vault_secret(secret_str):
    client = hvac.Client(
        url=os.environ["VAULT_ADDR"],
        token=os.environ["VAULT_TOKEN"],
        verify=os.environ["VAULT_CACERT"],
    )

    if ":" in secret_str:
        secret_path, secret_key = secret_str.split(":")
        try:
            resp = client.secrets.kv.v2.read_secret_version(secret_path[6:])
        except hvac.exceptions.InvalidPath as e:
            return "SECRET NOT FOUND"

        if secret_key not in resp["data"]["data"]:
            return "SECRET NOT FOUND"

        return resp["data"]["data"][secret_key]
    else:
        try:
            resp = client.secrets.kv.v2.read_secret_version(secret_str[6:])
        except hvac.exceptions.InvalidPath as e:
            return "SECRET NOT FOUND"
        return resp["data"]["data"]


def handle_aws_secret(secret_str):
    ssm = boto3.client("ssm")

    try:
        result = ssm.get_parameter(Name=secret_str[4:], WithDecryption=True)
    except ClientError as e:
        if e.response["Error"]["Code"] == "ParameterNotFound":
            return "SECRET NOT FOUND"
        raise e

    return result["Parameter"]["Value"]


class FilterModule(object):
    def filters(self):
        return {
            "convert_secrets": convert_secrets,
        }
