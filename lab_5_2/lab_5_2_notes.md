Creating a ClusterRole to Access a PV in Kubernetes
In this hands-on lab, you will be tasked with accessing a persistent volume from a pod in order to view the available volumes inside the Kubernetes cluster. By default, pods cannot access volumes directly, so you will also need to create a cluster role to provide authorization to the pod. Additionally, you cannot access the API server directly without authentication, so you will need to run kubectl in proxy mode to retrieve information about the volumes.

Solution
Log in to the provided lab server using the credentials provided:

ssh cloud_user@<PUBLIC_IP_ADDRESS>
View the Persistent Volume
View the Persistent Volume within the cluster:

kubectl get pv
Create a ClusterRole
Create the ClusterRole:

kubectl create clusterrole pv-reader --verb=get,list --resource=persistentvolumes
Create a ClusterRoleBinding
Create the ClusterRoleBinding:

kubectl create clusterrolebinding pv-test --clusterrole=pv-reader --serviceaccount=web:default
Create a Pod to Access the PV
Create the curlpod.yaml file:

vim curlpod.yaml
Add the following YAML to create a pod that will proxy the connection and allow you to curl the address:

apiVersion: v1
kind: Pod
metadata:
  name: curlpod
  namespace: web
spec:
  containers:
  - image: tutum/curl
    command: ["sleep", "9999999"]
    name: main
  - image: linuxacademycontent/kubectl-proxy
    name: proxy
  restartPolicy: Always
Save and exit the file by pressing Escape followed by :wq.

Create the pod:

kubectl apply -f curlpod.yaml
Request Access to the PV from the Pod
Open a new shell to the pod:

kubectl exec -it curlpod -n web -- sh
If it doesn't work immediately, wait a minute or so and then run the command again.

Curl the PV resource:

curl localhost:8001/api/v1/persistentvolumes
Conclusion
Congratulations on completing this lab!