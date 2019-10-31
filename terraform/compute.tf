data "google_compute_zones" "available" {}

variable "ssh_user" {}
variable "ssh_pub_key_file" {}

resource "google_compute_instance_template" "http_server_instance_template" {
    name = "http-server-instance-template"
    machine_type = "f1-micro"
    tags = ["http-server-instance"]
    metadata = {
        ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
    }
    disk {
        source_image = "ubuntu-1604-xenial-v20170328"
        boot = true
    }
    network_interface {
        network = "default"
        access_config {}
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_http_health_check" "http_server_http_health_check" {
    name = "http-server-http-health-check"
    request_path = "/"
    check_interval_sec = 10
    timeout_sec = 5
}

resource "google_compute_target_pool" "http_server_target_pool" {
    name = "http-server-target-pool"
    health_checks = [google_compute_http_health_check.http_server_http_health_check.name]
}

resource "google_compute_instance_group_manager" "http_server_instance_group_manager" {
    name = "http-server-instance-group-manager"
    zone = data.google_compute_zones.available.names[0]
    instance_template = google_compute_instance_template.http_server_instance_template.self_link
    base_instance_name = "http-server-instance"
    target_size = "3"
    target_pools = [google_compute_target_pool.http_server_target_pool.self_link]
}

resource "google_compute_health_check" "http_server_health_check" {
    name = "http-server-health-check"
    check_interval_sec = 5
    timeout_sec = 5
    http_health_check {
        port = "80"
        request_path = "/"
    }
}

resource "google_compute_backend_service" "http_server_backend_service" {
    name = "http-server-backend-service"
    protocol = "HTTP"
    health_checks = [google_compute_health_check.http_server_health_check.self_link]
    backend {
        group = google_compute_instance_group_manager.http_server_instance_group_manager.instance_group
    }
}

resource "google_compute_url_map" "http_server_url_map" {
    name = "http-server-url-map"
    default_service = google_compute_backend_service.http_server_backend_service.self_link
}

resource "google_compute_target_http_proxy" "http_server_target_http_proxy" {
    name = "http-server-target-http-proxy"
    url_map = google_compute_url_map.http_server_url_map.self_link
}

resource "google_compute_global_address" "http_server_global_address" {
    name = "http-server-global-address"
}

resource "google_compute_global_forwarding_rule" "http_server_global_forwarding_rule" {
    name = "http-server-global-forwarding-rule"
    target = google_compute_target_http_proxy.http_server_target_http_proxy.self_link
    ip_address = google_compute_global_address.http_server_global_address.self_link
    port_range = "80"
}

resource "google_compute_firewall" "http_server_firewall" {
    name = "http-server-firewall"
    network = "default"
    direction = "INGRESS"
    target_tags = ["http-server-instance"]
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
}