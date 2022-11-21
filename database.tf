
################ Database contained here ######################
resource "digitalocean_database_cluster" "postgres-web" {
  name       = "postgres-cluster"
  engine     = "pg"
  version    = "11"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
  tags = [digitalocean_tag.database_tag.id]

  private_network_uuid = digitalocean_vpc.assignment_vpc.id
}

resource "digitalocean_tag" "database_tag" {
  name = "database-cluster"
}

# Attach the database to project
resource "digitalocean_project_resources" "attach_database" {
    project = data.digitalocean_project.lab_project.id
    resources = [digitalocean_database_cluster.postgres-web.urn]
}

############### Database Firewall ############################
resource "digitalocean_database_firewall" "postgres-firewall" {
  cluster_id = digitalocean_database_cluster.postgres-web.id
  # Allows connections for droplets in the "web" group
  rule {
    type  = "tag"
    value = digitalocean_tag.do_tag.id
  }
}