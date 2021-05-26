# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  subscription_id = vars.azure_subscription_id
  features {}
}

resource "azurerm_resource_group" "kube" {
  name     = "kube"
  location = "eastus"
}

resource "azurerm_virtual_network" "kube-galenguyer-vnet" {
 name                = "kube-galenguyer-vnet"
 address_space       = ["10.0.0.0/16"]
 location            = "eastus"
 resource_group_name = azurerm_resource_group.kube.name
}

resource "azurerm_subnet" "kube-galenguyer-subnet" {
 name                 = "kube-galenguyer-subnet"
 resource_group_name  = azurerm_resource_group.kube.name
 virtual_network_name = azurerm_virtual_network.kube-galenguyer-vnet.name
 address_prefixes       = ["10.0.8.0/24"]
}

resource "azurerm_network_security_group" "kube-galenguyer-nsg" {
    name                = "kube-galenguyer-nsg"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.kube.name

    # normal stuff
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    # control plane
    security_rule {
        name                       = "Kube API Server"
        priority                   = 1100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "etcd server client API"
        priority                   = 1101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "2379-2380"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "kubelet API controller"
        priority                   = 1102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "10250"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "kube-scheduler"
        priority                   = 1103
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "10251"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "kube-controller-manager"
        priority                   = 1104
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "10252"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    # worker node stuff
    security_rule {
        name                       = "kubelet API worker"
        priority                   = 1110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "10250"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "NodePort Services"
        priority                   = 1111
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "30000-32767"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "*"
    }
}
