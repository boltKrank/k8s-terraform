15
15
01:09
/
02:28
video 1 of 2
Introduction
This video introduces you to the scenario for this learning activity and provides you with some guidance on where to find additional information on how to complete the tasks.
Creating a Certificate Authority and TLS Certificates for Kubernetes
Introduction

The various components of Kubernetes require certificates in order to authenticate with one another. Provisioning a certificate authority and using it to generate those certificates is a necessary step in bootstrapping a Kubernetes cluster from scratch.

In this hands-on lab, we will provision a certificate authority and generate the certificates Kubernetes needs. We will complete the following tasks:

    Provision a certificate authority (CA)
    Generate Kubernetes client certificates and kubelet client certificates for two worker nodes
    Generate a Kubernetes API server certificate
    Generate a Kubernetes service account key pair

Log In to the Environment

    Note: The Workspace server already has cfssl installed, so there is no need to install it.

    Navigate to the lab instructions page, and copy the Workspace Public IP address to your clipboard.

    Open your terminal application and run the following command:

    ssh cloud_user@&lt;PUBLIC_IP_ADDRESS&gt;

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

We are now successfully logged in to the cloud server environment.
Provision the Certificate Authority (CA)

    Run the following commands to provision the certificate authority:

    {

    cat > ca-config.json << EOF
    {
      "signing": {
        "default": {
          "expiry": "8760h"
        },
        "profiles": {
          "kubernetes": {
            "usages": ["signing", "key encipherment", "server auth", "client auth"],
            "expiry": "8760h"
          }
        }
      }
    }
    EOF

    cat > ca-csr.json << EOF
    {
      "CN": "Kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "Kubernetes",
          "OU": "CA",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert -initca ca-csr.json | cfssljson -bare ca

    }

    List the contents of the home directory to view the certificate authority files we just created.

    ls

Generate the Kubernetes Client Certificates and Kubelet Client Certificates for Two Worker Nodes
Generate the Admin Client Certificate

    Run the following command to generate the admin client certificate:

    {

    cat > admin-csr.json << EOF
    {
      "CN": "admin",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:masters",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      admin-csr.json | cfssljson -bare admin

    }

    List the contents of the home directory to view the admin certificate files we just created.

    ls

Generate the Kubelet Client Certificates

    Run the following commands to generate the kubelet client certificates:

    {
    cat > worker0.mylabserver.com-csr.json << EOF
    {
      "CN": "system:node:worker0.mylabserver.com",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:nodes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=172.34.1.0,worker0.mylabserver.com \
      -profile=kubernetes \
      worker0.mylabserver.com-csr.json | cfssljson -bare worker0.mylabserver.com

    cat > worker1.mylabserver.com-csr.json << EOF
    {
      "CN": "system:node:worker1.mylabserver.com",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:nodes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=172.34.1.1,worker1.mylabserver.com \
      -profile=kubernetes \
      worker1.mylabserver.com-csr.json | cfssljson -bare worker1.mylabserver.com

    }

    List the contents of the home directory to view the kubelet client certificate files we just created.

    ls

Generate the Kube-Controller-Manager Client Certificate

    Run the following command to generate the client certificate for the kube-controller-manager:

    {

    cat > kube-controller-manager-csr.json << EOF
    {
      "CN": "system:kube-controller-manager",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:kube-controller-manager",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

    }

    List the contents of the home directory to view the kube-controller-manager certificate files we just created.

    ls

Generate the Kube-Proxy Client Certificate

    Run the following command to generate the client certificate for the kube-proxy:

    {

    cat > kube-proxy-csr.json << EOF
    {
      "CN": "system:kube-proxy",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:node-proxier",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-proxy-csr.json | cfssljson -bare kube-proxy

    }

    List the contents of the home directory to view the kube-proxy certificate files we just created.

    ls

Generate the Kube-Scheduler Client Certificate

    Run the following command to generate the client certificate for the kube-scheduler:

    {

    cat > kube-scheduler-csr.json << EOF
    {
      "CN": "system:kube-scheduler",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "system:kube-scheduler",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-scheduler-csr.json | cfssljson -bare kube-scheduler

    }

    List the contents of the home directory to view the kube-scheduler certificate files we just created.

    ls

Generate the Kubernetes API Server Certificate

    Run the following command to generate the Kubernetes API server certificate:

    {

    cat > kubernetes-csr.json << EOF
    {
      "CN": "kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "Kubernetes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=10.32.0.1,172.34.0.0,controller0.mylabserver.com,172.34.0.1,controller1.mylabserver.com,172.34.2.0,kubernetes.mylabserver.com,127.0.0.1,localhost,kubernetes.default \
      -profile=kubernetes \
      kubernetes-csr.json | cfssljson -bare kubernetes

    }

    List the contents of the home directory to view the Kubernetes API server certificate files we just created.

    ls

Generate a Kubernetes Service Account Key Pair

    Run the following command to generate a Kubernetes service account key pair:

    {

    cat > service-account-csr.json << EOF
    {
      "CN": "service-accounts",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "US",
          "L": "Portland",
          "O": "Kubernetes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Oregon"
        }
      ]
    }
    EOF

    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      service-account-csr.json | cfssljson -bare service-account

    }

    List the contents of the home directory to view the service account key pair files we just created.

    ls

Conclusion

Congratulations, you've successfully completed this hands-on lab!