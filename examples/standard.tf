#####################
### Prerequisites ###
#####################

provider "azurerm" {
  features {}
}

# Manages an Azure Resource Group.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
#
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Canada Central"
}

# Manages an Azure Virtual Network.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
#
resource "azurerm_virtual_network" "example" {
  name                = "example-vn"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Manages an Azure Subnet within a Virtual Network. The subnet name must be RouteServerSubnet.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
#
resource "azurerm_subnet" "example" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

###########################
### Route Server Module ###
###########################

# Invokes the terraform-azurerm-route-server module used to create an Azure Route Server and BGP connections within it.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
#
module "route_server_example" {
  source = "../"

  naming_convention = "gc"
  user_defined      = "example"

  azure_resource_attributes = {
    department_code = "Gc"
    owner           = "ABC"
    project         = "aur"
    environment     = "dev"
    location        = azurerm_resource_group.example.location
    instance        = 0
  }

  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example.id

  bgp_peers = [
    {
      name     = "nva1"
      peer_asn = "65501"
      peer_ip  = "169.254.21.5"
    }
  ]

  tags = {
    "tier" = "k8s"
  }
}
