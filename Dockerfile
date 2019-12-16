# pull base image
FROM python:3.6-slim

# Labels
LABEL maintainer="dodin.roman@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date= \
    org.label-schema.vcs-ref= \
    org.label-schema.name="hellt/ansible-docker" \
    org.label-schema.description="Ansible inside Docker with plugins for network automation" \
    org.label-schema.url="https://github.com/hellt/ansible-docker" \
    org.label-schema.vcs-url="https://github.com/hellt/ansible-docker" \
    org.label-schema.vendor="Roman Dodin" \
    org.label-schema.docker.cmd="docker run --rm -it -v /Users/romandodin/Dropbox/projects/ansible-docker:/ansible -v ~/.ssh/id_rsa:/root/id_rsa hellt/ansible:2.8.7 ansible-playbook -i hosts my_playbook.yml"

RUN apt -y update && \
    apt -y install openssh-client && \
    pip install --upgrade pip cffi && \
    pip install ansible==2.9.2 && \
    pip install paramiko && \
    pip install pexpect && \
    pip install mitogen ansible-lint && \
    pip install --upgrade pywinrm

# Installing Galaxy collections and network plugins
# note, ansible-galaxy is only supported from Ansible 2.9
RUN ansible-galaxy collection install nokia.sros  # v1.2.0

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
