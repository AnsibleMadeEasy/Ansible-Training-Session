Molecule Supported Role Template
=========

This template provides a framework for testing a roles functionality using a container or a cluster of containers defined in the  ```molecule.yml``` defined in each scenario.
With that being in mind there are few caveats:
1. You will have to edit the role name in the scenario you choose to use/ This can be found in ```molecule/<scenario>/converge.yml```
2. This README document will come as is in the template. you will have to edit that. 
3. This template is maintained if you discover any changes that need to be addressed please submit a pull request or file an issue.

Requirements
------------

If the role requires any installation of manipulation of any systemd services the following actions must be performed on the test host the containers are to be created on.

Create a systemd folder:
```
sudo mkdir /sys/fs/cgroup/systemd
```
Create and mount a CGROUP tagged filesystem:
```
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
```

Once this is completed on the OS all future containers will be able to spin up with a systemd space to used by mounting filesystem in the container.

Batteries Included
------------------

Currently there are 3 docker container images inlcuded in this template. 

- CentOS 8 Stream
- Ubuntu 20.04
- Oracle Linux 7.9

When initialized the CentOS and Ubuntu start up a single container where the Oracle Linux started a small cluster of containers.

Please submit an Issue if you wish to have other containers added.


Startup a Scenario
------------------

In this example we will be spinning up a cluster of Oracle Linux 7 containers that come included in this container.

Start up the 'oraclecluster' scenario:
```
molecule create -s oraclecluster
```
In this cluster we have created 5 hosts names exadata{01..05}
```
  Instance Name   │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged  
╶─────────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  CentOS 8 Stream │ docker      │ ansible          │ centos        │ false   │ false      
  instance        │ docker      │ ansible          │ default       │ false   │ false      
  exadata01       │ docker      │ ansible          │ oraclecluster │ true    │ false      
  exadata02       │ docker      │ ansible          │ oraclecluster │ true    │ false      
  exadata03       │ docker      │ ansible          │ oraclecluster │ true    │ false      
  exadata04       │ docker      │ ansible          │ oraclecluster │ true    │ false      
  exadata05       │ docker      │ ansible          │ oraclecluster │ true    │ false      
  RedHat 8        │ docker      │ ansible          │ rhel          │ false   │ false      
  Ubuntu          │ docker      │ ansible          │ ubuntu        │ false   │ false      
```
Each one of these hosts can be accessed using:
```
molecule login -s oraclecluster -h exadata01
```
This command would log into exadata01. Once you are finished. Don't forget to destroy the containers.
```
molecule destroy -s oraclecluster
```