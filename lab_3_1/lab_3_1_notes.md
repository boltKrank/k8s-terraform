Deploying a Pod to a Node with a Label in Kubernetes
We have been given a Kubernetes cluster to inspect. In order to better understand the layout and the structure of this cluster, we must run the appropriate commands.

Log in to the Kube Master server using the credentials on the lab page (either in your local terminal, using the Instant Terminal feature, or using the public IP), and work through the objectives listed.

List all the nodes in the cluster.
Use the following command to list the nodes in your cluster:

kubectl get nodes
We should see three nodes: one master and two workers.

List all the pods in all namespaces.
Use the following command to list the pods in all namespaces:

kubectl get pods --all-namespaces
List all the namespaces in the cluster.
Use the following command to list all the namespaces in the cluster:

kubectl get namespaces
Here, we should see four namespaces: default, kube-public, kube-system, and kube-node-lease.

Check to see if there are any pods running in the default namespace.
Use the following command to list the pods in the default namespace:

kubectl get pods
We should see that there aren't any pods in the default namespace.

Find the IP address of the API server running on the master node.
Use the following command to find the IP address of the API server:

kubectl get pods --all-namespaces -o wide
List the labels for all nodes in the cluster
Use the following command to list the labels for all nodes:

kubectl get no --show-labels
We should see the label disk=ssd for one of the nodes.

Create the pod YAML that will run on the node labeled disk=ssd
Create a file named pod.yaml (vi pod.yaml) and paste in the following:

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx
  nodeSelector:
    disk: ssd
Apply the YAML to the Kubernetes cluster with the following command:

kubectl apply -f pod.yaml
Verify that the pod is running on the correct node
Verify that pod is on correct node with the following command

kubectl get po -o wide
You should see the node with the label in the node column

Conclusion