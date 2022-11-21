#####################Create tags##################
resource "digitalocean_tag" "do_tag" {
  name = "web-server"
}

###################Create a new VM#################
resource "digitalocean_droplet" "web" {
  image    = "rockylinux-9-x64"
  name     = "web-${count.index + 1}"
  count    = var.droplet_count
  tags     = [digitalocean_tag.do_tag.id]
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  vpc_uuid = digitalocean_vpc.assignment_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.lab_ssh_key.id]

  lifecycle {
    create_before_destroy = true
  }
}

# adds the droplets to an existing project
# the flatten will allow you to make a 2d list of the droplets so it isn't an array of arrays
resource "digitalocean_project_resources" "project_attach" {
    project = data.digitalocean_project.lab_project.id
    resources = flatten([ digitalocean_droplet.web.*.urn ])
}

###################Creates Firewall for web servers####################
resource "digitalocean_firewall" "web-firewall" {

    name = "web-firewall"

    droplet_ids = digitalocean_droplet.web.*.id

    # VPC rules to allow SSH to Bastion, ICMP to bastion for ping and HTTP to load balancer
    # SSH only to bastion
    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = [digitalocean_droplet.bastion.ipv4_address_private]
    }

    # PING only to bastion
    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_droplet.bastion.ipv4_address_private]
    }

    # HTTP only to loadbalancer
    inbound_rule {
        protocol = "tcp"
        port_range = "80"
        source_load_balancer_uids = [digitalocean_loadbalancer.http-loadbalancer.id]
    }
    
    # POSTGRES only to database cluster
    outbound_rule {
        protocol = "tcp"
        port_range = digitalocean_database_cluster.postgres-web.port
        destination_tags = [digitalocean_tag.database_tag.id]
    }
}

#############creates a loadbalancer####################
resource "digitalocean_loadbalancer" "http-loadbalancer" {
  name   = "loadbalancer-1"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  droplet_tag = "web-server"
  vpc_uuid = digitalocean_vpc.assignment_vpc.id
}



resource "digitalocean_project_resources" "attach_loadbalancer" {
    project = data.digitalocean_project.lab_project.id
    resources = [digitalocean_loadbalancer.http-loadbalancer.urn]
}