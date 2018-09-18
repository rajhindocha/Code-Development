resource "oci_database_db_system" "test_db_system" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}" #"${var.db_system_availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  database_edition    = "ENTERPRISE_EDITION"

  db_home {
    #Required
    database {
      #Required
      # Was: "${var.db_system_db_home_database_admin_password}"
      admin_password = "AdMin123##"

      db_name = "myDB"

      #db_workload = "${var.db_system_db_home_database_db_workload}"
      #ncharacter_set = "${var.db_system_db_home_database_ncharacter_set}"
      pdb_name = "PDB1"
    }

    #Optional
    db_version = "18.2.0.0"

    #display_name = "${var.db_system_db_home_display_name}"
  }

  node_count              = "1"                                                                                                                                                                                                                                                                                                                                                                                                                                                #"${lookup(data.oci_database_db_system_shapes.test_db_system_shapes.db_system_shapes[0], "minimum_node_count")}"
  data_storage_size_in_gb = "256"
  hostname                = "myDB"
  shape                   = "VM.Standard1.1"
  ssh_public_keys         = ["${var.SSH_key}"]
  subnet_id               = "${oci_core_subnet.DataBaseSubnet1.id}"
}
