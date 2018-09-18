output "lb_public_ip" {
  value = ["${oci_load_balancer_load_balancer.Load_balancer.ip_addresses}"]
}
# ------ Display the public IP of instance
output " Public IP of web-instance-1" {
  value = ["${oci_core_instance.WebInstance1.public_ip}"]
}
# ------ Display the public IP of instance
output " Public IP of second web-instance-2" {
  value = ["${oci_core_instance.WebInstance2.public_ip}"]
}
output " Public IP of second be-instance-1" {
  value = ["${oci_core_instance.BackEndInstance1.public_ip}"]
}
output " Public IP of second be-instance-2" {
  value = ["${oci_core_instance.BackEndInstance2.public_ip}"]
}
/*output " Public IP of Bastion host" {
  value = ["${oci_core_instance.BackEndInstance2.public_ip}"]
}*/