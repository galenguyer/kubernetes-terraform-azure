variable "azure_subscription_id" {
  type    = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable "rg_name" {
  type    = string
  default = "k8s"
}

variable "rg_region" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

// can be one of [Premium_LRS, Standard_LRS, StandardSSD_LRS]
variable "vm_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "username" {
  type    = string
  default = "user"
}

variable "unique_id" {
  type    = string
  default = "galenguyer"
}

variable "worker_count" {
  type    = number
  default = 3
}
