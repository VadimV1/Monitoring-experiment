# Monitoring-experiment

## Monitoring experiment with k8s cluster locally and on 'Linode' with MongoDB, Prometheus, Graphana.

### 1. Local lab environment configurations:

**VM 1:** **‘k8s-master@192.168.1.139’ -**

functions as the master/control node with the roles: **controlplane** and **etcd**.

**VM 2:** **‘k8s-worker1’@192.168.1.140’ -** 

functions as the master/control node with the roles: **worker**

**VM 3:** **‘k8s-worker2‘@192.168.1.138‘ -** 

functions as the master/control node with the roles: **worker**

**VM 5: ‘DNS@192.168.1.143’ -**

functions as a machine that is a local DNS server.

**Host**: **‘v.v@192.168.1.101’**  - \
Personal computer that runs the 5 VM’s, has ‘**RKE**’, ‘**Helm3**’, installed and ‘**kubectl’** for the cluster configuration.

**<span style="text-decoration:underline;">2 1.1. Deployment process of the VM’s:**

***Note that I intended to use a local domain of ‘lab2.cloud’ for all of the machines for an easier involvement with them and as a practice to make the IPs static and change dns in the machines, so I installed PiHole on one of the machines to act as a local dns server for all of the machines to resolve the ip in the local network through it.**

**1.1.1.** Deployment of the 5 VM’s consisted of  installing **Ubuntu 20.04** as their main os.

**1.1.2.** After finishing the installment process of the 4 VM’s, the procedure required the additional installment of ‘**vim**’, ‘**net-tools’**, ’**openssh-server**’ and enabling the ‘ssh’ process with ‘**systemctl enable ssh**’.

**1.1.3.** Proceeding on  **‘v.v@192.168.1.101** and making an SSH key for distribution across the 4 VM’s with the ‘**ssh-keygen**’ command.

**1.1.4.** In precedence to the previous step, commence distribution of the ssh key across the 4 VM’s with the ‘**ssh-copy-id**’ command.

**1.1.5.** After the ssh key distribution, the ‘**scp**’ command was used  to send to bash scripts, ‘**make_ip_static.sh**’ and ‘**docker_install.sh**’ across the VM’s.

**1.1.6.** Running the two bash scripts to make the ip of the machine static and installing ‘Docker’ engine with 24.0.9 version. 

***note that RKE is not compatible with ‘Docker’ engine version 25.X.X and up at the time of writing of this README**

**1.1.7.** Verification that all of the VM’s are running ‘Docker’ engine 24.0.9 and the user has privilege for docker commands without ‘**sudo**’ command or ‘**root**’ privileges.

**<span style="text-decoration:underline;">2. Creation of the cluster:</span>**

**2.1.** Installation of **‘RKE’** on **‘v.v@192.168.1.101**, giving it exec property and adding it to the ‘**$PATH**’ variable.

**Url:** [RKE installation guide](https://github.com/rancher/rke)

**2.2.** Installation of **‘kubectl’** on **‘v.v@192.168.1.101’**, giving it exec property and adding it to the ‘**$PATH**’ variable.

**Url:** [kubectl installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management) 

**2.3.** Creation of a directory for the Cluster config files on **‘v.v@192.168.1.101’.**

**2.4.** Creation of **‘cluster.yml’** file for ‘**RKE**’.

**2.5.** Deployment of the cluster with ‘**rke up –config cluster.yml**’ command.

**2.6.** Proceeding to copy the ‘**kube_config_cluster.yml**’ file that was created after ‘**RKE**’ runtime into the /.kube directory.

**2.7.** Running the **‘kubectl get nodes**’ command to see that all of the 3 nodes in the cluster are at ‘**READY**’ state.
