Ansible Role for NCSURepos
=========

This role sets up:
 - repos based on version of Oracle Linux

NCSURepos is a molecule framework supported role to configure the repos for systems so that the following tools may be installed:
- Crowdstrike Falcon Sensor
- Avamar Backup Agent
- Nessus

Requirements
------------

Proxy configurations for the servers must be specified in the role for the package manager to reach the servers providing the packages.

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

Currently there are 4 molecule scenarios included in this repo.

- centos (quay.io/centos/centos:stream8)
- default (quay.io/centos/centos:stream8)
- oraclecluster (docker.io/oraclelinux:7.9 and docker.io/oraclelinux:8)
- ubuntu (geerlingguy/docker-centos8-ansible:latest)

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

  Instance Name  │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
╶────────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  centos8-stream │ docker      │ ansible          │ centos        │ false   │ false
  instance       │ docker      │ ansible          │ default       │ false   │ false
  oracle7        │ docker      │ ansible          │ oraclecluster │ false   │ false
  oracle8        │ docker      │ ansible          │ oraclecluster │ false   │ false
  Ubuntu         │ docker      │ ansible          │ ubuntu        │ false   │ false
                 ╵             ╵                  ╵               ╵         ╵
```

Each one of these hosts can be accessed using:

```
molecule login -s oraclecluster -h oracle7
```

This command would log into oracle7. Once you are finished. Don't forget to destroy the containers.

```
molecule destroy -s oraclecluster
```
