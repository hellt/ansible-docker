# pull base image
FROM python:3.9-slim

# Labels
LABEL maintainer="dodin.roman@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date= \
    org.label-schema.name="hellt/ansible-docker" \
    org.label-schema.description="Ansible inside Docker with plugins for network automation" \
    org.label-schema.url="https://github.com/hellt/ansible-docker" \
    org.label-schema.vcs-url="https://github.com/hellt/ansible-docker" \
    org.label-schema.vendor="Roman Dodin" \
    org.label-schema.docker.cmd="docker run --rm -it -v /root/hellt/ansible-docker:/ansible -v ~/.ssh/id_rsa:/root/id_rsa hellt/ansible:2.8.7 ansible-playbook -i hosts my_playbook.yml"

RUN apt -y update && \
    apt -y install openssh-client lftp git && \
    pip install --upgrade pip cffi && \
    pip install ansible-core==2.13.8 && \
    pip install paramiko && \
    pip install pexpect && \
    pip install mitogen ansible-lint

# Installing Galaxy collections and network plugins
RUN ansible-galaxy collection install git+https://github.com/nokia/srlinux-ansible-collection.git

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
