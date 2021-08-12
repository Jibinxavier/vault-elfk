# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    =  var.api_pass
  auth_url    = "http://controller:5000/v3"
  region      = "RegionOne"
}


data "openstack_compute_flavor_v2" "medium" {
  name = "medium"
} 
data "openstack_compute_flavor_v2" "medium2" {
  name = "medium2"
}
data "openstack_compute_flavor_v2" "elk-large" {
  name = "elk-large"
} 
data "openstack_compute_flavor_v2" "elk-medium" {
  name = "elk-medium"
} 


data "openstack_networking_network_v2" "provider" {
  name = "provider"
}
 
data "openstack_compute_keypair_v2" "test-keypair" {
  name = "my-keypair"
}
data "openstack_images_image_v2" "centos7" {
  name        = "centos7"
 
}

resource "openstack_compute_secgroup_v2" "elk_sec_group" {
  name        = "elk_sec_group"
  description = "ELK Stack sec group"

  rule {
    from_port   = 5601
    to_port     = 5601
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   =  1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "192.168.9.1/24"
  }
}
resource "openstack_compute_instance_v2" "elk01" {
  name            = "elk01"
  image_id        = data.openstack_images_image_v2.centos7.id
  flavor_id       = data.openstack_compute_flavor_v2.elk-large.id
  key_pair        = data.openstack_compute_keypair_v2.test-keypair.name 
  security_groups = ["default",openstack_compute_secgroup_v2.elk_sec_group.name]
  network {
    name = data.openstack_networking_network_v2.provider.name
  } 
}

resource "openstack_compute_instance_v2" "elk02" {
  name            = "elk02"
  image_id        = data.openstack_images_image_v2.centos7.id
  flavor_id       = data.openstack_compute_flavor_v2.elk-medium.id
  key_pair        = data.openstack_compute_keypair_v2.test-keypair.name 
  security_groups = ["default", openstack_compute_secgroup_v2.elk_sec_group.name]

  network {
    name = data.openstack_networking_network_v2.provider.name
  } 
}


resource "openstack_compute_instance_v2" "vault01" {
  name            = "vault01"
  image_id        = data.openstack_images_image_v2.centos7.id
  flavor_id       = data.openstack_compute_flavor_v2.medium.id
  key_pair        = data.openstack_compute_keypair_v2.test-keypair.name 
  network {
    name = data.openstack_networking_network_v2.provider.name
  } 
}
resource "openstack_compute_instance_v2" "consul01" {
  name            = "consul01"
  image_id        = data.openstack_images_image_v2.centos7.id
  flavor_id       = data.openstack_compute_flavor_v2.medium.id
  key_pair        = data.openstack_compute_keypair_v2.test-keypair.name 
  network {
    name = data.openstack_networking_network_v2.provider.name
  } 
}



# resource "openstack_compute_instance_v2" "monitor01" {
#   name            = "monitor01"
#   image_id        = data.openstack_images_image_v2.centos7.id
#   flavor_id       = data.openstack_compute_flavor_v2.medium2.id
#   key_pair        = data.openstack_compute_keypair_v2.test-keypair.name 
#   security_groups = ["default" ]

#   network {
#     name = data.openstack_networking_network_v2.provider.name
#   } 
# }
