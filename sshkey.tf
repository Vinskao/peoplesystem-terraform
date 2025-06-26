# 定義名為 `ssh` 的 TLS 私鑰資源，使用 RSA 演算法生成私鑰
resource "tls_private_key" "ssh" {
  algorithm = "RSA" # 使用 RSA 演算法
  rsa_bits  = "4096" # RSA 密鑰長度設為 4096 位
}

# 定義名為 `ssh_private_key` 的本地文件資源，用於保存生成的私鑰
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem # 文件內容是生成的私鑰
  filename        = "id_rsa" # 文件名稱為 id_rsa
  file_permission = "0600" # 文件權限設為 0600，僅擁有者可讀寫
}

# 定義名為 `ssh_public_key` 的本地文件資源，用於保存生成的公鑰
resource "local_file" "ssh_public_key" {
  content         = tls_private_key.ssh.public_key_openssh # 文件內容是生成的公鑰
  filename        = "id_rsa.pub" # 文件名稱為 id_rsa.pub
  file_permission = "0600" # 文件權限設為 0600，僅擁有者可讀寫
}

# 定義本地變量 `authorized_keys`，包含一個經過處理的公鑰
locals {
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)] # 將生成的公鑰去除末尾換行符後儲存
}
