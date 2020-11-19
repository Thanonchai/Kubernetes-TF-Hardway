provider "azurerm" {
  version = ">=2.20.0"
  features{}
}

resource "azurerm_availability_set" "worker-as" {
  name = "${var.type_name}-as"
  resource_group_name = var.rg_name
  location = var.location
}

resource "azurerm_public_ip" "worker-pip" {
  count = var.amount
  name = join("-", [var.type_name, count.index, "pip"])
  resource_group_name = var.rg_name
  location = var.location
  allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "worker-nic" {
  count = var.amount
  name = join("-", [var.type_name, count.index, "nic"])
  resource_group_name = var.rg_name
  location = var.location
  enable_ip_forwarding = true
  ip_configuration {
    name = "worker"
    private_ip_address_allocation = "Static"
    private_ip_address = "${var.ip_prefix}${count.index}"
    public_ip_address_id = azurerm_public_ip.worker-pip[count.index].ip_address
    subnet_id = var.subnet_id
  }
}

resource "azurerm_linux_virtual_machine" "worker-vm" {
  count = var.amount
  name = "${var.type_name}-${count.index}"
  resource_group_name = var.rg_name
  location = var.location
  size = var.vm_size
  network_interface_ids = [azurerm_network_interface.worker-nic[count.index].id]
  availability_set_id = azurerm_availability_set.worker-as.id
  admin_username = "kuberoot"

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = "kuberoot"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = split(":", var.image_id)[0] 
    offer = split(":", var.image_id)[1]
    sku = split(":", var.image_id)[2]
    version = split(":", var.image_id)[3]
  }

  tags = {
    pod-cidr = "${var.pod_cidr}.${count.index}.0/24"
  }

}
