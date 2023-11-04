terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = "b1gu16jc91eoe16r1kvl"
  folder_id = "b1g4tgdb5lg50tp1as52"
  zone      = "ru-central1-b"
}

resource "yandex_compute_instance" "vm-instance" {
  count = var.num_instances

  name        = "alma${count.index}"
  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = true
  }

  resources {
    core_fraction = 5
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81m6n1rh1v2mpjft86"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Creating target group

resource "yandex_lb_target_group" "lb_target_group1" {
  name      = "lb-target-group1"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address   = "${yandex_compute_instance.vm-instance[0].network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    address   = "${yandex_compute_instance.vm-instance[1].network_interface.0.ip_address}"
  }
}

resource "yandex_lb_network_load_balancer" "lb_network_load_balancer1" {
  name = "my-network-load-balancer1"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.lb_target_group1.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}


output "internal_ip_addresses" {
  value = yandex_compute_instance.vm-instance.*.network_interface.0.ip_address
}

output "external_ip_addresses" {
  value = yandex_compute_instance.vm-instance.*.network_interface.0.nat_ip_address
}