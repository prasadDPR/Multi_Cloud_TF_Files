terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.17.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "82fadffa-e34b-4e41-8cb1-5bc72b95ee5a"
  tenant_id       = "184c7f09-848b-4264-bdd4-85b0a73d7db6"
  client_id       = "2ff28675-e779-46a7-aff5-5785842f9cff"
  client_secret   = "yzL8Q~peDNz1-jrpn5l5lWzwClpFewjoqfoNTa_y"
  features {
  }
}


resource "azurerm_resource_group" "RG" {
  name     = "task-RG"
  location = "West Europe"
}

resource "azurerm_network_security_group" "public-SG" {
  name                = "task-public-sg"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "VN" {
  name                = "task-virtual-network"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "publicsub1" {
  name                 = "public-subnet1"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "privatesub1" {
  name                 = "private-subnet1"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "publicsub2" {
  name                 = "public-subnet2"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "privatesub2" {
  name                 = "private-subnet2"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "SaN1" {
  subnet_id                 = azurerm_subnet.publicsub1.id
  network_security_group_id = azurerm_network_security_group.public-SG.id
}

resource "azurerm_subnet_network_security_group_association" "SaN2" {
  subnet_id                 = azurerm_subnet.publicsub2.id
  network_security_group_id = azurerm_network_security_group.public-SG.id
}

resource "azurerm_public_ip" "pip1" {
  name                = "acceptanceTestPublicIp2"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic1" {
  name                = "task-nic1"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "public-subnet1"
    subnet_id                     = azurerm_subnet.publicsub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}


resource "azurerm_network_interface" "nic2" {
  name                = "task-nic2"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "private-subnet1"
    subnet_id                     = azurerm_subnet.privatesub1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "pip2" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic3" {
  name                = "task-nic3"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "public-subnet2"
    subnet_id                     = azurerm_subnet.publicsub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}


resource "azurerm_network_interface" "nic4" {
  name                = "task-nic4"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "private-subnet2"
    subnet_id                     = azurerm_subnet.privatesub2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "AS" {
  name                = "task-aset"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_windows_virtual_machine" "VM1" {
  name                = "public-vm1"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  availability_set_id = azurerm_availability_set.AS.id
  size                = "Standard_F2"
  admin_username      = "Prasad"
  admin_password      = "Prasad@28"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "VM2" {
  name                = "public-vm2"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  availability_set_id = azurerm_availability_set.AS.id
  size                = "Standard_F2"
  admin_username      = "Prasad"
  admin_password      = "Prasad@28"
  network_interface_ids = [
    azurerm_network_interface.nic3.id,
  ]



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "VM-private1" {
  name                = "private-vm1"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  availability_set_id = azurerm_availability_set.AS.id
  size                = "Standard_F2"
  admin_username      = "Prasad"
  admin_password      = "Prasad@28"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



