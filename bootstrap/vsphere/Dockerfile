FROM ubuntu:20.04

# Upgrade system
RUN apt-get update
RUN apt-get upgrade -y

# Install Powershell core
RUN apt-get install -y wget apt-transport-https software-properties-common
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt-get update
RUN apt-get install -y powershell

# Install required packages
RUN apt-get install -y python3-pip git iputils-ping

# Install Ansible
RUN pip install ansible

# Install vmware collection
RUN ansible-galaxy collection install community.vmware:==1.10.0
RUN pip install -r /root/.ansible/collections/ansible_collections/community/vmware/requirements.txt
RUN pip install jmespath

# Install PowerCLI
RUN pwsh -C Install-Module VMware.PowerCLI -Force

# Patch vmware collection to support removing vnics from vswitch
COPY files/patches/vmware_vswitch.py /root/.ansible/collections/ansible_collections/community/vmware/plugins/modules/vmware_vswitch.py

# Make working directory
RUN mkdir -p /opt/setup
WORKDIR /opt/setup

# Copy local script files
COPY files/ .

# Run setup script
CMD ["bash", "setup.sh"]