variable "vm_name" {
  type        = string
  description = "Name of the virtual machine."
}

variable "computer_name" {
  type        = string
  description = "Windows computer name."
}

variable "nic_name" {
  type        = string
  description = "Name of the network interface."
}

variable "location" {
  type        = string
  description = "Azure region to deploy resources into."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the VM NIC."
}

variable "public_ip_id" {
  type        = string
  description = "Optional public IP ID for the NIC."
  default     = null
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM."
  sensitive   = true
}

variable "zone" {
  type        = string
  description = "Optional availability zone for the VM."
  default     = null
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Image reference for the VM."
}
