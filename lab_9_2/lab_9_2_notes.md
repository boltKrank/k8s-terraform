Generating Kubeconfigs for a New Kubernetes Cluster
Introduction

To set up a new Kubernetes cluster from scratch, we need to provide various components of the cluster with kubeconfig files so that they can locate and authenticate with the Kubernetes API. In this lab, we are going to generate a set of kubeconfigs that can be used to build a Kubernetes cluster.

We are going to create kubeconfig files for the following:

    Kubelet (one kubeconfig for each worker node)
    Kube-proxy
    Kube-controller-manager
    Kube-scheduler
    Admin

We will be using the following cluster architecture:

Controllers:

    Hostname: controller0.mylabserver.com, IP: 172.34.0.0
    Hostname: controller1.mylabserver.com, IP: 172.34.0.1

Workers:

    Hostname: worker0.mylabserver.com, IP: 172.34.1.0
    Hostname: worker1.mylabserver.com, IP: 172.34.1.1

Kubernetes API Load Balancer:

    Hostname: kubernetes.mylabserver.com, IP: 172.34.2.0

Log In to the Environment

    Navigate to the lab instructions page, and copy the Workspace Public IP address to your clipboard.
    Open your terminal application and run the following command:

ssh cloud_user@&lt;PUBLIC_IP_ADDRESS&gt;

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

We are now successfully logged in to the cloud server environment.
Generate Kubelet Kubeconfigs for Each Worker Node

    List the contents of the home directory to view the certificates and keys we will use to generate our kubeconfig files.

ls

    Set an environment variable called KUBERNETES_PUBLIC_ADDRESS and set it equal to the IP address of the load balancer.

KUBERNETES_PUBLIC_ADDRESS=172.34.2.0

    Run the following commands to generate the kubeconfigs for the worker nodes:

for instance in worker0.mylabserver.com worker1.mylabserver.com; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

    List the contents of the home directory again to view the kubeconfig files we just created.

ls

Generate a Kube-Proxy Kubeconfig

    Set an environment variable called KUBERNETES_PUBLIC_ADDRESS and set it equal to the IP address of the load balancer. (Note: This should already be set in your environment. If it is, you don't need to repeat this step.)

KUBERNETES_PUBLIC_ADDRESS=172.34.2.0

    Run the following command to generate a kubeconfig for kube-proxy:

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

    List the contents of the home directory to view the kube-proxy kubeconfig file we just created.

ls

Generate a Kube-Controller-Manager Kubeconfig

    Run the following command to generate a kubeconfig for the kube-controller-manager:

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

    List the contents of the home directory to view the kube-controller-manager kubeconfig file we just created.

ls

Generate a Kube-Scheduler Kubeconfig

    Run the following command to generate a kubeconfig for kube-scheduler:

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}

    List the contents of the home directory to view the kube-scheduler kubeconfig file we just created.

ls

Generate an Admin Kubeconfig

    Run the following command to generate a kubeconfig for the admin user:

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

    List the contents of the home directory to view the admin kubeconfig file we just created.

ls

Conclusion

Congratulations, you've successfully completed this hands-on lab!