## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "OKE_ATP_VCN" {
  cidr_block     = var.VCN-CIDR
  compartment_id = var.compartment_ocid
  display_name   = "OKE_ATP_VCN"
}

resource "oci_core_internet_gateway" "OKE_ATP_IGW" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE_ATP_IGW"
  vcn_id         = oci_core_vcn.OKE_ATP_VCN.id
}


resource "oci_core_route_table" "OKE_ATP_VCN_route_table_via_IGW" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.OKE_ATP_VCN.id
  display_name   = "OKE_ATP_VCN_route_table_via_IGW"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id =  oci_core_internet_gateway.OKE_ATP_IGW.id
  }
}


resource "oci_core_security_list" "OKE_ATP_LB_SecList" {
    compartment_id = var.compartment_ocid
    display_name = "OKE_ATP_LB_SecList"
    vcn_id = oci_core_vcn.OKE_ATP_VCN.id
    
    egress_security_rules {
        protocol = "6"
        destination = "0.0.0.0/0"
        stateless = true
    }

    ingress_security_rules {
        protocol = "6"
        source = "0.0.0.0/0"
        stateless = true
    }
}

resource "oci_core_security_list" "OKE_ATP_Worker_SecList" {
    compartment_id = var.compartment_ocid
    display_name = "OKE_ATP_Worker_SecList"
    vcn_id = oci_core_vcn.OKE_ATP_VCN.id
    
    egress_security_rules {
        protocol = "All"
        stateless = true
        destination = var.OKE_NodePool_Subnet-CIDR
    }

#    egress_security_rules {
#        protocol = "All"
#        stateless = true
#        destination = var.OKE_NodePool_Subnet2-CIDR
#    }
    
#    egress_security_rules {
#        protocol = "All"
#        stateless = true
#        destination = var.OKE_NodePool_Subnet3-CIDR
#    }
    
    ingress_security_rules {
        protocol = "All"
        source = var.OKE_NodePool_Subnet-CIDR
        stateless = true
    }

#    ingress_security_rules {
#        protocol = "All"
#        source = var.OKE_NodePool_Subnet2-CIDR
#        stateless = true
#    }

#    ingress_security_rules {
#        protocol = "All"
#        source = var.OKE_NodePool_Subnet3-CIDR
#        stateless = true
#    }

    ingress_security_rules {
        protocol = "1"
        source = "0.0.0.0/0"
        stateless = false
        icmp_options {
            type = 3
            code = 4
        }
    }

    ingress_security_rules {
        protocol = "6"
        source = "0.0.0.0/0"
        stateless = false
        tcp_options {
            min = 22
            max = 22
        }
    }

    ingress_security_rules {
        protocol = "6"
        source = "0.0.0.0/0"
        stateless = false
        tcp_options {
            min = 30000 
            max = 32767
        }
    }
}

resource "oci_core_subnet" "OKE_Cluster_Subnet" {
  cidr_block          = var.OKE_Cluster_Subnet-CIDR
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.OKE_ATP_VCN.id
  display_name        = "OKE_Cluster_Subnet"

  security_list_ids = [oci_core_vcn.OKE_ATP_VCN.default_security_list_id, oci_core_security_list.OKE_ATP_LB_SecList.id]
  route_table_id    = oci_core_route_table.OKE_ATP_VCN_route_table_via_IGW.id
}

resource "oci_core_subnet" "OKE_NodePool_Subnet" {
  cidr_block          = var.OKE_NodePool_Subnet-CIDR
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.OKE_ATP_VCN.id
  display_name        = "OKE_NodePool_Subnet"

  security_list_ids = [oci_core_vcn.OKE_ATP_VCN.default_security_list_id, oci_core_security_list.OKE_ATP_Worker_SecList.id]
  route_table_id    = oci_core_route_table.OKE_ATP_VCN_route_table_via_IGW.id
}

