## OCI 驗證
```sh
# 重新設定config
oci setup config
vi ~/.oci/config
rm ~/.oci/config
oci session authenticate
```

## 敏感文件處理

### 重要：以下文件包含敏感資訊，不會被上傳到版本控制系統：

| 文件 | 說明 | 處理方式 |
|------|------|----------|
| `ap-osaka-1` | OCI 配置文件 | 複製 `ap-osaka-1.example` 並填入你的實際配置 |
| `id_rsa` | SSH 私鑰 | 由 Terraform 自動生成，每次部署都會重新生成 |
| `id_rsa.pub` | SSH 公鑰 | 由 Terraform 自動生成，每次部署都會重新生成 |
| `kubeconfig` | Kubernetes 配置 | 由 Terraform 自動生成，包含集群認證資訊 |

### 設置步驟：
1. 複製範例配置文件：`cp ap-osaka-1.example ap-osaka-1`
2. 編輯配置文件：`vi ap-osaka-1`
3. 填入你的實際 OCI 配置資訊
4. 運行 `terraform apply` 生成其他必要文件

## Steps
1. Create an Oracle Cloud Infrastructure account (just follow this link).
2. Have installed or install kubernetes.
3. Have installed or install terraform.
4. Have installed or install OCI CLI .
5. Configure OCI credentials. If you obtain a session token (with oci session authenticate), make sure to put the correct region, and when prompted for the profile name, enter DEFAULT so that Terraform finds the session token automatically.
6. Download this project and enter its folder.
7. `terraform init`
8. `terraform apply`


## Reference
`https://github.com/jpetazzo/ampernetacle`

## Applying OKE Planning

### 從單機實例轉換到 OKE (Oracle Container Engine for Kubernetes) 需要調整的項目清單：

#### 1. 主要資源變更

| 操作 | 資源類型 | 說明 |
|------|----------|------|
| 移除 | `oci_core_instance` | main.tf 中的虛擬機實例 |
| 新增 | `oci_container_engine_cluster` | OKE 集群 |
| 新增 | `oci_container_engine_node_pool` | 節點池 |

#### 2. 網路配置調整

| 操作 | 組件 | 說明 |
|------|------|------|
| 保留 | VCN, Internet Gateway, Route Table, Security List, Subnet | 基礎網路架構保持不變 |
| 新增 | 負載均衡器子網 | 可能需要額外的子網用於負載均衡器 |
| 調整 | Security List 規則 | 針對 Kubernetes 服務進行優化 |

#### 3. 變量調整 (variables.tf)

| 操作 | 原變量 | 新變量 | 說明 |
|------|--------|--------|------|
| 保留 | `name` | `name` | 資源名稱 |
| 保留 | `availability_domain` | `availability_domain` | 可用性域 |
| 調整 | `shape` | `node_pool_shape` | 節點池形狀 |
| 調整 | `how_many_nodes` | `node_pool_size` | 節點池大小 |
| 調整 | `ocpus_per_node` | `node_pool_ocpus` | 節點 OCPU |
| 調整 | `memory_in_gbs_per_node` | `node_pool_memory` | 節點記憶體 |
| 新增 | - | `kubernetes_version` | Kubernetes 版本 |
| 新增 | - | `node_pool_name` | 節點池名稱 |

#### 4. 移除的組件

| 文件/組件 | 說明 |
|-----------|------|
| `cloudinit.tf` | OKE 會自動處理節點初始化 |
| `sshkey.tf` | OKE 會自動生成 SSH 金鑰 |
| TLS 私鑰相關資源 | 不再需要手動管理 |
| kubeadm 相關配置和腳本 | OKE 自動處理集群初始化 |

#### 5. 新增的組件

| 組件 | 說明 |
|------|------|
| OKE 集群配置 | 定義 Kubernetes 集群 |
| 節點池配置 | 定義工作節點池 |
| Kubernetes 配置輸出 | 生成 kubeconfig |

#### 6. 輸出調整 (outputs.tf)

| 操作 | 輸出項目 | 說明 |
|------|----------|------|
| 移除 | 實例相關輸出 | 不再需要實例 IP 等資訊 |
| 新增 | OKE 集群 ID | 集群識別碼 |
| 新增 | 節點池 ID | 節點池識別碼 |
| 新增 | Kubernetes 配置 | kubeconfig 內容 |


#### 7. 注意事項

| 項目 | 說明 |
|------|------|
| 網路配置 | OKE 需要額外的網路配置用於負載均衡器 |
| IAM 策略 | 可能需要調整 IAM 策略以支援 OKE 操作 |
| 成本評估 | 成本可能會有所不同，需要評估 |
| 自定義配置 | 某些自定義配置可能需要通過 OKE 的配置選項實現 |