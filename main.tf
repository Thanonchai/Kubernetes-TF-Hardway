provider "azurerm" {
  version = "=2.20.0"
  features {}
}

module resource_group {
  source = "./modules/resource_group"
}

resource "azurerm_virtual_network" "vnet" {
  name = "kubernetes-vnet"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  address_space = ["10.240.0.0/24"]
}

resource "azurerm_subnet" "k8s-subnet" {
  name = "kubernetes-subnet"
  resource_group_name = module.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.240.0.0/24" ]
}

resource "azurerm_subnet_network_security_group_association" "k8s-sn-nsg" {
  subnet_id = azurerm_subnet.k8s-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
  name = "kubernetes-nsg"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
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
  resource_group_name = module.resource_group.name
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
  resource_group_name = module.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "pip" {
  name = "kubernetes-pip"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  allocation_method = "Static"
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  name = "kubernetes-lb-pool"
  resource_group_name = module.resource_group.name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb" "lb" {
  name = "kubernetes-lb"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  
  frontend_ip_configuration {
    name = "pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

module controller {
  source = "./modules/controller"
  rg_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = azurerm_subnet.k8s-subnet.id
  lb_id = azurerm_lb_backend_address_pool.lb-pool.id
  image_id = var.image_id
}

//resource "azurerm_availability_set" "controller-as" {
//  name = "controller-as"
//  resource_group_name = module.resource_group.name
//  location = module.resource_group.location
//}
//
//resource "azurerm_public_ip" "controller-pip" {
//  count = 2
//  name = join("-", ["controller", count.index, "pip"])
//  resource_group_name = module.resource_group.name
//  location = module.resource_group.location
//  allocation_method = "Dynamic"
//}
//
//resource "azurerm_network_interface" "nic" {
//  count = 2
//  name = join("-", ["worker", count.index, "nic"])
//  resource_group_name = module.resource_group.name
//  location = module.resource_group.location
//  ip_configuration {
//    name = "worker"
//    private_ip_address_allocation = "Static"
//    private_ip_address = "10.240.0.2${count.index}"
//    public_ip_address_id = azurerm_public_ip.controller-pip[count.index].ip_address
//    subnet_id = azurerm_subnet.k8s-subnet.id
//  }
//  
//}
