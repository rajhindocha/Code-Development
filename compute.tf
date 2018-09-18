# ------- Create a compute instance in AD-2
resource "oci_core_instance" "WebInstance1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "WebInstance1"
  hostname_label = "WebInstance1"
  source_details {
    source_id = "ocid1.bootvolume.oc1.iad.abuwcljrdtieiddm4rugsin6wjit2towt6d4hcgddgnv36yqts3ijsxfwbta"
    source_type = "bootVolume"
  }
  shape = "VM.Standard2.1"
  subnet_id = "${oci_core_subnet.PrivateSubnet1.id}"
  metadata {
    #user_data = "${base64encode(var.user-data)}"
    ssh_authorized_keys = "${var.SSH_key}"
  }
  timeouts {
    create = "30m"
  }
}
resource "oci_core_instance" "WebInstance2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "WebInstance2"
  hostname_label = "WebInstance2"
  source_details {
    source_id = "ocid1.bootvolume.oc1.iad.abuwcljto5rjypliorgyrflk34hayq6t7fc3sdkua3kkpaty2bl2fjzled5q"
    source_type = "bootVolume"
  }
  shape = "VM.Standard2.1"
  subnet_id = "${oci_core_subnet.PrivateSubnet2.id}"
  metadata {
    #user_data = "${base64encode(var.user-data)}"
    ssh_authorized_keys = "${var.SSH_key}"
  }
  timeouts {
    create = "30m"
  }
}
resource "oci_core_instance" "BackEndInstance1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "BackEndInstance1"
  hostname_label = "BackEndInstance1"
  source_details {
    source_id = "ocid1.bootvolume.oc1.iad.abuwcljrzybntfgctpedx4rw5va52tjlcy42c3etvyuqqptfrw4yyxven53a"
    source_type = "bootVolume"
  }
  shape = "VM.Standard1.1"
  subnet_id = "${oci_core_subnet.PrivateSubnet1.id}"
  metadata {
    #user_data = "${base64encode(var.user-data)}"
    ssh_authorized_keys = "${var.SSH_key}"
  }
  timeouts {
    create = "30m"
  }
}
resource "oci_core_instance" "BackEndInstance2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "BackEndInstance2"
  hostname_label = "BackEndInstance2"
  source_details {
    source_id = "ocid1.bootvolume.oc1.iad.abuwcljtexkrnspkckrmeqy4fcqxauc2syxli4s4pzdhoyh3xeiihiguixpq"
    source_type = "bootVolume"
  }
  shape = "VM.Standard1.1"
  subnet_id = "${oci_core_subnet.PrivateSubnet2.id}"
  metadata {
    #user_data = "${base64encode(var.user-data)}"
    ssh_authorized_keys = "${var.SSH_key}"
  }
  timeouts {
    create = "30m"
  }
}