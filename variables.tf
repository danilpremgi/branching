variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "rg-uksouth-windows"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into."
  default     = "UKSouth"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
  default     = "Standard_DS1_v2"
}

variable "jumpbox_vm_size" {
  type        = string
  description = "Azure VM size for the jumpbox."
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Windows VMs."
  default     = "adm_azure"
}
