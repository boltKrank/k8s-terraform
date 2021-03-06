Bootstrapping an etcd Cluster for Kubernetes
Introduction

Kubernetes uses etcd to reliably store data in a distributed fashion. One of the necessary steps for setting up a Kubernetes cluster from scratch is to configure an etcd cluster that spans all of the Kubernetes control nodes.

In this hands-on lab, we will install and configure an etcd cluster.
Log In to the Environment
Log In to the Controller0 Server

    Navigate to the lab instructions page, and copy the Controller0 Public IP address to your clipboard.
    Open your terminal application and run the following command:

    ssh cloud_user@&lt;CONTROLLER0_PUBLIC_IP_ADDRESS&gt;

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

Log In to the Controller1 Server

    Go back to the lab instructions page, and copy the Controller1 Public IP address to your clipboard.
    Open a new window of your terminal application and run the following command:

    ssh cloud_user@&lt;CONTROLLER1_PUBLIC_IP_ADDRESS&gt;

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

We are now successfully logged in to the cloud server environment.
Install the etcd Binary on Both Control Nodes

    In your first terminal window, run the following command to download the etcd archive:

    wget -q --show-progress --https-only --timestamping \
      "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz"

    Extract the etcd archive.

    tar -xvf etcd-v3.3.5-linux-amd64.tar.gz

    Move the extracted files to the /usr/local/bin/ directory.

    sudo mv etcd-v3.3.5-linux-amd64/etcd* /usr/local/bin/

    Enter your password at the prompt.
    Repeat these steps in your second terminal window.

Configure and Start the etcd Service on Both Control Nodes

    In your first terminal window, run the following command to create the /etc/etcd and /var/lib/etcd directories:

    sudo mkdir -p /etc/etcd /var/lib/etcd

    List the contents of the home directory to view the certificate and key files we'll need to configure and run the etcd service.

    ls

    Copy the ca.pem, kubernetes-key.pem, and kubernetes.pem files to the /etc/etcd/ directory.

    sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

    Set the following environment variables

        NOTE: Be sure to replace the placeholders with their actual values, paying special attention to the correct controller name for the controller you are setting the variables for:

        ETCD_NAME=<REPLACE WITH controller-0 OR controller-1>
        INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
        CONTROLLER_0_INTERNAL_IP=&lt;CONTROLLER0_PRIVATE_IP&gt;
        CONTROLLER_1_INTERNAL_IP=&lt;CONTROLLER1_PRIVATE_IP&gt;

    Create the ectd systemd unit file.

    cat << EOF | sudo tee /etc/systemd/system/etcd.service
    [Unit]
    Description=etcd
    Documentation=https://github.com/coreos

    [Service]
    ExecStart=/usr/local/bin/etcd \\
      --name ${ETCD_NAME} \\
      --cert-file=/etc/etcd/kubernetes.pem \\
      --key-file=/etc/etcd/kubernetes-key.pem \\
      --peer-cert-file=/etc/etcd/kubernetes.pem \\
      --peer-key-file=/etc/etcd/kubernetes-key.pem \\
      --trusted-ca-file=/etc/etcd/ca.pem \\
      --peer-trusted-ca-file=/etc/etcd/ca.pem \\
      --peer-client-cert-auth \\
      --client-cert-auth \\
      --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
      --listen-peer-urls https://${INTERNAL_IP}:2380 \\
      --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
      --advertise-client-urls https://${INTERNAL_IP}:2379 \\
      --initial-cluster-token etcd-cluster-0 \\
      --initial-cluster controller-0=https://${CONTROLLER_0_INTERNAL_IP}:2380,controller-1=https://${CONTROLLER_1_INTERNAL_IP}:2380 \\
      --initial-cluster-state new \\
      --data-dir=/var/lib/etcd
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    EOF

    Enable and start the etcd service.

    sudo systemctl daemon-reload
    sudo systemctl enable etcd
    sudo systemctl start etcd

    Verify that the etcd cluster is working correctly.

    sudo ETCDCTL_API=3 etcdctl member list \
      --endpoints=https://127.0.0.1:2379 \
      --cacert=/etc/etcd/ca.pem \
      --cert=/etc/etcd/kubernetes.pem \
      --key=/etc/etcd/kubernetes-key.pem

    Repeat these steps in your second terminal window. (Be sure to replace controller-0 with controller-1 in the first line of the command in Step 4.)

Conclusion

Congratulations, you've successfully completed this hands-on lab!