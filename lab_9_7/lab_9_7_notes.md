Setting Up Kubernetes Networking with Weave Net
Introduction

In this lab, we'll configure a Kubernetes pod network using Weave Net. After completing the lab, you will have hands-on experience implementing networking within a Kubernetes cluster.

To start, open two terminal windows and log in to both worker nodes using the public IPs and credentials listed on the lab page. Note: We're going to run all the commands on both servers simultaneously throughout the entire lab.
Enable IP Forwarding on All Worker Nodes

In order for Weave Net to work, we need to make sure IP forwarding is enabled on the worker nodes. Enable it by running the following on both workers:

sudo sysctl net.ipv4.conf.all.forwarding=1

echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

Install Weave Net in the Cluster

Log in to the controller server in a new terminal window, and then do the following:

    Install Weave Net using a configuration from Weaveworks like this:

    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.200.0.0/16"

    Verify that everything is working:

    kubectl get pods -n kube-system

    This should return two `weave-net` pods and look something like this:

    ```
    NAME              READY     STATUS    RESTARTS   AGE
    weave-net-m69xq   2/2       Running   0          11s
    weave-net-vmb2n   2/2       Running   0          11s
    ```

3. Spin up some pods to test the networking functionality (be careful that you are not pasting in invisible characters such as spaces and tabs when copy/pasting):

    a. First, create an Nginx deployment with 2 replicas:

    ```
    cat << EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
       apiVersion: apps/v1
       kind: Deployment
       metadata:
         name: nginx
       spec:
         selector:
           matchLabels:
             run: nginx
         replicas: 2
         template:
           metadata:
             labels:
               run: nginx
           spec:
             containers:
             - name: my-nginx
               image: nginx
               ports:
               - containerPort: 80
    EOF
    ```

    b. Next, create a service for that deployment so that we can test connectivity to services as well:

    ```
    kubectl expose deployment/nginx
    ```

    c. Start up another pod. We will use this pod to test our networking. We will test whether we can connect to the other pods and services from this pod.

    ```
    kubectl run busybox --image=radial/busyboxplus:curl --command -- sleep 3600 POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
    ```

    d. Get the IP addresses of our two `nginx` pods:

    ```
    kubectl get ep nginx
    ```

    There should be two IP addresses listed under `ENDPOINTS`. For example:

    ```
    NAME      ENDPOINTS                       AGE
    nginx     10.200.0.2:80,10.200.128.1:80   50m
    ```

4. Make sure the `busybox` pod can connect to the `nginx` pods on both of those IP addresses.

    ```
    kubectl exec $POD_NAME -- curl &lt;first nginx pod IP address&gt;
    
    kubectl exec $POD_NAME -- curl &lt;second nginx pod IP address&gt;
    ```

    Both commands should return some HTML with the title `"Welcome to Nginx!"` This means that we can successfully connect to other pods.

5. Now let's verify that we can connect to services.

    ```
    kubectl get svc
    ```

    This should display the IP address for our Nginx service. For example, in this case, the IP is `10.32.0.54`:

    ```
    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.32.0.1    <none>        443/TCP   1h
    nginx        ClusterIP   10.32.0.54   <none>        80/TCP    53m
    ```

6. Check that we can access the service from the `busybox` pod.
    
    ```
    kubectl exec $POD_NAME -- curl &lt;nginx service IP address&gt;
    ```

    This should also return HTML with the title `"Welcome to nginx!"`

Getting this response means that we have successfully reached the Nginx service from inside a pod and that our networking configuration is working!

## Conclusion

Congratulations on completing this lab!