# 定義一個 OCI 身份的 compartment 資源
resource "oci_identity_compartment" "_" {
  name          = var.name          # Compartment 的名稱，從變量 `var.name` 獲取
  description   = var.name          # Compartment 的描述，從變量 `var.name` 獲取
  enable_delete = true              # 允許刪除此 compartment
}

# 定義本地變量 `compartment_id`，存儲剛剛創建的 compartment 的 ID
locals {
  compartment_id = oci_identity_compartment._.id
}

# 獲取可用域的數據
data "oci_identity_availability_domains" "_" {
  compartment_id = local.compartment_id # 使用上面定義的 compartment_id
}

# 獲取符合條件的映像數據
data "oci_core_images" "_" {
  compartment_id           = local.compartment_id  # 使用上面定義的 compartment_id
  shape                    = var.shape             # 使用指定的形狀
  operating_system         = "Canonical Ubuntu"    # 操作系統為 Ubuntu
  operating_system_version = "22.04"               # 操作系統版本為 22.04
}

# 定義 OCI 虛擬機實例資源
resource "oci_core_instance" "_" {
  for_each            = local.nodes # 遍歷 `local.nodes` 以創建多個實例
  display_name        = each.value.node_name # 實例的顯示名稱
  availability_domain = data.oci_identity_availability_domains._.availability_domains[var.availability_domain].name # 可用域名稱
  compartment_id      = local.compartment_id # 使用上面定義的 compartment_id
  shape               = var.shape # 實例的形狀，從變量 `var.shape` 獲取
  shape_config {
    memory_in_gbs = var.memory_in_gbs_per_node # 每個實例的內存大小
    ocpus         = var.ocpus_per_node        # 每個實例的 CPU 核數
  }
  source_details {
    source_id   = data.oci_core_images._.images[0].id # 使用的映像 ID
    source_type = "image" # 資源類型為映像
  }
  create_vnic_details {
    subnet_id  = oci_core_subnet._.id # 連接到的子網 ID
    private_ip = each.value.ip_address # 實例的私有 IP 地址
  }
  metadata = {
    ssh_authorized_keys = join("\n", local.authorized_keys) # SSH 授權的公鑰
    user_data           = data.cloudinit_config._[each.key].rendered # 用戶數據，從 cloud-init 配置中獲取
  }
  connection {
    host        = self.public_ip # 實例的公共 IP 地址
    user        = "ubuntu" # SSH 用戶名
    private_key = tls_private_key.ssh.private_key_pem # SSH 私鑰
  }
  provisioner "remote-exec" {
    inline = [
      "tail -f /var/log/cloud-init-output.log &", # 在後台運行 cloud-init 日誌查看
      "cloud-init status --wait >/dev/null", # 等待 cloud-init 完成
    ]
  }
}

# 定義本地變量 `nodes`，創建節點配置
locals {
  nodes = {
    for i in range(1, 1 + var.how_many_nodes) :
    i => {
      node_name  = format("node%d", i) # 節點名稱，例如 node1, node2, 等等
      ip_address = format("10.0.0.%d", 10 + i) # 節點的 IP 地址
      role       = i == 1 ? "controlplane" : "worker" # 節點角色，第一個節點為控制平面，其餘為工作節點
    }
  }
}
