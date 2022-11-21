########### data blocks contained here #######

#declare the ssh key
data "digitalocean_ssh_key" "lab_ssh_key" {
  name = "River"
}

#declares the project name
data "digitalocean_project" "lab_project" {
  name = "4640_labs"
}
