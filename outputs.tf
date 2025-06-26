# 定義一個輸出變量 "ssh-with-k8s-user"
output "ssh-with-k8s-user" {
  
  # 設定這個輸出變量的值，使用 format 函數來組合一個 SSH 命令字串
  value = format(
    
    # 格式化的字串，\n 是換行符號，將會產生類似這樣的字串：
    # ssh -o StrictHostKeyChecking=no -i <私鑰路徑> -l k8s <目標IP>
    "\nssh -o StrictHostKeyChecking=no -i %s -l %s %s\n",
    
    # %s 佔位符會被替換成下面指定的變量：
    # 第一個 %s 將會被替換為 SSH 私鑰的檔案名
    local_file.ssh_private_key.filename,
    
    # 第二個 %s 將會被替換為使用者名稱 "k8s"
    "k8s",
    
    # 第三個 %s 將會被替換為 OCI 實例的公有 IP 地址，這裡取的是第 2 個實例（索引從 0 開始）
    oci_core_instance._[1].public_ip
  )
}

# 定義另一個輸出變量 "ssh-with-ubuntu-user"
output "ssh-with-ubuntu-user" {
  
  # 設定這個輸出變量的值，這裡使用 join 函數來組合多行 SSH 命令
  value = join(
    
    # 每個命令之間用換行符號 "\n" 分隔
    "\n",
    
    # 使用 for 循環，對每一個 OCI 實例執行同樣的操作，並生成對應的 SSH 命令
    [for i in oci_core_instance._ :
      
      # 格式化字串將會生成類似這樣的字串：
      # ssh -o StrictHostKeyChecking=no -l ubuntu -p 22 -i <私鑰路徑> <實例公有IP> # <實例名稱>
      format(
        "ssh -o StrictHostKeyChecking=no -l ubuntu -p 22 -i %s %s # %s",
        
        # 第一個 %s 將會被替換為 SSH 私鑰的檔案名
        local_file.ssh_private_key.filename,
        
        # 第二個 %s 將會被替換為當前實例的公有 IP 地址
        i.public_ip,
        
        # 第三個 %s 將會被替換為當前實例的顯示名稱
        i.display_name
      )
    ]
  )
}
