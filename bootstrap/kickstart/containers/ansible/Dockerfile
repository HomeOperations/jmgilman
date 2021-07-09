FROM alpine@sha256:1775bebec23e1f3ce486989bfc9ff3c4e951690df84aa9f926497d82f2ffca9d

# Install Ansible
RUN apk add ansible openssl python3 py3-pip
RUN pip install --upgrade pip
RUN pip install jmespath pywinrm pyyaml python-consul ansible-modules-hashivault

RUN addgroup -S app && adduser -S app -G app
RUN mkdir /ansible
RUN mkdir /ansible/configs
RUN mkdir /ansible/configs/consul
WORKDIR /ansible

COPY config.yml .
COPY templates/ templates
RUN chown -R app:app /ansible

USER app
ENTRYPOINT [ "ansible-playbook", "config.yml" ]