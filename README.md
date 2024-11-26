# Initializing a Kiwi News node

Using Terraform to create a VM and Ansible scripts to install and run the [Kiwi News](https://news.kiwistand.com/) app. 
Each node participates in the decentralized *Kiwi News* network for crypto-related news.

## Creating a VM with Terraform

This example uses the Hetzner Cloud, but since the requirements are minimal, other providers could be used easily instead.

The recipe creates one small VM with 4GB RAM and 40GB disk space. 

```sh
cd tf
terraform init                  # Initialize and download providers
terraform plan                  # Check to see if your defintiions are ok
terraform apply -auto-approve   # Create the resources
```

Terraform will respond with the IP address of the created VM:

> knnode_ip4 = "XXX.XXX.XXX.XXX"


## Adding the Kiwi News software with Ansible

### Install the required Ansible modules

```sh
cd ansible
ansible-galaxy install -r requirements.yml
```

### Check the Ansible inventory for the new node

Due to our configuration, Ansible can access information about the resources we just created.

Executing

```sh
cd ansible
ansible-inventory -i terraform.yml --graph --vars
```

should produce something like this:

```sh
@all:
  |--@ungrouped:
  |  |--kn-node
  |  |  |--{ansible_host = XX.XXX.XXX.XX}
  |  |  |--{ansible_ssh_private_key_file = ~/.ssh/id_rsa}
  |  |  |--{ansible_user = knuser}
```

### Install node.js

```sh
ansible-playbook nodejs-playbook
```

This playbook installs Node JS, NPM and PM2.


### Install the Kiwi News software

```sh
cp vars-template.yml vars.yml
# edit vars.yml to add your Alchemy API key
ansible-playbook kiwistand-playbook
```

Installs the Kiwi News app and installs all dependencies.

## Run the Kiwi News app

Initialize the database by running the sync script for some time:

```sh
npm run sync
```

Cancel the script and start the app:

```sh
pm2 start ecosystem.config.js
```


