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

#### 1.1. Deployment process of the VM’s:

***Note that I intended to use a local domain of ‘lab2.cloud’ for all of the machines for an easier involvement with them and as a practice to make the IPs static and change dns in the machines, so I installed PiHole on one of the machines to act as a local dns server for all of the machines to resolve the ip in the local network through it.**

**1.1.1.** Deployment of the 5 VM’s consisted of  installing **Ubuntu 20.04** as their main os.

**1.1.2.** After finishing the installment process of the 4 VM’s, the procedure required the additional installation of ‘**vim**’, ‘**net-tools’**, ’**openssh-server**’ and enabling the ‘**ssh**’ process with ```systemctl enable ssh```.

**1.1.3.** Proceeding on  **‘v.v@192.168.1.101** and making an SSH key for distribution across the 4 VM’s with the ```ssh-keygen```.

**1.1.4.** In precedence to the previous step, commence distribution of the ssh key across the 4 VM’s with the ```ssh-copy-id```.

**1.1.5.** After the ssh key distribution, the ```scp```  was used to send to bash scripts, ‘**make_ip_static.sh**’ and ‘**docker_install.sh**’ across the VM’s.

**1.1.6.** Running the two bash scripts to make the ip of the machine static and installing ‘Docker’ engine with 24.0.9 version. 

***note that RKE is not compatible with ‘Docker’ engine version 25.X.X and up at the time of writing of this README**

**1.1.7.** Verification that all of the VM’s are running ‘Docker’ engine 24.0.9 and the user has privilege for docker commands without ‘**sudo**’ command or ‘**root**’ privileges.

#### 1.2. Creation of the cluster:

**1.2.1.** Installation of **‘RKE’** on **‘v.v@192.168.1.101**, giving it exec property and adding it to the ‘**$PATH**’ variable.

**Url:** [RKE installation guide](https://github.com/rancher/rke)

**1.2.2.** Installation of **‘kubectl’** on **‘v.v@192.168.1.101’**, giving it exec property and adding it to the ‘**$PATH**’ variable.

**Url:** [kubectl installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management) 

**1.2.3.** Creation of a directory for the Cluster config files on **‘v.v@192.168.1.101’.**

**1.2.4.** Creation of **‘cluster.yml’** file for ‘**RKE**’.

**1.2.5.** Deployment of the cluster with ```rke up –config cluster.yml```.

**1.2.6.** Proceeding to copy the ‘**kube_config_cluster.yml**’ file that was created after ‘**RKE**’ runtime into the /.kube directory.

**1.2.7.** Running the ```kubectl get nodes``` command to see that all of the 3 nodes in the cluster are at ‘**READY**’ state.

#### 1.3. Installation of an NFS server provisioner:

***note that the deployment of DB's, server etc, require a presisntent volume by default in the helm chart (mostly) so in order not to waste time on making storage classes, PV's and PVC's for each app I've decided that deploying a nfs server that will provision dynamically the PV's for the PVC's will be more efficent**

**1.3.1** Use **Helm3** to deploy [nfs-server-provisioner](https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner) on the k8s cluster, preferably in its own NS.

***note that the process of installation/deployment/usage is the same for both of the local cluster and 'Linode' cluster from now on**

### 2. Installation of MongoDB:  

**2.1.** Use **Helm3** to deploy [MongoDB](https://artifacthub.io/packages/helm/bitnami/mongodb) on the k8s cluster, preferably in its own NS (i.e in **mongodb** namespace).

**2.1.1.** Create a custom values **.yaml** for the **Helm3** deployment and specfiy there that the pod will run under **NodePort** to be able to connect to the DB across the cluster.

**2.1.2**  Create a namespace for MongoDB with ```kubectl create ns *your ns name*```.

**2.1.2** Run ```helm install ``` with the specifed **MongoDB** repo, the desired NS and the custom values file.

**2.2.** After the installation **MongoDB** should be accessible through **[IP]**:**[nodePort]**

### 3. Installation of Prometheus:

***note that for ease of use I have used the kube-prometheus-stack wchich contains Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring**

**3.1.** Use **Helm3** to deploy [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) on the k8s cluster, preferably in its own NS (i.e in **monitoring** namespace).

**3.1.1.** Create a custom values **.yaml** for the **Helm3** deployment and specfiy there that the pods for **Grafana**,**Prometheus** will run under **NodePort** to be able to connect to them locally, optionally enable **ingress** through the **values.yaml** so that the UI's of the deployments will be accesible through a ascii address.

**3.1.2**  Create a namespace for **kube-prometheus-stack** with ```kubectl create ns *your ns name*```.

**3.1.2** Run ```helm install ``` with the specifed **kube-prometheus-stack** repo, the desired NS and the custom values file.

**3.2.** After the installation **Grafana** and **Prometheus** should be accessible through **[IP]**:**[nodePort]** or **[address]**:**[port]** if you used **ingerss**.

### 4. Installation of a MongoDB exporter:

**4.1.** Use **Helm3** to deploy [prometheus-mongodb-exporter](https://artifacthub.io/packages/helm/prometheus-community/prometheus-mongodb-exporter) on the k8s cluster, preferably in the **Default** namespace, or the same namespace that you specefied for **Step 3**.

***note the by default prometheus has limited access for namespace in which it can pull data from the exporters through the servicemonitors, that is why I specified the 'Default' or the same NS that the 'Prometheus' was deployed, If by any chance you need to allow 'Prometheus' to be able so scrape other NS that is doesnt have persmission, please check [Monitoring additional namespaces](https://github.com/prometheus-operator/kube-prometheus/blob/main/docs/customizations/monitoring-additional-namespaces.md)**.

**4.1.1.** Create a custom values **.yaml** for the **Helm3** deployment and specfiy there that the serviceMonitor for **Prometheus** will be enabled and specify under **serviceMonitor.additionalLabels.release** the same **release** the the prometheus cluster's **servicemonitor**'s have in their configurations (Use ```kubectl get servicemonitor -n [Prometheus NS]``` and then ```kubectl get servicemonitor [serviceMonitor of some exporteer] -n [Prometheus NS] -o yaml``` to see the release under the label, so your new exporeter will be available to the **Prometheus** scraper ) and also specefy the MongoDB URI the you use to connect to it, for example with **MongoDB Compass**. Optionally run the exporter pod under **NodePort** to be able to connect to them locally for debugging.

**4.1.2.** Run ```helm install ``` with the specifed **prometheus-mongodb-exporter** repo, the needed NS and the custom values file.

**4.2.** After the installation, the **Target** tab in the **Prometheus** UI should be able to see the newly added exporter or if you configured it with nodePort, the interface of the scraper may also be accessible.


### 5. Grafana dashboard initialization:

**5.1.** After your **Grafana** can be accessed through the browser, either with **NodePort** or **Ingress**, you will need to login to the UI with **username**:```admin```, **password**:```prom-operator```.

**5.2.** Now you can enter the **Dashboard** section of **Grafana** and start creating your own dashboards using the appropriate **scraping variables** of the exporter.

**5.2.** Use the official guide of [MongoDB Documentation](https://www.mongodb.com/docs/manual/), the [query functions of **Prometheus**](https://prometheus.io/docs/prometheus/latest/querying/functions/) and guides on the web to be able to use the appropriate **scraping variables** for your dashboard visualization.

# Photos:
![Screenshot from 2024-05-06 17-56-07](https://github.com/VadimV1/Monitoring-experiment/assets/20540663/6bba1991-7e9a-406e-81ab-433f62708b64)
![Screenshot from 2024-05-06 17-55-56](https://github.com/VadimV1/Monitoring-experiment/assets/20540663/4e2a853a-114a-460f-b472-33af3b2929cd)




