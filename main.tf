provider "google" {
    project = "${var.gcp_project}"
    region = "${var.gcp_region}"
    zone = "${var.gcp_zone}"
}

resource "google_compute_instance" "mysql_node" {
    count = "${var.count_instances}"

    name = "${var.instance_name}${count.index + 1}"
    machine_type = "${var.machine_type}"
     
    scheduling {
        automatic_restart   = true
    }
    
    boot_disk {
        initialize_params {
            image = "centos-8"
            size = "${var.disk_size}"
            type = "pd-standard"
        }
    }

    network_interface {
        network = "default"
        network_ip = "${var.node_ip_part}.${count.index + 1}"
    }
    tags = ["mysql-cluster"]
}

resource "google_compute_instance" "mysql_router" {
    name = "mysql-router"
    machine_type = "${var.machine_type}"
     
    scheduling {
        automatic_restart   = true
    }
    
    boot_disk {
        initialize_params {
            image = "centos-8"
            size = "${var.disk_size}"
            type = "pd-standard"
        }
    }

    network_interface {
        network = "default"
        network_ip = "${var.router_ip}"
    }
    tags = ["mysql-cluster"]
}

resource "google_compute_firewall" "mysql_cluster" {
  name    = "mysql-cluster"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["all"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mysql-cluster"]
}
output "ip" {
  value = "${google_compute_instance.mysql_router.network_interface.0.access_config.0.nat_ip}"
}
output "ip" {
  value = "${google_compute_instance.mysql_node.network_interface.0.access_config.0.nat_ip}"
}