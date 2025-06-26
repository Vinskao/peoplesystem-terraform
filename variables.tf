# 定義名為 `name` 的變量，用於指定資源的名稱
variable "name" {
  type    = string
  default = "peoplesystem-arm"
}

# 註釋區塊：列出了可用的 flex shapes，這些 shapes 代表不同的虛擬機類型
/*
Available flex shapes:
"VM.Optimized3.Flex"  # Intel Ice Lake
"VM.Standard3.Flex"   # Intel Ice Lake
"VM.Standard.A1.Flex" # Ampere Altra
"VM.Standard.E3.Flex" # AMD Rome
"VM.Standard.E4.Flex" # AMD Milan
*/

# 定義名為 `shape` 的變量，用於指定虛擬機的形狀（即類型）
variable "shape" {
  type    = string # 變量的類型是字符串
  default = "VM.Standard.A1.Flex" # 默認值設為 "VM.Standard.A1.Flex"
}

# 定義名為 `how_many_nodes` 的變量，用於指定節點的數量
variable "how_many_nodes" {
  type    = number # 變量的類型是數字
  default = 4 # 默認值設為 4
}

# 定義名為 `availability_domain` 的變量，用於指定可用性域（Availability Domain）
variable "availability_domain" {
  type    = number # 變量的類型是數字
  default = 0 # 默認值設為 0
}

# 定義名為 `ocpus_per_node` 的變量，用於指定每個節點的 OCPU 數量
variable "ocpus_per_node" {
  type    = number # 變量的類型是數字
  default = 1 # 默認值設為 1
}

# 定義名為 `memory_in_gbs_per_node` 的變量，用於指定每個節點的內存（以 GB 為單位）
variable "memory_in_gbs_per_node" {
  type    = number # 變量的類型是數字
  default = 6 # 默認值設為 6 GB
}
