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
  subscription_id = var.azure_subscription_id
  features {}
}

resource "azurerm_resource_group" "k8s" {
  name     = "k8s"
  location = var.region
}

resource "azurerm_virtual_network" "k8s-vnet" {
 name                = "k8s-vnet"
 address_space       = ["10.0.0.0/16"]
 location            = var.region
 resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_subnet" "k8s-subnet" {
 name                 = "k8s-subnet"
 resource_group_name  = azurerm_resource_group.k8s.name
 virtual_network_name = azurerm_virtual_network.k8s-vnet.name
 address_prefixes       = ["10.0.8.0/24"]
}

resource "azurerm_network_security_group" "k8s-nsg" {
    name                = "k8s-nsg"
    location            = var.region
    resource_group_name = azurerm_resource_group.k8s.name

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
        name                       = "k8slet API controller"
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
        name                       = "k8s-scheduler"
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
        name                       = "k8s-controller-manager"
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
        name                       = "k8slet API worker"
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
