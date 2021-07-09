FROM ubuntu:20.04

ENV CONSUL_VERSION=1.9.5
ENV VAULT_VERSION=1.7.2

# Upgrade system
RUN apt update && apt upgrade -y

# Install base tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt install -y ca-certificates curl git jq iputils-ping unzip wget nano

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

WORKDIR /root
COPY containers/control/files/bootstrap.sh .
COPY containers/control/files/env.sh .
RUN chmod +x env.sh
RUN chmod +x bootstrap.sh

ENTRYPOINT [ "/root/env.sh" ]
CMD [ "/bin/bash" ]
#CMD [ "/root/bootstrap.sh" ]