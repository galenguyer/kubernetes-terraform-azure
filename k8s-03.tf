resource "azurerm_public_ip" "k8s-03-ip" {
 name                         = "k8s-03-ip"
 location                     = "East US"
 resource_group_name          = azurerm_resource_group.k8s.name
 allocation_method            = "Static"
 domain_name_label            = "k8s-${var.uniqueid}-03"
}

resource "azurerm_network_interface" "k8s-03-nic" {
    name                        = "k8s-03-nic"
    location                    = var.region
    resource_group_name         = azurerm_resource_group.k8s.name

    ip_configuration {
        name                          = "k8s-03-nic-config"
        subnet_id                     = azurerm_subnet.k8s-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.k8s-03-ip.id
    }
}

resource "azurerm_network_interface_security_group_association" "k8s-03-nic-nsg-association" {
    network_interface_id      = azurerm_network_interface.k8s-03-nic.id
    network_security_group_id = azurerm_network_security_group.k8s-nsg.id
}

resource "azurerm_linux_virtual_machine" "k8s-03" {
    name                  = "k8s-03"
    location              = var.region
    resource_group_name   = azurerm_resource_group.k8s.name
    network_interface_ids = [azurerm_network_interface.k8s-03-nic.id]
    size                  = "Standard_B2s"

    os_disk {
        name                 = "k8s-03-osdisk"
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