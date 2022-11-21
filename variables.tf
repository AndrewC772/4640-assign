#add the variable for api token
variable "do_token" {}

#the default region
variable "region" {
    type = string 
    default = "sfo3"
}


#sets the number of droplets to create
variable "droplet_count" {
    type = number
    default = 2
}