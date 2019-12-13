ANSIBLE_VERSION="$1"
PYTHON_VERSION="$2"
ALPINE_VERSION="$3"

if [ -z "$ANSIBLE_VERSION" ]; then ANSIBLE_VERSION=""; else ANSIBLE_PIP_VERSION="==$ANSIBLE_VERSION"; fi
if [ "$PYTHON_VERSION" == "2" ]; then PYTHON_MAJORVER=""; else PYTHON_MAJORVER=$PYTHON_VERSION; fi

[[ -z "$ALPINE_VERSION" ]] && { ALPINE_VERSION="3.9"; }

git checkout $ANSIBLE_VERSION-py$PYTHON_VERSION || git checkout -b $ANSIBLE_VERSION-py$PYTHON_VERSION

cat <<EOF >Dockerfile
# pull base image
FROM alpine:$ALPINE_VERSION

# Labels
LABEL maintainer="dodin.roman@gmail.com" \\
    org.label-schema.schema-version="1.0" \\
    org.label-schema.build-date=$BUILD_DATE \\
    org.label-schema.vcs-ref=$VCS_REF \\
    org.label-schema.name="hellt/ansible-docker" \\
    org.label-schema.description="Ansible inside Docker with plugins for network automation" \\
    org.label-schema.url="https://github.com/hellt/ansible-docker" \\
    org.label-schema.vcs-url="https://github.com/hellt/ansible-docker" \\
    org.label-schema.vendor="Roman Dodin" \\
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/id_rsa hellt/ansible:2.8.7 ansible-playbook -i hosts my_playbook.yml"

RUN apk --no-cache add \\
        sudo \\
        python$PYTHON_MAJORVER \\
        py-pip \\
        openssl \\
        ca-certificates \\
        sshpass \\
        openssh-client \\
        rsync \\
        git && \\
    apk --no-cache add --virtual build-dependencies \\
        python$PYTHON_MAJORVER-dev \\
        libffi-dev \\
        openssl-dev \\
        build-base && \\
    pip$PYTHON_MAJORVER install --upgrade pip cffi && \\
    pip$PYTHON_MAJORVER install ansible$ANSIBLE_PIP_VERSION && \\
    pip$PYTHON_MAJORVER install paramiko && \\
    pip$PYTHON_MAJORVER install pexpect && \\
    pip$PYTHON_MAJORVER install mitogen ansible-lint && \\
    pip$PYTHON_MAJORVER install --upgrade pywinrm && \\
    apk del build-dependencies && \\
    rm -rf /var/cache/apk/*

# Installing Galaxy collections and network plugins
# note, ansible-galaxy is only supported from Ansible 2.9
RUN ansible-galaxy collection install nokia.sros  # v1.2.0

RUN mkdir /ansible && \\
    mkdir -p /etc/ansible && \\
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
EOF

git add Dockerfile
git commit -m "added Ansible $ANSIBLE_VERSION-py$PYTHON_VERSION"
git push origin $ANSIBLE_VERSION-py$PYTHON_VERSION
git checkout master
