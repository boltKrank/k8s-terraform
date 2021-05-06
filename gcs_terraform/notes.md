# GCS Terraform

Uses terraform and GCP to deploy a full puppet enterprise stack.

Most of the variables you'll need to mess around with are in terraform.tfvars but there might be some dangling ones that I've not cleaned up yet.

You will need to have your GCP creds in place (default ~/.config/gcloud/application_default_credentials.json), which can be created using the gcloud SDK.

The command to create these credentials is:

gcloud auth application-default login

*NOTE: On Windows machines, the default path is ${HOME}\AppData\Roaming\gcloud\application_default_credentials.json
Tunables*

You can set the number of client machines (vars.clients) and control if splunk, metrics dashboard, cd4pe, HA replica, compliers, comply etc are deployed. Check the variables.tf for the list
How to

- terraform init
- terraform apply

Sit and wait.

Takes a while to run up the base environment (30-40 mins)
