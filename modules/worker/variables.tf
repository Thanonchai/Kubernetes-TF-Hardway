variable "amount" {
  type = number
  default = 2
}

variable "ip_prefix" {
  type = string
  default = "10.240.0.2"
}

variable "type_name" {
  type = string
  default = "worker"
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "vm_size" {
  type = string
  default = "Standard_B2ms"
}

variable "pod_cidr" {
  type = string
  default = "10.200"
}
