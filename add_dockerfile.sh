ANSIBLE_VERSION="$1"
ALPINE_VERSION="$2"

if [ -z "$ANSIBLE_VERSION" ]; then ANSIBLE_VERSION=""; else ANSIBLE_VERSION="==$ANSIBLE_VERSION"; fi

[[ -z "$ALPINE_VERSION" ]] && { ALPINE_VERSION="3.9"; }

git checkout -b $ANSIBLE_VERSION

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
        python \\
        py-pip \\
        openssl \\
        ca-certificates \\
        sshpass \\
        openssh-client \\
        rsync \\
        git && \\
    apk --no-cache add --virtual build-dependencies \\
        python-dev \\
        libffi-dev \\
        openssl-dev \\
        build-base && \\
    pip install --upgrade pip cffi && \\
    pip install ansible$ANSIBLE_VERSION && \\
    pip install paramiko && \\
    pip install mitogen ansible-lint && \\
    pip install --upgrade pywinrm && \\
    apk del build-dependencies && \\
    rm -rf /var/cache/apk/*

RUN mkdir /ansible && \\
    mkdir -p /etc/ansible && \\
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
EOF

git add Dockerfile
git commit -m "added Ansible $ANSIBLE_VERSION"
git push origin $ANSIBLE_VERSION
