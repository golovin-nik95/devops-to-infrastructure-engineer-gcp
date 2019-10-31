# GCP
Capstone project of the course "DevOps to Infrastructure Engineer - GCP" at Grid Dynamics

## Prerequisites

### Software

You should have installed on the host machine:

* terraform v0.12+

* ansible v2.8+

* requests and google-auth python libraries 

### Service accounts

You should have the following service accounts in GCP:

* Terraform service account that you can set up at the link below
`https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform`

* Ansible service account that you can set up at the link below
`https://programmaticponderings.com/2019/01/30/getting-started-with-red-hat-ansible-for-google-cloud-platform`

## Terraform provisioning

Before running terraform, you need to set up the required environment variables. 
This can be done either in the file `terraform/terraform.tfvars` or via command `export TF_VAR_<variable_name>=<variable_value>`.
A list of required environment variables is given below:

* project_id - GCP project ID
* region - Provisioning region
* ssh_user - Username to be used for ansible provisioning
* ssh_pub_key_file - Public key of the user connected via SSH

In case you want to use the remote state for terraform, you need to provide GS bucket 
and set it's name in the field `bucket` of the file `terraform/backend.tf`

Finally, run `terraform init` to initialize the configuration and `terraform apply` to provision GCP resources

## Ansible provisioning

Before running ansible, you need to set up the required environment variables.
This can be done in the files `ansible/ansible.cfg` and `ansible/inventory.compute.gcp.yml`.
A list of required environment variables is given below:

`# ansible/ansible.cfg`
* remote_user - Username to be used for ansible provisioning
* private_key_file - Private key of the user connected via SSH

`# ansible/inventory.compute.gcp.yml`
* projects - GCP project ID
* service_account_file - Json key of the Ansible service account

Finally, run `ansible-playbook -i inventory.compute.gcp.yml apache-http-server.yml` to provision Apache HTTP Server to the GCP VM instances

## How to check

To check load balancer work you need to open GCP Dashboard and then select the menu item `Network services > Load balancing`.
In the appeared window select the tab `Frontends`, open the address specified in the forwarding rule `http-server-global-forwarding-rule` in the browser, 
and refresh the page several times
