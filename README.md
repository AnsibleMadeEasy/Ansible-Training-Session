# Ansible User Sessions
## Purpose
This code base is to both serve as a teaching tool and testing ground for users to get familiar and comfortable with the functionality with Ansible as an orchestration and configuration management tool. 

## Requirements
It is prefered that you utilize one of the support OS Distributions listed:

| Operating System | Version | Supported |
|------------------|---------|-----------|
| Red Hat Enterprise Linux | 8 | [x] |
| Canonical Ubuntu | 22 | [x] | 
| Fedora Linux | | [x] |
| MacOSX | 14.2 < | [x] | 

Though its is not listed operating systems downstream of Red Hat Enterprise Linux are supported by this code base as well. Testing is limiwed with respect to time.

Ansible is also required to be installed on you system as well. This can be done be performing the following:
### Red Hat Distributions
#### Using Packages 
```sh
sudo dnf install ansible-core
```
#### Using Python3 PIP
```sh
pip3 install ansible --user
```
If you do not have pip installed this can be remediated by running:
```sh
sudo dnf install python3-pip
```
### Ubuntu 
```sh
apt update && apt install ansible-core 
```
### MacOSX
Using Homebrew:
```sh
brew install ansible
```
Using Python3 PIP
```
pip3 install ansible --user
```

## Getting started
Before you can get 'off to the races' with this training environment. It too is driven by Ansible. So your first task is to spin up your conatainers using either Docker or Podman. The following playbook will do all these tasks based on your prefered container manager (Docker/Podman) for you to include to check if the container manager is installed on your system.
### Start Up
```sh
ansible-playbook training_session.yml -t docker
```
#### What it does
- Checks if the system has a conainer manager installed
- Creates a Docker Network for all operations to work within
- Creates an Ansible Control node for you to work in
- Creates a cluster of hosts connected to the controll node
- Pulls the working repo into the controll node.

After the playbook has successfully completed you will be able to log into the 'controller' node for this tesing environment using the following:
```sh
ssh -o StrictHostKeyChecking=no -p 2222 ansible@localhost
``` 
Aftwards you will be prompted for the password which you can find in the ```var/containers.yml``` file. A message at the end of the playbook will also provide you these credentials.

You can also add the following to your ```~/.ssh/config``` file for conveniance sake:
```
Host ansible
   User ansible
   hostname localhost
   StrictHostKeyChecking no
   Port 2222
```

## Cleaning up
After you are done with your session you may teardown you working cluster by running the follwoing command from outside your cluster:
```sh
ansible-playbook training_session.yml -t teardown
```
#### What it does
- Stops all running containers
- Removes all containers
- Removes the Docker network

## Happy Coding and Glad to have you!
[Sign Up for the Ansible Empire](mail:dlewell@ncsu.edu)