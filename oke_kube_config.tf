## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "local_file" "KubeConfigFile" {
  content  = data.oci_containerengine_cluster_kube_config.KubeConfig.content
  filename = "${path.module}/oke_cluster_kubeconfig"
}
