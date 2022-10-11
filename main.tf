terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgproject4" {
  name     = "rgproject4"
  location = "west europe"
}

resource "azurerm_virtual_network" "vnetp4" {
  name                = "vnetp4"
  location            = azurerm_resource_group.rgproject4.location
  resource_group_name = azurerm_resource_group.rgproject4.name
  address_space       = ["10.0.0.0/16"]


  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "p4-subnet" {
  name                 = "p4-subnet"
  resource_group_name  = azurerm_resource_group.rgproject4.name
  virtual_network_name = azurerm_virtual_network.vnetp4.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "p4-sg" {
  name                = "p4-sg"
  location            = azurerm_resource_group.rgproject4.location
  resource_group_name = azurerm_resource_group.rgproject4.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "p4-rule" {
  name                        = "p4-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgproject4.name
  network_security_group_name = azurerm_network_security_group.p4-sg.name
}


resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.p4-subnet.id
  network_security_group_id = azurerm_network_security_group.p4-sg.id
}


resource "azurerm_network_interface" "p4-nic" {
  name                = "p4-nic"
  location            = azurerm_resource_group.rgproject4.location
  resource_group_name = azurerm_resource_group.rgproject4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.p4-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "p4-vm" {
  name                = "p4-vm"
  resource_group_name = azurerm_resource_group.rgproject4.name
  location            = azurerm_resource_group.rgproject4.location
  size                = "Standard_D2as_v4"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.p4-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/Users/gunwathecreator/devopslearn/project4/key/project4azurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
