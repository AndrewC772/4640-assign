# reads out the IP of the servers
output "server_ip" {
    value = digitalocean_droplet.web.*.ipv4_address
}

output "bastion_ip"{
    value = digitalocean_droplet.bastion.ipv4_address
}

output "load_balancer_ip"{
    value = digitalocean_loadbalancer.http-loadbalancer.ip
}