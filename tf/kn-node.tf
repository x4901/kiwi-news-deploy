
# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Get pre-defined SSH key
data "hcloud_ssh_key" "ssh_key_1" {
  name = "${var.ssh_keyname}"
}

# Get the cloud config and render it
data "template_file" "init" {
  template = "${file("${path.module}/cloud-config.yaml")}"
  vars = {
    public_ssh_key = "${var.pub_ssh}"
  }
}
data "cloudinit_config" "cloudinit_knnode" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = data.template_file.init.rendered
  }
}

# Create KN node
resource "hcloud_server" "srv_knnode" {
    name        = "kn-node"
    image       = "ubuntu-22.04"
    server_type = "cx22"
    location    = "hel1"
    ssh_keys    =  [ data.hcloud_ssh_key.ssh_key_1.id ]
    user_data   = data.cloudinit_config.cloudinit_knnode.rendered    
    public_net {
      ipv4_enabled = true
      ipv6_enabled = true
    }  
}

# Generate the inventory file
resource "ansible_host" "knnode_1" {
  name   = "kn-node"
  #groups = ["kn"] # Groups this host is part of.
  variables = {
    # Connection vars.
    ansible_user = "knuser" # Default user depends on the OS.
    ansible_host = hcloud_server.srv_knnode.ipv4_address # IP address of the host.
    ansible_ssh_private_key_file = "~/.ssh/id_rsa" # Path to the SSH private key used
  }
}
