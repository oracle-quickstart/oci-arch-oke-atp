## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "OKE_Cluster_Kubernetes_Versions" {
  value = [data.oci_containerengine_cluster_option.OKE_Cluster_Option.kubernetes_versions]
}

output "OKE_Cluster_NodePool_Kubernetes_Version" {
  value = [data.oci_containerengine_node_pool_option.OKE_Cluster_NodePool_Option.kubernetes_versions]
}

output "OKE_Cluster" {
  value = {
    id                 = oci_containerengine_cluster.OKECluster.id
    kubernetes_version = oci_containerengine_cluster.OKECluster.kubernetes_version
    name               = oci_containerengine_cluster.OKECluster.name
  }
}

output "OKE_NodePool" {
  value = {
    id                 = oci_containerengine_node_pool.OKENodePool.id
    kubernetes_version = oci_containerengine_node_pool.OKENodePool.kubernetes_version
    name               = oci_containerengine_node_pool.OKENodePool.name
    subnet_ids         = oci_containerengine_node_pool.OKENodePool.subnet_ids
  }
}

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}