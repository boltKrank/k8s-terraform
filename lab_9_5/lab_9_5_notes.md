15
15
00:03
/
02:18
video 1 of 2
Inroduction
This video introduces the scenario for this learning activity and points you to some additional resources that can help you complete it.
Bootstrapping a Kubernetes Control Plane
Introduction

In order to configure a Kubernetes cluster, we need to be able to set up a Kubernetes control plane. The control plane manages the Kubernetes cluster and serves as its primary interface.

In this hands-on lab, we're going to set up a distributed Kubernetes control plane using two servers.

To do this, we will install and configure the following services:

    kube-apiserver
    kube-controller-manager
    kube-scheduler
    kubectl

Log In to the Environment
Log In to the Controller 0 Server

    On the lab instructions page, copy the Controller 0 Public IP address to your clipboard.

    Open your terminal application and run the following command:

    ssh cloud_user@<CONTROLLER_0_PUBLIC_IP_ADDRESS>

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

Log In to the Controller 1 Server

    On the lab instructions page, copy the Controller 1 Public IP address to your clipboard.
    Open a new window of your terminal application and run the following command:

    ssh cloud_user@<CONTROLLER_1_PUBLIC_IP_ADDRESS>

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

We are now successfully logged in to the cloud server environment.
Download and Install the Binaries

Complete the following steps in both of your terminal windows:

    Create the /etc/kubernetes/config directory:

    sudo mkdir -p /etc/kubernetes/config

    Enter your cloud_user password at the prompt.

    Download the service binaries:

    wget -q --show-progress --https-only --timestamping \
      "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-apiserver" \
      "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-controller-manager" \
      "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-scheduler" \
      "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl"

    Run the following command to make the binaries executable:

    chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl

    Move the files we just downloaded to the /usr/local/bin directory:

    sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

Configure the kube-apiserver Service

Complete the following steps in both of your terminal windows:

    Create the /var/lib/kubernetes directory:

    sudo mkdir -p /var/lib/kubernetes/

    List the contents of the home directory to view the certificate and kubeconfig files we need to set up our Kubernetes control plane:

    ls

    Move all the .pem files and the encryption-config.yaml file to the /var/lib/kubernetes directory:

    sudo cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
      service-account-key.pem service-account.pem \
      encryption-config.yaml /var/lib/kubernetes/

    Set the INTERNAL_IP environment variable:

    INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

    Set the following environment variables (be sure to replace the placeholders with the actual private IPs):

    ETCD_SERVER_0=<CONTROLLER_0_PRIVATE_IP>
    ETCD_SERVER_1=<CONTROLLER_1_PRIVATE_IP>

    Create the systemd unit file for kube-apiserver:

    cat << EOF | sudo tee /etc/systemd/system/kube-apiserver.service
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=/usr/local/bin/kube-apiserver \\
      --advertise-address=${INTERNAL_IP} \\
      --allow-privileged=true \\
      --apiserver-count=3 \\
      --audit-log-maxage=30 \\
      --audit-log-maxbackup=3 \\
      --audit-log-maxsize=100 \\
      --audit-log-path=/var/log/audit.log \\
      --authorization-mode=Node,RBAC \\
      --bind-address=0.0.0.0 \\
      --client-ca-file=/var/lib/kubernetes/ca.pem \\
      --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
      --enable-swagger-ui=true \\
      --etcd-cafile=/var/lib/kubernetes/ca.pem \\
      --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
      --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
      --etcd-servers=https://${ETCD_SERVER_0}:2379,https://${ETCD_SERVER_1}:2379 \\
      --event-ttl=1h \\
      --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
      --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
      --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
      --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
      --kubelet-https=true \\
      --runtime-config=api/all \\
      --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
      --service-cluster-ip-range=10.32.0.0/24 \\
      --service-node-port-range=30000-32767 \\
      --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
      --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
      --v=2 \\
      --kubelet-preferred-address-types=InternalIP,InternalDNS,Hostname,ExternalIP,ExternalDNS
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    EOF

Configure the kube-controller-manager Service

Complete the following steps in both of your terminal windows:

    Move the kube-controller-manager.kubeconfig file to the /var/lib/kubernetes directory:

    sudo mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

    Create the systemd unit control file for kube-controller-manager:

    cat << EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
    [Unit]
    Description=Kubernetes Controller Manager
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=/usr/local/bin/kube-controller-manager \\
      --address=0.0.0.0 \\
      --cluster-cidr=10.200.0.0/16 \\
      --cluster-name=kubernetes \\
      --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
      --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
      --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
      --leader-elect=true \\
      --root-ca-file=/var/lib/kubernetes/ca.pem \\
      --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
      --service-cluster-ip-range=10.32.0.0/24 \\
      --use-service-account-credentials=true \\
      --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    EOF

Configure the kube-scheduler Service

Complete the following steps in both of your terminal windows:

    Move the kube-scheduler.kubeconfig file to the /var/lib/kubernetes directory:

    sudo mv kube-scheduler.kubeconfig /var/lib/kubernetes/

    Create the kube-scheduler config file:

    cat << EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
    apiVersion: componentconfig/v1alpha1
    kind: KubeSchedulerConfiguration
    clientConnection:
      kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
    leaderElection:
      leaderElect: true
    EOF

    Create the systemd unit file for kube-scheduler:

    cat << EOF | sudo tee /etc/systemd/system/kube-scheduler.service
    [Unit]
    Description=Kubernetes Scheduler
    Documentation=https://github.com/kubernetes/kubernetes

    [Service]
    ExecStart=/usr/local/bin/kube-scheduler \\
      --config=/etc/kubernetes/config/kube-scheduler.yaml \\
      --v=2
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    EOF

Start All of the Services

Complete the following steps in both of your terminal windows:

    Enable and start the Kubernetes control plane services:

    sudo systemctl daemon-reload

    sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler

    sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler

    Run the following command to verify everything is working properly:

    kubectl get componentstatuses --kubeconfig admin.kubeconfig

    The output should look something like this:

    NAME                 STATUS    MESSAGE              ERROR
    controller-manager   Healthy   ok
    scheduler            Healthy   ok
    etcd-0               Healthy   {"health": "true"}
    etcd-1               Healthy   {"health": "true"}

Enable HTTP Health Checks

Complete the following steps in both of your terminal windows:

    Install Nginx:

    sudo apt-get install -y nginx

    Create an Nginx config file:

    cat > kubernetes.default.svc.cluster.local << EOF
    server {
      listen      80;
      server_name kubernetes.default.svc.cluster.local;

      location /healthz {
         proxy_pass                    https://127.0.0.1:6443/healthz;
         proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
      }
    }
    EOF

    Move the Nginx config file to the /etc/nginx/sites-available directory:

    sudo mv kubernetes.default.svc.cluster.local \
      /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

    Create a symlink in the /sites-enabled directory:

    sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/

    Start and enable Nginx:

    sudo systemctl restart nginx

    sudo systemctl enable nginx

    Verify the HTTP health checks are working:

    curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz

    This should return a 200 OK status code.

Set Up RBAC for Kubelet Authorization

Complete the following steps in one of your terminal windows:

    Note: It's okay if you complete these steps in both of your terminal windows ??? the lab will still work. It just isn't a requirement to do so.

    Create a cluster role to allow the kubernetes-apiservice to access the kubelets:

      cat << EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
      apiVersion: rbac.authorization.k8s.io/v1beta1
      kind: ClusterRole
      metadata:
        annotations:
          rbac.authorization.kubernetes.io/autoupdate: "true"
        labels:
          kubernetes.io/bootstrapping: rbac-defaults
        name: system:kube-apiserver-to-kubelet
      rules:
        - apiGroups:
            - ""
          resources:
            - nodes/proxy
            - nodes/stats
            - nodes/log
            - nodes/spec
            - nodes/metrics
          verbs:
            - "*"
      EOF

    Assign the role to the kube-apiserver user:

    cat << EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: system:kube-apiserver
      namespace: ""
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: system:kube-apiserver-to-kubelet
    subjects:
      - apiGroup: rbac.authorization.k8s.io
        kind: User
        name: kubernetes
    EOF

Conclusion

Congratulations, you've successfully completed this hands-on lab!