ANSIBLE_CORE_VERSION="$1"
PYTHON_VERSION="$2"

set -e

git checkout $ANSIBLE_CORE_VERSION-py$PYTHON_VERSION || git checkout -b $ANSIBLE_CORE_VERSION-py$PYTHON_VERSION

cat <<EOF >Dockerfile
# pull base image
FROM python:$PYTHON_VERSION-slim

# Labels
LABEL maintainer="dodin.roman@gmail.com" \\
    org.label-schema.schema-version="1.0" \\
    org.label-schema.build-date=$BUILD_DATE \\
    org.label-schema.name="hellt/ansible-docker" \\
    org.label-schema.description="Ansible inside Docker with plugins for network automation" \\
    org.label-schema.url="https://github.com/hellt/ansible-docker" \\
    org.label-schema.vcs-url="https://github.com/hellt/ansible-docker" \\
    org.label-schema.vendor="Roman Dodin" \\
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/id_rsa hellt/ansible:2.8.7 ansible-playbook -i hosts my_playbook.yml"

RUN apt -y update && \\
    apt -y install openssh-client lftp git && \\
    pip install --upgrade pip cffi && \\
    pip install ansible-core==$ANSIBLE_CORE_VERSION && \\
    pip install paramiko && \\
    pip install pexpect && \\
    pip install mitogen ansible-lint

# Installing Galaxy collections and network plugins
RUN ansible-galaxy collection install nokia.srlinux:0.2.0

RUN mkdir /ansible && \\
    mkdir -p /etc/ansible && \\
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
EOF

git add Dockerfile
git commit -m "added Ansible $ANSIBLE_CORE_VERSION-py$PYTHON_VERSION"
git push origin $ANSIBLE_CORE_VERSION-py$PYTHON_VERSION
docker build -t ghcr.io/hellt/ansible:$ANSIBLE_CORE_VERSION .
docker push ghcr.io/hellt/ansible:$ANSIBLE_CORE_VERSION .
# git checkout master
