variable "name" {
  description = "Name of the Resource Group to be used in the tutorial"
  type = string
  default = "kubernetes"
}

variable "location" {
  description = "Location of the resource group"
  type = string
  default = "eastus2"
}
