# 定義一個 OCI 的虛擬雲網路（VCN）
resource "oci_core_vcn" "_" {
  
  # 指定要在哪個 compartment（隔離區）中創建 VCN，這裡使用了本地變量 compartment_id
  compartment_id = local.compartment_id
  
  # 設定 VCN 的網路範圍為 10.0.0.0/16
  cidr_block     = "10.0.0.0/16"
}

# 定義一個 OCI 的網際網路閘道（Internet Gateway），用來讓 VCN 連接到外部互聯網
resource "oci_core_internet_gateway" "_" {

  # 指定這個 Internet Gateway 所在的 compartment（隔離區）
  compartment_id = local.compartment_id

  # 指定這個 Internet Gateway 所屬的 VCN
  vcn_id         = oci_core_vcn._.id
}

# 管理 VCN 的預設路由表，使流量可以通過 Internet Gateway 發送到外部網路
resource "oci_core_default_route_table" "_" {
  
  # 設定要管理的預設路由表的 ID，這裡直接引用 VCN 的 default_route_table_id
  manage_default_resource_id = oci_core_vcn._.default_route_table_id

  # 定義一條路由規則
  route_rules {

    # 將目的地設定為所有 IP（即 0.0.0.0/0）
    destination       = "0.0.0.0/0"

    # 指定目的地的類型為 CIDR_BLOCK
    destination_type  = "CIDR_BLOCK"

    # 設定將流量發送到網際網路閘道（Internet Gateway）
    network_entity_id = oci_core_internet_gateway._.id
  }
}

# 管理 VCN 的預設安全列表（Security List），設定進出網路的安全規則
resource "oci_core_default_security_list" "_" {

  # 指定要管理的預設安全列表的 ID，這裡直接引用 VCN 的 default_security_list_id
  manage_default_resource_id = oci_core_vcn._.default_security_list_id

  # 定義入站（Ingress）安全規則
  ingress_security_rules {

    # 允許所有協議的流量
    protocol = "all"

    # 允許來自任何來源（0.0.0.0/0）的流量
    source   = "0.0.0.0/0"
  }

  # 定義出站（Egress）安全規則
  egress_security_rules {

    # 允許所有協議的流量
    protocol    = "all"

    # 允許發送到任何目的地（0.0.0.0/0）的流量
    destination = "0.0.0.0/0"
  }
}

# 定義一個 OCI 的子網（Subnet），子網是 VCN 中的一個網路片段
resource "oci_core_subnet" "_" {

  # 指定這個子網所在的 compartment（隔離區）
  compartment_id    = local.compartment_id

  # 設定子網的網路範圍為 10.0.0.0/24
  cidr_block        = "10.0.0.0/24"

  # 指定這個子網所屬的 VCN
  vcn_id            = oci_core_vcn._.id

  # 指定這個子網使用的路由表
  route_table_id    = oci_core_default_route_table._.id

  # 指定這個子網使用的安全列表，這裡使用了之前定義的預設安全列表
  security_list_ids = [oci_core_default_security_list._.id]
}
