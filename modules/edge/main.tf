data "spectrocloud_cluster_profile" "this" {
  for_each = {
    for profile in var.cluster_profiles : profile.name => profile
  }
  name = each.key
  version = each.value["tag"]
}


resource "spectrocloud_appliance" "this" {
  count = length(var.device_uuid)
  
  uid = lower("edge-${var.device_uuid[count.index]}")
  labels = {
    "cluster" = spectrocloud_cluster_import.this.id
    "name" = "edge-${var.location}"
    "environment" = var.branch
  }
  wait = false
}

resource "spectrocloud_cluster_import" "this" {
  name               = "edge-${var.location}"
  cloud              = "generic"
  tags = ["imported:false","environment:${var.branch}"]

  dynamic "cluster_profile" {
  
    for_each = var.cluster_profiles
    content {
      id = data.spectrocloud_cluster_profile.this[cluster_profile.value.name].id
      
      dynamic "pack" {
        for_each = cluster_profile.value.packs == null ? [] : cluster_profile.value.packs

        content {
          name = pack.value.name
          tag = pack.value.tag
          values = pack.value.values
        }
      }
      }
    
  }
}