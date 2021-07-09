from cryptography.fernet import Fernet

import argparse
import base64
import boto3
import consul
import os

NUM_BYTES_FOR_LEN = 4


def create_data_key(cmk_id, key_spec="AES_256"):
    # Create data key
    kms_client = boto3.client("kms")
    response = kms_client.generate_data_key(KeyId=cmk_id, KeySpec=key_spec)

    # Return the encrypted and plaintext data key
    return response["CiphertextBlob"], base64.b64encode(response["Plaintext"])


def decrypt_data_key(data_key_encrypted):
    # Decrypt the data key
    kms_client = boto3.client("kms")
    response = kms_client.decrypt(CiphertextBlob=data_key_encrypted)

    # Return plaintext base64-encoded binary data key
    return base64.b64encode((response["Plaintext"]))


def backup(c, path, key):
    # Fetch and encrypt snapshot
    snap = c.snapshot.get()
    dk_enc, dk_plain = create_data_key(key)
    f = Fernet(dk_plain)
    snap_enc = f.encrypt(snap)

    # Write encrypted backup w/ key
    with open(path, "wb") as file_encrypted:
        file_encrypted.write(
            len(dk_enc).to_bytes(NUM_BYTES_FOR_LEN, byteorder="big")
        )
        file_encrypted.write(dk_enc)
        file_encrypted.write(snap_enc)


def restore(c, path):
    # Read encrypted backup w/ key
    with open(path, "rb") as file:
        file_contents = file.read()

    dk_enc_len = (
        int.from_bytes(file_contents[:NUM_BYTES_FOR_LEN], byteorder="big")
        + NUM_BYTES_FOR_LEN
    )
    dk_enc = file_contents[NUM_BYTES_FOR_LEN:dk_enc_len]
    dk_plain = decrypt_data_key(dk_enc)

    # Decrypt and restore backup
    f = Fernet(dk_plain)
    file_contents_decrypted = f.decrypt(file_contents[dk_enc_len:])
    c.snapshot.put(file_contents_decrypted)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Encrypted backup and restore of Consul cluster"
    )
    parser.add_argument(
        "--operation",
        help="Operation to perform: backup or restore",
        required=True,
    )
    parser.add_argument(
        "--keyid",
        help="The KMS key ID to use for encryption operations",
        required=False,
    )
    parser.add_argument(
        "--file",
        help="File to backup to or restore from",
        default="backup.enc.snap",
        required=False,
    )

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
    args = parser.parse_args()

    if args.operation == "backup":
        backup(c, args.file, args.keyid)
    elif args.operation == "restore":
        restore(c, args.file)
    else:
        print("Invalid operation")
