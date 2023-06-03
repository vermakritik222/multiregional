# Resource group
resource "azurerm_resource_group" "eastus_rg" {
  name     = "eastus_rg_1"
  location = "eastus"
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "eastus_rg_1"
  location = "eastus"
}


# Virtual networks
resource "azurerm_virtual_network" "vnet" {
  name                = "eastus_vnet_1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

# ----------------JUMP BOX VM START--------------------
# Create a subnet for the jump box
resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "eastus_jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

## Create a network security group for the jump box
resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "eastus_jumpbox-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH inbound access to the jump box
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }
}

# Create a network interface for the jump box
resource "azurerm_network_interface" "jumpbox_nic" {
  name                      = "eastus_jumpbox-nic"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  subnet_id                 = azurerm_subnet.jumpbox_subnet.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

# Create a virtual machine for the jump box
resource "azurerm_virtual_machine" "eastus_jumpbox" {
  name                  = "eastus_jumpbox_vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jumpbox-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "jumpbox-vm"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# ----------------------JUMP BOX VM END---------------------------------
# ----------------------BACKEND VM START----------------------------------
# Backend Subnet 
resource "azurerm_subnet" "backend_subnet" {
  name                 = "eastus_backend_subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  # security_group = azurerm_network_security_group.example.id
}

## Create a network security group for the jump box
# Backend NSG 

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "eastus_nsg_backend_1"
  location            = azurerm_resource_group.eastus_rg.location
  resource_group_name = azurerm_resource_group.eastus_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefixes    = ["0.0.0.0/0"]
    destination_address_prefix = "*"
  }
}

# interface cards (2)

resource "azurerm_network_interface" "eastus_nic_backend1" {
  name                      = "eastus_nic_backend_1"
  location                  = azurerm_resource_group.eastus_rg.location
  resource_group_name       = azurerm_resource_group.eastus_rg.name
  network_security_group_id = azurerm_network_security_group.eastus_nsg_backend.id

  ip_configuration {
    name                          = "eastus_nic_backend_ipconfig"
    subnet_id                     = azurerm_subnet.eastus_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


# VM backend 
resource "azurerm_virtual_machine" "eastus_backend_vm1" {
  name                  = "eastus_backend_vm1"
  location              = azurerm_resource_group.eastus_rg.location
  resource_group_name   = azurerm_resource_group.eastus_rg.name
  network_interface_ids = [azurerm_network_interface.eastus_nic_backend1.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }

  connection {
    type        = "ssh"
    host        = azurerm_virtual_machine.jumpbox.private_ip_address
    user        = "adminuser"
    password    = "Password1234!"
    port        = 22
    agent       = false
    timeout     = "1m"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
}

# Output the public IP address of the VM
output "public_ip" {
  value = azurerm_virtual_machine.example.public_ip_address
}
# -----------------------------BACKEND VM END -----------------

# Virtual networks              OK

  # Subnets (2)                 OK(1) 

# NSG (2)                       OK(1)

  # interface cards (2)         OK(1)

# VM frontend 

# Application gateway

  # frontend Config

  # backend pool

  # health prob

  #

# VM backend                      OK

# Load balancer

  # frontend Config

  # backend pool

  # health prob

  #

