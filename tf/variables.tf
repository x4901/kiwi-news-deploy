terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.3"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
  required_version = ">= 0.13"
}

variable "pub_ssh" {
    type = string
    default = ""
}

variable "hcloud_token" {
    type = string
    default = ""
}

variable "ssh_keyname" {
    type = string
    default = ""
}

output "knnode_ip4" {
  value = hcloud_server.srv_knnode.ipv4_address
}

output "cloudinit" {
  value = data.cloudinit_config.cloudinit_knnode
}

