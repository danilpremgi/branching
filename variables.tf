variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "rg-uksouth-windows"
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into."
  default     = "East US"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for the deployment."
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
  default     = "Standard_B2ms"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Windows VMs."
  default     = "adm_azure"
}
