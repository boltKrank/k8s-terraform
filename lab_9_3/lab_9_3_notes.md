Generating a Data Encryption Config for Kubernetes
Introduction

Kubernetes offers the ability to encrypt sensitive data at rest. In order to take advantage of this feature, it is necessary to generate an encryption key and a data encryption config. In this hands-on lab, you will learn how to generate an encryption key and a data encryption config file for Kubernetes.
Log In to the Environment

We'll start by logging in to the Workspace server.

    Navigate to the lab instructions page, and copy the public IP address for the Workspace server to your clipboard.
    Open your terminal application and run the following command (remember to replace the placeholder with the actual public IP address of the Workspace server):

ssh cloud_user@&ltPUBLIC_IP_ADDRESS&gt

    Type yes at the prompt.
    Enter your password from the lab instructions page when prompted.

We are now successfully logged in to the environment.
Generate an Encryption Key and Include It in a Kubernetes Data Encryption Config File

The first step is to create an encryption key. We will also set it to an environment variable so we can include the encryption key in our config file.

    Run the following command to generate the random string we'll use for our encryption key:

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

    Use the echo command to view the random string we just generated.

echo $ENCRYPTION_KEY

    Then, use the following command to generate our config file:

cat > encryption-config.yaml << EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

Copy the File to the Kubernetes Controller Servers

The next step is to copy encryption-config.yaml to each Kubernetes controller server.

    Go back to the lab instructions page, and copy the public IP address for Controller 0.
    Then run the following command (be sure to replace the placeholder with the actual IP address of Controller 0):

scp encryption-config.yaml cloud_user@&ltCONTROLLER0_PUBLIC_IP&gt:~/

    Type yes at the prompt.
    Enter your password when prompted.
    Then, run the following command to copy the encryption config file to the Controller 1 server (be sure to replace the placeholder with the actual IP address of Controller 1:

scp encryption-config.yaml cloud_user@&ltCONTROLLER1_PUBLIC_IP&gt:~/

    Type yes at the prompt.
    Enter your password when prompted.

Conclusion