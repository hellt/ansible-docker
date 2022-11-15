# Ansible container image

To generate the dockerfiles:

```
# bash add_dockerfile.sh <ansible_version> <python_major_version>
# for 2.8.7 and python2
bash add_dockerfile.sh 2.8.7 2

# for 2.8.7 and python3
bash add_dockerfile.sh 2.8.7 3

# for debian based package
# only two arguments are needed, <ansible_version> <python version>
bash add_dockerfile_deb.sh 2.9.2 3.7
```
