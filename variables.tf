variable "VPC-CIDR" {
  default = "10.0.0.0/16"
}
variable "SSH_key" {
  default = "<your_key>"
}
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

variable "node_count" {
  default = "1"
}

# Choose an Availability Domain
variable "availability_domain_index" {
  default = "1"
}

# DBSystem specific 
variable "db_system_shape" {
  default = "BM.HighIO1.36"
}

variable "cpu_core_count" {
  default = "2"
}

variable "db_edition" {
  default = "ENTERPRISE_EDITION"
}

variable "db_admin_password" {
  default = "BEstrO0ng_#11"
}

variable "db_name" {
  default = "aTFdb"
}

variable "db_version" {
  default = "12.1.0.2"
}

variable "db_home_display_name" {
  default = "MyTFDBHome"
}

variable "db_disk_redundancy" {
  default = "HIGH"
}

variable "db_system_display_name" {
  default = "MyTFDBSystem"
}

variable "hostname" {
  default = "myoracledb"
}

variable "host_user_name" {
  default = "opc"
}

variable "n_character_set" {
  default = "AL16UTF16"
}

variable "character_set" {
  default = "AL32UTF8"
}

variable "db_workload" {
  default = "OLTP"
}

variable "pdb_name" {
  default = "pdbName"
}

variable "data_storage_size_in_gb" {
  default = "256"
}

variable "license_model" {
  default = "LICENSE_INCLUDED"
}

variable "data_storage_percentage" {
  default = "40"
}
