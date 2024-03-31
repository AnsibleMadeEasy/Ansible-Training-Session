Ansible Role for autofs
=========

This role sets up:
 - `/Remote/` directory and
   - `AdminUnixHome/` if needed.
 - installs `autofs` (variying methods for OS)
 - enables `autofs`
 - copies our configs

Variables
------------

Variable | Data Type | Purpose | Required 
-----|-----|-----|------|
autofs_mounts| list | Defines the directory to be created and serve as the mount point| No|
autofs_maps|list| This defined the file, server, paths and option to be used on the mount points| Yes 


Examples
```yaml
autofs_mounts: 
  - /data
              

autofs_maps: 
  - name: home
    directories: 
      - path: "*"
        server: your_server
        server_path: your_path_on_server
        options:
          - rw
          - intr
          - bg
          - soft
          - vers=3
          - retry=5
          - retrans=8
```
These values can either be defined at the group or host level within th corresponding inventory file. If you have a standard set of options for all of the mount points that you would like to use you can do the follwoing to save libes in the variables file:
```yaml

autofs_options:
 - rw
 - intr
 - bg
 - soft
 - vers=3
 - retry=5
 - retrans=8

autofs_maps: 
  - name: home
    directories: 
      - path: "*"
        server: your_server
        server_path: your_path_on_server
        options: "{{ autofs_options }}
```
Requirements
------------

You will need molecule and ansible on your host. See the [Molecule Docs](https://molecule.readthedocs.io/en/stable/installation.html#) Here's the [Ansible Docs](https://docs.ansible.com/ansible/latest/installation_guide/index.html).

`pip` is the offical way to install either, but you can try `brew` to install ansible; the brew install of molecule had issues that were resolved by installing with `pip`.

TL;DR

```bash
# install molecule with pip
python3 -m pip install molecule
python3 -m pip install --user "molecule[docker]"
python3 -m pip install --user "molecule[podman]"
```

(You can try with `brew` but I have had mixed results.)

Batteries Included
------------------

Currently there are 6 molecule scenarios included in this repo.

- centos (geerlingguy/docker-centos8-ansible:latest)
- default (geerlingguy/docker-centos8-ansible)
- default-podman (docker.io/geerlingguy/docker-ubi8-ansible:latest)
- oraclecluster (oraclelinux:7.9 and oraclelinux:8.5)
- rhel (geerlingguy/docker-centos8-ansible)
- ubuntu (geerlingguy/docker-ubuntu2204-ansible:latest)

Other than the oraclecluster, which deploys 2 containers, all the scenarios create a single container with the listed images.

Please submit an Issue if you wish to have other containers added.

Startup a Scenario
------------------

In this example we will be spinning up a cluster of Oracle Linux 7 containers that come included in this container.

Start up the 'oraclecluster' scenario:
```
molecule create -s oraclecluster
```
In this cluster we have created 2 hosts, 'oracle7' and 'oracle8'


```
molecule list

  Instance Name   │ Driver Name │ Provisioner Name │ Scenario Name  │ Created │ Converged
╶─────────────────┼─────────────┼──────────────────┼────────────────┼─────────┼───────────╴
  CentOS8Stream   │ docker      │ ansible          │ centos         │ false   │ false
  defaultinstance │ docker      │ ansible          │ default        │ false   │ false
  defaultinstance │ podman      │ ansible          │ default-podman │ false   │ false
  oracle7         │ docker      │ ansible          │ oraclecluster  │ false   │ false
  oracle8         │ docker      │ ansible          │ oraclecluster  │ false   │ false
  RedHat8         │ docker      │ ansible          │ rhel           │ false   │ false
  ubuntu2204      │ docker      │ ansible          │ ubuntu         │ false   │ false
```

Each one of these hosts can be accessed using:

```
molecule login -s oraclecluster -h oracle7
```

This command would log into oracle7. Once you are finished. Don't forget to destroy the containers.

```
molecule destroy -s oraclecluster
```