# 定義 Terraform 配置
terraform {
  # 定義所需的提供者
  required_providers {
    # 配置 Oracle Cloud Infrastructure (OCI) 提供者
    oci = {
      source  = "oracle/oci" # 提供者的來源為 Oracle 的 OCI 提供者
      version = "4.114.0"    # 指定 OCI 提供者的版本為 4.114.0
    }
  }
}
