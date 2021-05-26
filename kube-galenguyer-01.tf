resource "azurerm_public_ip" "kube-01-ip" {
 name                         = "kube-01-ip"
 location                     = "East US"
 resource_group_name          = azurerm_resource_group.kube.name
 allocation_method            = "Static"
 domain_name_label            = "kube-01"
}

resource "azurerm_network_interface" "kube-01-nic" {
    name                        = "kube-01-nic"
    location                    = "eastus"
    resource_group_name         = azurerm_resource_group.kube.name

    ip_configuration {
        name                          = "kube-01-nic-config"
        subnet_id                     = azurerm_subnet.kube-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.kube-01-ip.id
    }
}

resource "azurerm_network_interface_security_group_association" "kube-01-nic-nsg-association" {
    network_interface_id      = azurerm_network_interface.kube-01-nic.id
    network_security_group_id = azurerm_network_security_group.kube-nsg.id
}

resource "azurerm_linux_virtual_machine" "kube-01" {
    name                  = "kube-01"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.kube.name
    network_interface_ids = [azurerm_network_interface.kube-01-nic.id]
    size                  = "Standard_B2s"

    os_disk {
        name                 = "kube-01-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Debian"
        offer     = "debian-10"
        sku       = "10"
        version   = "latest"
    }

    admin_username = var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key = file("~/.ssh/id_rsa.pub")
    }
}
