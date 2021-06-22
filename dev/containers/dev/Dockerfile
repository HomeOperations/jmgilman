FROM ubuntu:20.04

ENV CONSUL_VERSION=1.9.5
ENV NOMAD_VERSION=1.1.1
ENV PACKER_VERSION=1.7.2
ENV PACKER_WIN_UPDATE_VERSION=0.11.0
ENV TERRAFORM_VERSION=0.15.5
ENV VAULT_VERSION=1.7.2
ENV VSSH_VERSION=0.1.2

# Update system
RUN apt update
RUN apt upgrade -y

# Install base tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt install -y ca-certificates git jq iputils-ping ssh unzip wget nano rsync

# Install Consul
RUN wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O /tmp/consul.zip
RUN unzip /tmp/consul.zip -d /usr/bin
RUN chmod +x /usr/bin/consul

# Install Nomad
RUN wget https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip  -O /tmp/nomad.zip
RUN unzip /tmp/nomad.zip -d /usr/bin
RUN chmod +x /usr/bin/nomad

# Install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -O /tmp/packer.zip
RUN unzip /tmp/packer.zip -d /usr/bin
RUN chmod +x /usr/bin/packer

# Install Packer Windows update plugin
RUN wget https://github.com/rgl/packer-provisioner-windows-update/releases/download/v${PACKER_WIN_UPDATE_VERSION}/packer-provisioner-windows-update_${PACKER_WIN_UPDATE_VERSION}_linux_amd64.tar.gz -O /tmp/packer_win_update.tar.gz
RUN tar -xvzf /tmp/packer_win_update.tar.gz -C /tmp
RUN cp /tmp/packer-provisioner-windows-update /usr/bin/packer-provisioner-windows-update
RUN chmod +x /usr/bin/packer-provisioner-windows-update

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/bin
RUN chmod +x /usr/bin/terraform

# Install Vault
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault.zip
RUN unzip /tmp/vault.zip -d /usr/bin
RUN chmod +x /usr/bin/vault

# Install vssh
RUN wget https://github.com/jmgilman/vssh/releases/download/v${VSSH_VERSION}/vssh_${VSSH_VERSION}_Linux_x86_64.tar.gz -O /tmp/vssh.tar.gz
RUN tar -xvzf /tmp/vssh.tar.gz -C /tmp
RUN cp /tmp/vssh /usr/bin/vssh
RUN chmod +x /usr/bin/vssh

# Install MinIO client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/bin/mc
RUN chmod +x /usr/bin/mc

# Install Ansible
RUN apt install -y python3 python3-pip
RUN pip install --upgrade pip
RUN pip install ansible jmespath pywinrm pyyaml python-consul ansible-modules-hashivault

RUN ansible-galaxy collection install chocolatey.chocolatey
RUN ansible-galaxy collection install ansible.windows
RUN ansible-galaxy collection install community.windows

RUN ansible-galaxy collection install community.vmware:==1.10.0
RUN pip install -r /root/.ansible/collections/ansible_collections/community/vmware/requirements.txt

# Install Powershell Core
RUN apt install -y apt-transport-https software-properties-common
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
RUN dpkg -i /tmp/packages-microsoft-prod.deb
RUN apt update
RUN add-apt-repository universe
RUN apt install -y powershell
RUN pwsh -C Install-Module -Name VMware.PowerCLI -Force

# Install CloudFlare CLI tool
RUN apt install -y nodejs npm
RUN npm install -g cloudflare-cli

WORKDIR /root
COPY containers/dev/env.sh .
COPY containers/dev/vssh.yml .vssh
COPY scripts/backup.sh .
RUN chmod +x env.sh

ENTRYPOINT [ "/root/env.sh" ]
CMD [ "/bin/bash" ]