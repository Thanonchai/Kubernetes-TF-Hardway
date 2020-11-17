provider "azurerm" {
  version = "=2.20.0"
  features {}
}

resource "azurerm_resource_group" "k8s" {
  name = "kubernetes"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name = "kubernetes-vnet"
  resource_group_name = azurerm_resource_group.k8s.name
  location = azurerm_resource_group.k8s.location
  address_space = ["10.240.0.0/24"]

  subnet {
    name = "kubernetes-subnet"
    address_prefix = "10.240.0.0/24"
    security_group = azurerm_network_security_group.nsg.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = "kubernetes-nsg"
  resource_group_name = azurerm_resource_group.k8s.name
  location = azurerm_resource_group.k8s.location
}

resource "azurerm_network_security_rule" "nsg-allow-ssh" {
  name = "kubernetes-allow-ssh"
  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = 22
  direction = "Inbound"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  priority = 1000
  resource_group_name = azurerm_resource_group.k8s.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "nsg-allow-api-server" {
  name = "kubernetes-allow-api-server"
  access = "Allow"
  destination_address_prefix = "*"
  destination_port_range = 6443
  direction = "Inbound"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  priority = 1001
  resource_group_name = azurerm_resource_group.k8s.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "pip" {
  name = "kubernetes-pip"
  resource_group_name = azurerm_resource_group.k8s.name
  location = azurerm_resource_group.k8s.location
  allocation_method = "Static"
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  name = "kubernetes-lb-pool"
  resource_group_name = azurerm_resource_group.k8s.name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb" "lb" {
  name = "kubernetes-lb"
  resource_group_name = azurerm_resource_group.k8s.name
  location = azurerm_resource_group.k8s.location
  
  frontend_ip_configuration {
    name = "pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
