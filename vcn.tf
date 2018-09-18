variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {default = "ocid1.compartment.oc1..aaaaaaaa57mgrqxyajbn66vxjs4cgtqri5xnnictsyqzwuasuj2wnrtwqtiq"}
variable "region" {}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

resource "oci_core_virtual_network" "VCN" {
  cidr_block     = "${var.VPC-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "VCN"
  dns_label      = "myVCN"
}

resource "oci_core_internet_gateway" "IG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "IG"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
}

resource "oci_core_route_table" "RouteTable" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.IG.id}"
  }
}
resource "oci_core_route_table" "PublicRouteTable" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "PublicRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.IG.id}"
  }
}

resource "oci_core_security_list" "LoadBalancerSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "LoadBalancerSL"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "6"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 80
      "min" = 80
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = 3000
        "min" = 3000
      }

      protocol = "6"
      source   = "10.0.2.0/23"
    },
    {
      protocol = "6"
      source   = "${var.VPC-CIDR}"
    },{
      tcp_options {
        "max" = 8000
        "min" = 8000
      }

      protocol = "6"
      source   = "10.0.2.0/23"
    },
    {
      protocol = "6"
      source   = "${var.VPC-CIDR}"
    }
  ]
}

resource "oci_core_security_list" "PrivateSubnetSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "PrivateSubnetSL"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "${var.VPC-CIDR}"
  }]

  ingress_security_rules = [{
    protocol = "6"
    source   = "${var.VPC-CIDR}"
  },
  {
      tcp_options {
        "max" = 8000
        "min" = 8000
      }

      protocol = "6"
      source   = "10.0.0.0/23"
    },
    {
      tcp_options {
        "max" = 3000
        "min" = 3000
      }

      protocol = "6"
      source   = "10.0.0.0/23"
    },
    {
      tcp_options {
        "max" = 1521
        "min" = 1521
      }

      protocol = "6"
      source   = "10.0.4.0/24"
    }]
}

resource "oci_core_security_list" "BastionSubnetSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "BastionSubnetSL"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      protocol = "6"
      source   = "${var.VPC-CIDR}"
    },
  ]
}
resource "oci_core_security_list" "BackEndSubnetSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "BackEndSubnetSL"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 1521
      "min" = 1521
    }

    protocol = "6"
    source   = "10.0.2.0/23"
  },
    {
      protocol = "6"
      source   = "${var.VPC-CIDR}"
    },
  ]
}

resource "oci_core_subnet" "LBSubnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "10.0.0.0/24"
  display_name        = "LBSubnet1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.PublicRouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.LoadBalancerSL.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
  dns_label           = "myLBSubnet1"
}

resource "oci_core_subnet" "LBSubnet2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "10.0.1.0/24"
  display_name        = "LBSubnet2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.PublicRouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.LoadBalancerSL.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
  dns_label           = "myLBSubnet2"
}

/*
resource "oci_core_subnet" "WebSubnetAD3" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block          = "10.0.3.0/24"
  display_name        = "WebSubnetAD3"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.RouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.WebSubnetSC.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}*/

resource "oci_core_subnet" "PrivateSubnet1" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block                 = "10.0.2.0/24"
  display_name               = "PrivateSubnet1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${oci_core_virtual_network.VCN.id}"
  route_table_id             = "${oci_core_route_table.RouteTable.id}"
  security_list_ids          = ["${oci_core_security_list.PrivateSubnetSL.id}"]
  dhcp_options_id            = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "private1"
}

resource "oci_core_subnet" "PrivateSubnet2" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block                 = "10.0.3.0/24"
  display_name               = "PrivateSubnet2"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${oci_core_virtual_network.VCN.id}"
  route_table_id             = "${oci_core_route_table.RouteTable.id}"
  security_list_ids          = ["${oci_core_security_list.PrivateSubnetSL.id}"]
  dhcp_options_id            = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "private2"
}

resource "oci_core_subnet" "DataBaseSubnet1" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block                 = "10.0.4.0/24"
  display_name               = "DataBaseSubnet1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${oci_core_virtual_network.VCN.id}"
  route_table_id             = "${oci_core_route_table.RouteTable.id}"
  security_list_ids          = ["${oci_core_security_list.BackEndSubnetSL.id}"]
  dhcp_options_id            = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "myDBSubnet"
}

resource "oci_core_subnet" "BastionSubnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block          = "10.0.6.0/24"
  display_name        = "BastionSubnet1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.PublicRouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.BastionSubnetSL.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}

/*
resource "oci_core_subnet" "BastionSubnetAD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "10.0.8.0/24"
  display_name        = "BastionSubnetAD2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.RouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.BastionSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}

resource "oci_core_subnet" "BastionSubnetAD3" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block          = "10.0.9.0/24"
  display_name        = "BastionSubnetAD3"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.VCN.id}"
  route_table_id      = "${oci_core_route_table.RouteTable.id}"
  security_list_ids   = ["${oci_core_security_list.BastionSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.VCN.default_dhcp_options_id}"
}*/

