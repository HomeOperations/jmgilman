import base64
import consul
import hvac
import json
import logging as log
import sys
import time


def nodes_online(path, node_names):
    node_paths = list(map(path.format, node_names))
    nodes_status = list(map(c.kv.get, node_paths))
    return len([node for node in nodes_status if node[1]])


c = consul.Consul()
v = hvac.Client()
log.basicConfig(level=log.INFO)

# The below paths are where nodes are writing/reading from as they boot
bs_root = json.loads(c.kv.get("bootstrap/hashi")[1]["Value"])["paths"]["nodes"]
node_ready_path = bs_root + "/{0}/ready"
all_ready_path = bs_root + "/ready"

# Wait until all nodes are ready to bootstrap
node_names = json.loads(base64.b64decode(sys.argv[1]))
nodes_required = len(node_names)
nodes_ready = nodes_online(node_ready_path, node_names)

log.info("Initiating bootstrap of %i nodes", nodes_required)
log.info("Detected %i/%i nodes online", nodes_ready, nodes_required)
while nodes_ready != nodes_required:
    time.sleep(15)
    nodes_ready = nodes_online(node_ready_path, node_names)
    log.info("Detected %i/%i nodes online", nodes_ready, nodes_required)

machine_config = json.loads(c.kv.get("machines/hashi")[1]["Value"])
for node_name in node_names:
    # Wrap role and secret IDs
    log.info("Writing AppRole configuration for %s", node_name)
    ip = machine_config[node_name]["networking"]["ip"]
    authorized_ips = [
        "{0}/24".format(ip),  # Private ip of the machine
        "192.168.224.1/24",  # Vault running in Docker see's requests like this
        "127.0.0.1/32",  # Requests coming from the same machine
    ]
    secret_id_wrapped = v.write(
        "/auth/approle/role/{0}/secret-id".format(node_name),
        wrap_ttl="20m",
        cidr_list=authorized_ips,
    )
    role_id_wrapped = v.read(
        "/auth/approle/role/{0}/role-id".format(node_name), wrap_ttl="20m"
    )

    # Store wrapped tokens in Consul for machines to consume
    c.kv.put(
        "{0}/{1}/tokens/role_id".format(bs_root, node_name),
        role_id_wrapped["wrap_info"]["token"],
    )
    c.kv.put(
        "{0}/{1}/tokens/secret_id".format(bs_root, node_name),
        secret_id_wrapped["wrap_info"]["token"],
    )
    log.info("Wrote AppRole configuration to bootstrap/%s/tokens/", node_name)

# Instruct nodes to begin bootstrapping
log.info("Instructing nodes to begin bootstrapping")
c.kv.put(all_ready_path, "1")
