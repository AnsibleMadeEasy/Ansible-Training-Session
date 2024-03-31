Ansible ad-hoc
----------
## Why Use Ad-Hoc?
There are many cases where you might have to tranfer files, restart servers, manage packages and or users. Writing individual playbooks for each task can be time consuming anf make you project even more inidated with files than it needs to be. Running these tasks utilizing Ansible's ad-hoc utility can allow to perform these actions against multiple hosts managed in your project.

## Ad-Hoc Training Module
### Start Up the training environment
1. Start up the Training Environment:  
   - Docker: ```ansible-playbook training_session.yml -t docker```
   - Podman: ```ansible-playbook training_session.yml -t podman```
2. Log into in the Control Node:
   - ```ssh -p 2222 ansible@local```
   - The credentials for SSH can be found in ```vars/containers.yml```
   - Login credentials are also provided in a message once the containers are set up.

### Test connectivity in yoru training cluster
This will be the first ah-hoc command you will utilize to test the connectivity within your training cluster with the pre-built inventory.
```sh
ansible -m ansible.builtin.ping all
```
#### What does this command mean?
```-m``` or ```--module``` invokes the ansible builtin module for ping this may be invoked using the short form of ```ping ``` or the log form used above. The long version format represents <namespace>.<collection>.<module>.
``all``  mean that you are running this command against all of the hosts in yout inventory.

### Get the OS Distribution of the Cluster
This next action will involve using the module ```setup``` this allows yout to gather the facts on the hosts that you manage in your project. In this instance it is yout training cluster. To keep this example will aslo pass the module an expected option using the ```-a``` argument.
```sh
ansible -m setup -a "filter=ansible_distribution" all
```
This will provide you the OS Distribution for each of the hosts.
```sh
ansible -m setup -a "filter=ansible_os_family" all
```
### Get IPv$ Information of the cluster using the setup module
Now filter IPv4 information on the hosts in the cluster.
```sh
ansible -m setup -a "filter=ansible_default_ipv4" all
```
The ```setup``` module will also allow you to gather all the facts on a host and determine how they can be used later in playbooks. Facts can greatly improve the efficiency of playbook executions.

### Send a remote command to all hosts 
In this step we will be utilizing the modules ```ansible.builtin.command``` and ```ansible.builtin.shell```. What is the difference between these commands you may ask? The ```command``` module invokes a python subprocess to run the command in a controlled environment. The ```command``` module is also restricted to the commands and arguments. Attempting to pipe or redirect the command string will result in a failure as thos actions are note supported in the python subprocess class module used. The other module ```shell``` executes commands directly in the target host. Here coomands can be executed with pipes and redirectes as they would if you were utilizing a shell directly.
** Best Practice **
Avoid utilizing the ```shell``` module as much as possible and instead use the ```command``` module. This is because the ```command``` module is more secure and predictable. The ```command ``` module also runs directly with the python script.

#### Using the command module ad-hoc
```sh
ansible -m command -a "whoami" all
```
** Results **
The return value should be ```ansible``` since this is the user profile that Ansible is utilizing to execute the module against the cluster hosts.

In this next section we will be utilizing the ```packages``` module to manage packages against a cluster of hosts of mixed OS families. Ansible does provide more indepth package management for each supported OS type, but if we were to specify the package manager such as yum,dnf,apt or zypper then this command would fail. The ```packages``` module provides a more system agnostic approach

#### Using the packages module ad-hoc
```sh
ansible -m packages -a "name=httpd" all
```