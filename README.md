# Ansible Collection - lxhome.jenkins

Documentation for the collection.


## Install jenkins via shell

``` shell
    #!/bin/bash
    wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update
    apt install default-jdk jenkins -y
```