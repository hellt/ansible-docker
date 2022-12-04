docker run --rm -it \
    -v $(pwd):/ansible \
    -v ~/.ssh:/root/.ssh \
    ghcr.io/hellt/ansible:6.6.0-py3.10-deb ansible-playbook $@