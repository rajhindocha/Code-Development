# ------ Load Balancer
resource "oci_load_balancer_load_balancer" "Load_balancer" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Load_balancer"
    shape = "100Mbps"
    subnet_ids = ["${oci_core_subnet.LBSubnet1.id}","${oci_core_subnet.LBSubnet2.id}"]
}

# -------- Back End Set
resource "oci_load_balancer_backend_set" "Backend_Set_FE" {
    health_checker {
        protocol = "HTTP"
        port = "3000"
        url_path = "/"
    }
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    name = "BackEnd_Set_FE"
    policy = "ROUND_ROBIN"
}
resource "oci_load_balancer_backend_set" "Backend_Set_BE" {
    health_checker {
        protocol = "HTTP"
        port = "8000"
        url_path = "/getPolls"
    }
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    name = "BackEnd_Set_BE"
    policy = "ROUND_ROBIN"
}
# -------- Back End FE
resource "oci_load_balancer_backend" "Backend_1" {
    backendset_name = "${oci_load_balancer_backend_set.Backend_Set_FE.id}"
    ip_address = "${oci_core_instance.WebInstance1.private_ip}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    port = "3000"
}
resource "oci_load_balancer_backend" "Backend_2" {
    backendset_name = "${oci_load_balancer_backend_set.Backend_Set_FE.id}"
    ip_address = "${oci_core_instance.WebInstance2.private_ip}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    port = "3000"
}
# -------- Back End BE
resource "oci_load_balancer_backend" "Backend_3" {
    backendset_name = "${oci_load_balancer_backend_set.Backend_Set_BE.id}"
    ip_address = "${oci_core_instance.BackEndInstance1.private_ip}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    port = "8000"
}
resource "oci_load_balancer_backend" "Backend_4" {
    backendset_name = "${oci_load_balancer_backend_set.Backend_Set_BE.id}"
    ip_address = "${oci_core_instance.BackEndInstance2.private_ip}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    port = "8000"
}
# ------- Listeners
resource "oci_load_balancer_listener" "Listener1" {
    default_backend_set_name = "${oci_load_balancer_backend_set.Backend_Set_FE.id}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    name = "Listener1"
    port = "80"
    protocol = "HTTP"
}
resource "oci_load_balancer_listener" "Listener2" {
    default_backend_set_name = "${oci_load_balancer_backend_set.Backend_Set_BE.id}"
    load_balancer_id = "${oci_load_balancer_load_balancer.Load_balancer.id}"
    name = "Listener2"
    port = "8000"
    protocol = "TCP"
}