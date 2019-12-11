ANSIBLE_VERSION="$1"
PYTHON_VERSION="$2"

if [ -z "$ANSIBLE_VERSION" ]; then ANSIBLE_VERSION=""; else ANSIBLE_PIP_VERSION="==$ANSIBLE_VERSION"; fi
if [ "$PYTHON_VERSION" == "2" ]; then PYTHON_MAJORVER=""; else PYTHON_MAJORVER=$PYTHON_VERSION; fi

git checkout $ANSIBLE_VERSION-py$PYTHON_VERSION-deb || git checkout -b $ANSIBLE_VERSION-py$PYTHON_VERSION-deb

cat <<EOF >Dockerfile
# pull base image
FROM python:$PYTHON_VERSION-slim

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

RUN pip install --upgrade pip cffi && \\
    pip install ansible$ANSIBLE_PIP_VERSION && \\
    pip install paramiko && \\
    pip install pexpect && \\
    pip install mitogen ansible-lint && \\
    pip install --upgrade pywinrm

# Installing Galaxy collections and network plugins
# note, ansible-galaxy is only supported from Ansible 2.9
RUN ansible-galaxy collection install nokia.sros  # v1.1.2

RUN mkdir /ansible && \\
    mkdir -p /etc/ansible && \\
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
EOF

git add Dockerfile
git commit -m "added Ansible $ANSIBLE_VERSION-py$PYTHON_VERSION-deb"
git push origin $ANSIBLE_VERSION-py$PYTHON_VERSION-deb
git checkout master
