FROM ubuntu:20.04

ENV CONSUL_VERSION=1.9.5
ENV VAULT_VERSION=1.7.2
ENV CT_VERSION=0.9.1
ENV VSSH_VERSION=0.1.2

# Upgrade system
RUN apt update && apt upgrade -y

# Install base tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt install -y ca-certificates curl git jq iputils-ping unzip wget nano kpartx parted

# Install Consul
RUN wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /usr/bin
RUN chmod +x /usr/bin/consul

# Install MinIO client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/bin/mc
RUN chmod +x /usr/bin/mc

# Install Vault
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault.zip
RUN unzip /tmp/vault.zip -d /usr/bin
RUN chmod +x /usr/bin/vault

# Install Ansible
RUN apt install -y python3 python3-pip
RUN pip install --upgrade pip
RUN pip install ansible jmespath pywinrm pyyaml python-consul ansible-modules-hashivault boto3 botocore

# Install CloudFlare CLI tool
RUN apt install -y nodejs npm
RUN npm install -g cloudflare-cli

# Install AWS CLI
RUN pip install awscli

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

# Install Flatcar Linux config transpiler
RUN wget https://github.com/kinvolk/container-linux-config-transpiler/releases/download/v${CT_VERSION}/ct-v${CT_VERSION}-x86_64-unknown-linux-gnu -O /usr/bin/ct
RUN chmod +x /usr/bin/ct

# Install vssh
RUN wget https://github.com/jmgilman/vssh/releases/download/v${VSSH_VERSION}/vssh_${VSSH_VERSION}_Linux_x86_64.tar.gz -O /tmp/vssh.tar.gz
RUN tar -xvzf /tmp/vssh.tar.gz -C /tmp
RUN cp /tmp/vssh /usr/bin/vssh
RUN chmod +x /usr/bin/vssh

COPY containers/control/files/hosts.ini /etc/ansible/hosts

WORKDIR /root
COPY containers/control/files/bootstrap.sh .
COPY containers/control/files/env.sh .
COPY containers/control/files/raspi.sh .
COPY containers/control/files/restore.sh .
RUN chmod +x bootstrap.sh
RUN chmod +x env.sh
RUN chmod +x raspi.sh
RUN chmod +x restore.sh

ENTRYPOINT [ "/root/env.sh" ]