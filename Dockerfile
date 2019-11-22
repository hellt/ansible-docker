# pull base image
FROM alpine:3.9

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

RUN apk --no-cache add \
        sudo \
        python \
        py-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip install --upgrade pip cffi && \
    pip install ansible==2.9.1 && \
    pip install paramiko && \
    pip install pexpect && \
    pip install mitogen ansible-lint && \
    pip install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
