# pull base image
FROM python:3.10-slim

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
    org.label-schema.docker.cmd="docker run --rm -it -v /root/hellt/ansible-docker:/ansible -v ~/.ssh/id_rsa:/root/id_rsa hellt/ansible:2.8.7 ansible-playbook -i hosts my_playbook.yml"

RUN apt -y update && \
    apt -y install openssh-client lftp && \
    pip install --upgrade pip cffi && \
    ansible==6.6.0 && \
    paramiko && \
    pexpect && \
    mitogen && \
    ansible-lint && \
    pywinrm && \
    ansible-pylibssh==1.1.0

# Installing Galaxy collections and network plugins
# note, ansible-galaxy is only supported from Ansible 2.9
# https://github.com/nokia/ansible-networking-collections/tree/master/sros
RUN ansible-galaxy collection install nokia.sros
RUN ansible-galaxy collection install arista.eos

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
