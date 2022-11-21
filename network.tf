#Create a new VPC
resource "digitalocean_vpc" "assignment_vpc" {
  name   = "assignment"
  region = var.region
}
