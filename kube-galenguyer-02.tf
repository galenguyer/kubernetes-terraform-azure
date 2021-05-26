resource "azurerm_public_ip" "kube-02-ip" {
 name                         = "kube-02-ip"
 location                     = "East US"
 resource_group_name          = azurerm_resource_group.kube.name
 allocation_method            = "Static"
 domain_name_label            = "kube-${var.uniqueid}-02"
}

resource "azurerm_network_interface" "kube-02-nic" {
    name                        = "kube-02-nic"
    location                    = "eastus"
    resource_group_name         = azurerm_resource_group.kube.name

    ip_configuration {
        name                          = "kube-02-nic-config"
        subnet_id                     = azurerm_subnet.kube-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.kube-02-ip.id
    }
}

resource "azurerm_network_interface_security_group_association" "kube-02-nic-nsg-association" {
    network_interface_id      = azurerm_network_interface.kube-02-nic.id
    network_security_group_id = azurerm_network_security_group.kube-nsg.id
}

resource "azurerm_linux_virtual_machine" "kube-02" {
    name                  = "kube-02"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.kube.name
    network_interface_ids = [azurerm_network_interface.kube-02-nic.id]
    size                  = "Standard_B2s"

    os_disk {
        name                 = "kube-02-osdisk"
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
