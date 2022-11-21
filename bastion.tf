################## Creates a VM for SSH access #################

resource "digitalocean_droplet" "bastion" {
  image    = "rockylinux-9-x64"
  name     = "bastion-${var.region}"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.lab_ssh_key.id]
  vpc_uuid = digitalocean_vpc.assignment_vpc.id
}
################## Sets Firwall for VM #################
resource "digitalocean_firewall" "bastion" {
  
  name = "bastion-firewall"

  droplet_ids = [digitalocean_droplet.bastion.id]
  # Enable SSH from the web incoming
  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  # Enable SSH outbound to all devices within the vpc
  outbound_rule {
    protocol = "tcp"
    port_range = "22"
    destination_addresses = [digitalocean_vpc.assignment_vpc.ip_range]
  }
  # Enable ICMP/ping to all devices within the VPC
  outbound_rule {
    protocol = "icmp"
    destination_addresses = [digitalocean_vpc.assignment_vpc.ip_range]
  }
}

resource "digitalocean_project_resources" "attach_bastion" {
    project = data.digitalocean_project.lab_project.id
    resources = digitalocean_droplet.bastion.*.urn
}