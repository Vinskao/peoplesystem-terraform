# 定義本地變量 is_windows，用於判斷當前操作系統是否為 Windows
locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true # 根據家目錄路徑的第一個字符來確定是否為 Windows 系統
}

# 定義外部數據源 kubeconfig，用於從 Kubernetes 節點獲取 kubeconfig 文件並將其轉換為 base64 格式
data "external" "kubeconfig" {
  depends_on = [oci_core_instance._[1]] # 確保在 oci_core_instance._[1] 創建之後再執行此數據源

  # 根據操作系統的不同，使用不同的命令來獲取 kubeconfig 文件的 base64 編碼
  program = local.is_windows ? [
    "powershell", # Windows 系統使用 PowerShell
    <<EOT
    write-host "{`"base64`": `"$(ssh -o StrictHostKeyChecking=no -l k8s -i ${local_file.ssh_private_key.filename} ${oci_core_instance._[1].public_ip} sudo base64 -w0 /etc/kubernetes/admin.conf)`"}"
    EOT
    ] : [
    "sh", # 非 Windows 系統使用 sh
    "-c",
    <<-EOT
      set -e # 在任何命令出錯時退出
      cat >/dev/null # 這行命令不做任何操作，僅用於設置環境
      echo '{"base64": "'$(
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
              -l k8s -i ${local_file.ssh_private_key.filename} \
              ${oci_core_instance._[1].public_ip} \
              'sudo cat /etc/kubernetes/admin.conf | base64 -w0'
            )'"}'
    EOT
  ]
}

# 定義本地文件 kubeconfig，用於將 base64 編碼的 kubeconfig 文件內容寫入本地文件
resource "local_file" "kubeconfig" {
  content         = base64decode(data.external.kubeconfig.result.base64) # 將 base64 編碼的內容解碼並寫入文件
  filename        = "kubeconfig" # 文件名稱
  file_permission = "0600" # 文件權限設置為 0600，僅擁有者可讀寫

  # 在本地文件創建後執行 kubectl 命令來設置 Kubernetes 集群配置
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=kubeconfig config set-cluster kubernetes --server=https://${oci_core_instance._[1].public_ip}:6443"
  }
}
