Ansible Role for access control
=========

This role sets up:
 - a `oit.ansible.dba.srv` user
 - copies over `ncsu_sudoers` template
 - creates a symlink to `/u`
 - lists useers in `exadata` group
 - adds users from the ldap `exadata` group to the local `wheel` group
 - creates these local groups:
   - `DBA`
   - `OINSTALL`
 - creates a local `ORAROM` user and adds to the `wheel` group
 - creates a local `ORADBA` user
 - adds the following to the `wheel` group:
   - DB admins
   - storage admins
   - CSI admins
 - copies over a ncsu_cmdb sudoers config

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
- default (geerlingguy/docker-ubi8-ansible:latest)
- default-podman (ubi8/ubi-init:latest)
- oraclecluster (oraclelinux:7.9 and oraclelinux:8.5)
- rhel (redhat/ubi8-init:latest)
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
  CentOS8Stream   │ docker      │ ansible          │ centos         │ true    │ false
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