variable "datacenter" {
  type        = string
  description = "Datacenter name to create the VM in"
}

variable "datastore" {
  type        = string
  description = "Datastore name to place the VM in"
}

variable "resource_pool_name" {
  type        = string
  description = "Name of the resource pool to place in the VM in"
}

variable "template_name" {
  type        = string
  description = "VM template name to clone"
}

variable "vm_name" {
  type        = string
  description = "VM name"
}

variable "vm_folder" {
  type = string
  description = "VM folder path relative to the datacenter"
  default     = null
}

variable "cpu" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Amount of RAM to allocate (MB)"
  default     = 4096
}

variable "nics" {
  type = list(
    object({
      network = string
      ip      = string
      netmask  = number
      gateway = string
  }))
}

variable "dns" {
  type = list(string)
  description = "List of DNS servers to configure the guest OS with"
  default = []
}

variable "domains" {
    type = list(string)
    description = "List of search domains to configure the guest OS with"
    default = []
}

variable "data_disk" {
  description = "Additional disks to add to the VM"
  type        = map(map(string))
  default     = {}
}

variable "disk_label" {
  description = "Optional labels for added disks"
  type        = list(any)
  default     = []
}

variable "disk_size_gb" {
  description = "List of disk sizes to override template disk size"
  type        = list(any)
  default     = null
}

variable "disk_datastore" {
  description = "Datastore where template disks should be placed"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to assign to the VM formatted as a map (category: tag)"
  type        = map(any)
  default     = null
}

variable "custom_attributes" {
  description = "Map of custom attribute ids to attribute value strings to set for virtual machine."
  type        = map(any)
  default     = null
}

variable "script" {
    description = "Shell script to run at boot on guest OS"
    type = string
    default = ""
}