## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_containerengine_cluster" "OKECluster" {
  #  depends_on         = [oci_identity_policy.OKEPolicy1]
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.OKE_ATP_VCN.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.OKE_Cluster_Subnet.id]

    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }

    kubernetes_network_config {
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }
  }
}

resource "oci_containerengine_node_pool" "OKENodePool" {
  #  depends_on         = [oci_identity_policy.OKEPolicy1]
  cluster_id         = oci_containerengine_cluster.OKECluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "OKENodePool"
  node_shape         = var.node_pool_shape

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.node_pool_flex_shape_memory
      ocpus         = var.node_pool_flex_shape_ocpus
    }
  }

  node_source_details {
    #image_id = data.oci_core_images.InstanceImageOCID.images[0].id
    image_id    = local.oracle_linux_images.0
    source_type = "IMAGE"
  }

  node_config_details {
    size = var.node_pool_size

    placement_configs {
      availability_domain = var.availablity_domain_name
      subnet_id           = oci_core_subnet.OKE_NodePool_Subnet.id
    }
  }

  initial_node_labels {
    key   = "key"
    value = "value"
  }

  ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh

}
