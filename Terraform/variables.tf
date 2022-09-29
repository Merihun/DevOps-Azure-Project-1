
# Azure authentication variables

variable "azure-subscription-id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure-client-id" {
  type        = string
  description = "Azure Client ID"
}

variable "azure-client-secret" {
  type        = string
  description = "Azure Client Secret"
}

variable "azure-tenant-id" {
  type        = string
  description = "Azure Tenant ID"
}



# Network - Variables #

variable "network-vnet-cidr" {
  type        = string
  description = "The CIDR of the network VNET"
}

variable "network-subnet-cidr" {
  type        = string
  description = "The CIDR for the network subnet"
}


# VM - Variables #


# VM Admin User
variable "vm-admin-username" {
  type        = string
  description = "Admin User"
  default     = "vmadmin"
}

# VM Admin Password
variable "vm-admin-password" {
  type        = string
  description = "Admin Password"
  default     = "Pa55w0rd"
}

# VM Hostname (limited to 15 characters long)
variable "vm-hostname" {
  type        = string
  description = "Hostname"
  default     = "mytfhost"
}

# Windows VM Virtual Machine Size
variable "vm-size" {
  type        = string
  description = "VM Size"
  default     = "Standard_B1ls"
}



# Project environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "East US"
}


## Main Variables ##


variable "resource_group" {
  description = "Name of the resource group, including the -rg"
  default     = "udacity-devops-project1-rg"
  type        = string
}

variable "packer_resource_group" {
  description = "Name of the resource group where the packer image is"
  default     = "udacity-packerimage-rg"
  type        = string
}

variable "prefix" {
  description = "The prefix which should be used for all resources in the resource group specified"
  default     = "udacity"
  type        = string
}

variable "num_of_vms" {
  description = "Number of VM resources to create behind the load balancer"
  default     = 2
  type        = number
}
