Making 2 node k8s cluster:
- 1 master, 2 workers

STEPS:

Install needed packages:
1. Install docker on all machines.
2. Install kubelet
3. Install kubeadm
4. Install kubectl

Setup k8s cluster:
1. kubeadm init --pod-network-cidr=10.244.0.0/16 (Only run on master)

Setup kube config:
1. Using commands from the output of the previous command
  - mkdir -p $HOME/.kube
  - sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  - sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
Check cluster setup:
- run kubectl version (if it returns both server and client version, client has been setup correctly)

Join worker nodes to the master:
- copy the command from the output: kubeadm join 10.0.1.101:6443 --token ...

Check nodes are appearing in list:
- kubectl get nodes
NOTE: Status will say "NotReady" since networking hasn't been setup.

iptables bridge calls needs to be run on all machines.

add:
- net.bridge.bridge-nf-call-iptable=1 to /etc/sysctl.conf
- run sudo sysctl -p (to update the config immediately)

On master node:
- kubectl apply -f <github.file:kube-flannel.yml>

Once this is done - all nodes should be ready (master may take some time).