Scheduling Pods with Taints and Tolerations in Kubernetes
In this hands-on lab, we have been given a three-node cluster. Within that cluster, we must perform the following tasks to taint the production node in order to repel work. We will create the necessary taint to properly label one of the nodes “prod.” Then, we will deploy two pods — one to each environment. One pod spec will contain the toleration for the taint.

Solution
Log in to the Master server using the credentials on the lab page (either in your local terminal, using the Instant Terminal feature, or using the public IPs):

ssh cloud_user@<KUBE_MASTER_PUBLIC_IP_ADDRESS>
Hint: When copying and pasting code into Vim from the lab guide, first enter :set paste (and then i to enter insert mode) to avoid adding unnecessary spaces and hashes.

Taint one of the worker nodes to repel work.
List out the nodes:

kubectl get nodes
Taint the node, replacing <NODE_NAME> with one of the worker node names returned in the previous command:

kubectl taint node <NODE_NAME> node-type=prod:NoSchedule
Schedule a pod to the dev environment.
Create the dev-pod.yaml file:

vim dev-pod.yaml
Enter the following YAML to specify a pod that will be scheduled to the dev environment:

apiVersion: v1
kind: Pod
metadata:
  name: dev-pod
  labels:
    app: busybox
spec:
  containers:
  - name: dev
    image: busybox
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
Save and quit the file by pressing Escape followed by wq!.

Create the pod:

kubectl create -f dev-pod.yaml
Schedule a pod to the prod environment.
Create the prod-deployment.yaml file:

vim prod-deployment.yaml
Enter the following YAML to specify a pod that will be scheduled to the prod environment:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prod
  template:
    metadata:
      labels:
        app: prod
    spec:
      containers:
      - args:
        - sleep
        - "3600"
        image: busybox
        name: main
      tolerations:
      - key: node-type
        operator: Equal
        value: prod
        effect: NoSchedule
Save and quit the file by pressing Escape followed by wq!.

Create the pod:

kubectl create -f prod-deployment.yaml
Verify each pod has been scheduled to the correct environment.
Verify the pods have been scheduled:

kubectl get pods -o wide
Scale up the deployment:

kubectl scale deployment/prod --replicas=3
Look at our deployment again:

kubectl get pods -o wide
We should see that two more pods have been deployed.

Conclusion