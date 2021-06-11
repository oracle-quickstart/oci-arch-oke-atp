## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_option" "OKE_Cluster_Option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "OKE_Cluster_NodePool_Option" {
  node_pool_option_id = "all"
}

locals {
  all_sources         = data.oci_containerengine_node_pool_option.OKE_Cluster_NodePool_Option.sources
  oracle_linux_images = [for source in local.all_sources : source.image_id if length(regexall("Oracle-Linux-[0-9]*.[0-9]*-20[0-9]*", source.source_name)) > 0]
}

data "oci_containerengine_cluster_kube_config" "KubeConfig" {
  cluster_id    = oci_containerengine_cluster.OKECluster.id
  token_version = var.cluster_kube_config_token_version
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}
