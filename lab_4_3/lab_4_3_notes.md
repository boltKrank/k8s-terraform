Performing a Rolling Update of an Application in Kubernetes
In this hands-on lab, we have been given a three-node cluster. Within that cluster, we must deploy our application and then successfully update the application to a new version without causing any downtime.

Log in to the Kube Master server using the credentials on the lab page (either in your local terminal, using the Instant Terminal feature, or using the public IPs), and work through the objectives listed.

Create and roll out version 1 of the application, and verify a successful deployment.
Use the following YAML named kubeserve-deployment.yaml to create your deployment:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubeserve
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kubeserve
  template:
    metadata:
      name: kubeserve
      labels:
        app: kubeserve
    spec:
      containers:
      - image: linuxacademycontent/kubeserve:v1
        name: app
Create the deployment:

kubectl apply -f kubeserve-deployment.yaml --record
Verify the deployment was successful:

kubectl rollout status deployments kubeserve
Verify the app is at the correct version:

kubectl describe deployment kubeserve
Scale up the application to create high availability.
Scale up your application to five replicas:

kubectl scale deployment kubeserve --replicas=5
Verify the additional replicas have been created:

kubectl get pods
Create a service, so users can access the application.
Create a service for your deployment:

kubectl expose deployment kubeserve --port 80 --target-port 80 --type NodePort
Verify the service is present, and collect the cluster IP:

kubectl get services
Verify the service is responding:

curl http://&lt;ip-address-of-the-service>
Perform a rolling update to version 2 of the application, and verify its success.
Start another terminal session to the same Kube Master server. There, use this curl loop command to see the version change as you perform the rolling update:

while true; do curl http://&lt;ip-address-of-the-service>; done
Perform the update in the original terminal session (while the curl loop is running in the new terminal session):

kubectl set image deployments/kubeserve app=linuxacademycontent/kubeserve:v2 --v 6
View the additional ReplicaSet created during the update:

kubectl get replicasets
Verify all pods are up and running:

kubectl get pods
View the rollout history:

kubectl rollout history deployment kubeserve
Conclusion