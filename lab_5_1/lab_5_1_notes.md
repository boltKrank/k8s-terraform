Creating Persistent Storage for Pods in Kubernetes
In this hands-on lab, to decouple our storage from our pods, we will create a persistent volume to mount for use by our pods. We will deploy a redis image. We will first create the persistent volume, then create the pod YAML for deploying the pod to mount the volume. We will then delete the pod and create a new pod, which will access that same volume.

Log in to the Kube Master server using the credentials on the lab page (either in your local terminal, using the Instant Terminal feature, or using the public IP), and work through the objectives listed.

Create a PersistentVolume.
Create the file, named redis-pv.yaml:

vim redis-pv.yaml
Use the following YAML spec for the PersistentVolume:

apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv
spec:
  storageClassName: ""
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
Then, create the PersistentVolume:

kubectl apply -f redis-pv.yaml
Create a PersistentVolumeClaim.
Create the file, named redis-pvc.yaml:

vim redis-pvc.yaml
Use the following YAML spec for the PersistentVolumeClaim:

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redisdb-pvc
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
Then, create the PersistentVolumeClaim:

kubectl apply -f redis-pvc.yaml
Create a pod from the redispod image, with a mounted volume to mount path /data.
Create the file, named redispod.yaml:

vim redispod.yaml
Use the following YAML spec for the pod:

apiVersion: v1
kind: Pod
metadata:
  name: redispod
spec:
  containers:
  - image: redis
    name: redisdb
    volumeMounts:
    - name: redis-data
      mountPath: /data
    ports:
    - containerPort: 6379
      protocol: TCP
  volumes:
  - name: redis-data
    persistentVolumeClaim:
      claimName: redisdb-pvc
Then, create the pod:

kubectl apply -f redispod.yaml
Verify the pod was created:

kubectl get pods
Connect to the container and write some data.
Connect to the container and run the redis-cli:

kubectl exec -it redispod redis-cli
Set the key space server:name and value "redis server":

SET server:name "redis server"
Run the GET command to verify the value was set:

GET server:name
Exit the redis-cli:

QUIT
Delete redispod and create a new pod named redispod2.
Delete the existing redispod:

kubectl delete pod redispod
Open the file redispod.yaml and change line 4 from name: redispod to:

name: redispod2
Create a new pod named redispod2:

kubectl apply -f redispod.yaml
Verify the volume has persistent data.
Connect to the container and run redis-cli:

kubectl exec -it redispod2 redis-cli
Run the GET command to retrieve the data written previously:

GET server:name
Exit the redis-cli:

QUIT
Conclusion
Congratulations on completing this lab!