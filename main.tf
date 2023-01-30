provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

# Récupération du groupe de ressource (Azure subscription 1)
data "azurerm_resource_group" "_ressource_group" {
  name     = "HUGO_MORIN_GROUPE_RESSOURCE"
  // Emplacement : France Central
  // Id : a7d4ce37-6303-4e62-b920-3898a62c5666
}

#################################### PARTIE 1 ########################################################

# Création du virtual network
resource "azurerm_virtual_network" "_virtual_network" {
  name                = "Vnet_hugo_morin"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
}

# Création du subnet
resource "azurerm_subnet" "_vm_subnet" {
  name                 = "SubnetVm_hugo_morin"
  resource_group_name  = data.azurerm_resource_group._ressource_group.name
  virtual_network_name = azurerm_virtual_network._virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création du Network Security Groupe
resource "azurerm_network_security_group" "_vm_network_security_group" {
  name                = "NetworkSecurityGroupVm_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name

  security_rule {
    name                       = "security_rule_hugo_morin_v1"
    priority                   = 1001
    direction                   = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
  security_rule {
    name                       = "security_rule_hugo_morin_v2"
    priority                   = 1002
    direction                   = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}

# Création d'une IP public
resource "azurerm_public_ip" "_vm_ip_public" {
  name                = "PublicIPVm_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Création de l'interface
resource "azurerm_network_interface" "_vm_interface" {
  name                = "NetworkInterfaceVm_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name

  ip_configuration {
    name                          = "NetworkInterfaceVm_hugo_morin_configuration"
    subnet_id                     = azurerm_subnet._vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip._vm_ip_public.id
  }
}

# Connection du security groupe et de l'interface
resource "azurerm_network_interface_security_group_association" "_interface_x_security_group" {
  network_interface_id      = azurerm_network_interface._vm_interface.id
  network_security_group_id = azurerm_network_security_group._vm_network_security_group.id
}

# Création de la machine virtuel
resource "azurerm_linux_virtual_machine" "_virtual_machine" {
  name                            = "VM_hugo_morin"
  location                        = data.azurerm_resource_group._ressource_group.location
  resource_group_name             = data.azurerm_resource_group._ressource_group.name
  network_interface_ids           = [azurerm_network_interface._vm_interface.id]
  size                            = "Standard_B2s"
  computer_name                   = "vmHhugoMorin"
  admin_username                  = "azure_hugo_morin"
  admin_password                  = "var._adminPassw0rd"
  disable_password_authentication = false

  os_disk {
    name                 = "OsDisk_hugo_morin"
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

#Instalation d'apache
resource "azurerm_virtual_machine_extension" "_virtual_machine_extension" {
  name                 = "virtualMachineExtension_hugo_morin"
  virtual_machine_id   = azurerm_linux_virtual_machine._virtual_machine.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt -y install apache2 && sudo systemctl start apache2"
 }
SETTINGS
}

#################################### PARTIE 2 ########################################################

# Création du subnet
resource "azurerm_subnet" "_as_subnet" {
  name                 = "SubnetAs_hugo_morin"
  resource_group_name  = data.azurerm_resource_group._ressource_group.name
  virtual_network_name = azurerm_virtual_network._virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
  private_link_service_network_policies_enabled = false
}

# Création du Network Security Groupe
resource "azurerm_network_security_group" "_as_network_security_group" {
  name                = "NetworkSecurityGroupAs_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name

  security_rule {
    name                       = "security_rule_as_hugo_morin_v1"
    priority                   = 1001
    direction                   = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
  security_rule {
    name                       = "security_rule_as_hugo_morin_v2"
    priority                   = 1002
    direction                   = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}

# Création d'une IP public
resource "azurerm_public_ip" "_as_ip_public" {
  name                = "PublicIPAs_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Création de l'interface
resource "azurerm_network_interface" "_as_interface" {
  name                = "NetworkInterfaceAs_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name

  ip_configuration {
    name                          = "NetworkInterfaceAs_hugo_morin_configuration"
    subnet_id                     = azurerm_subnet._as_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip._as_ip_public.id
  }
}

# Connection du security groupe et de l'interface
resource "azurerm_network_interface_security_group_association" "_as_interface_x_as_security_group" {
  network_interface_id      = azurerm_network_interface._as_interface.id
  network_security_group_id = azurerm_network_security_group._as_network_security_group.id
}


# Création du plan app service
resource "azurerm_service_plan" "_service_plan" {
  name                = "planAppService_hugo_morin"
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  location            = data.azurerm_resource_group._ressource_group.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Création de l'app service
resource "azurerm_linux_web_app" "_web_app" {
  name                = "webAppHugoMorin"
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  location            = azurerm_service_plan._service_plan.location
  service_plan_id     = azurerm_service_plan._service_plan.id

  site_config {
    application_stack {
      php_version = "8.0"
    }
  }

  identity {
    type="SystemAssigned"
  }

  app_settings = {
    "user" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret._key_vault_secret.id})"
  }
}

# Création du coffre de clé
resource "azurerm_key_vault" "_key_vault" {
  name                        = "keyVaultHugoMorin"
  location                    = data.azurerm_resource_group._ressource_group.location
  resource_group_name         = data.azurerm_resource_group._ressource_group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "List",
      "Purge",
      "Set",
      "Get",
      "Delete",
      "Recover",
      "Restore",
      "Backup"
    ]
  }
  sku_name = "standard"
}

# Création du secret dans le coffre de clé
resource "azurerm_key_vault_secret" "_key_vault_secret" {
  name         = "User"
  value        = "TOTO"
  key_vault_id = azurerm_key_vault._key_vault.id
}

# Ecriture de l'id dans index.txt
resource "null_resource" "_resource_id" {
  provisioner "local-exec" {
    command = "(Get-AzWebApp -Name ${azurerm_linux_web_app._web_app.name}).Identity.PrincipalId > ./index.txt"
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [
    azurerm_linux_web_app._web_app
  ]
}

# Récupération de l'id
data "local_file" "_file_id" {
  filename = "${path.module}/index.txt"

  depends_on = [
    null_resource._resource_id
  ]
}

# Création du secret dans le coffre de clé pour la web app
resource "azurerm_key_vault_access_policy" "_key_vault_access_policy" {
  key_vault_id = azurerm_key_vault._key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = "9aac96e4-31dc-4356-a396-e433444d5826"

  secret_permissions = [
      "Get",
      "List",
  ]

  depends_on = [
    data.local_file._file_id
  ]
}

#################################### PARTIE 3 ########################################################

# Création du server postgreSQL
resource "azurerm_postgresql_server" "_postgresql_server" {
  name                = "postgresqlserverhugomorin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  sku_name = "GP_Gen5_4"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

# Création du firewall
resource "azurerm_postgresql_firewall_rule" "_postgresql_firewall_rule" {
  name                = "postgresqlFirewallRule_hugo_morin"
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  server_name         = azurerm_postgresql_server._postgresql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Création de la BD postgreSQL
resource "azurerm_postgresql_database" "_postgresql_database" {
  name                = "postgresqlDatabase_hugo_morin"
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  server_name         = azurerm_postgresql_server._postgresql_server.name
  charset             = "UTF8"
  collation           = "fr-FR"
}



/*
resource "null_resource" "test" {
  provisioner "local-exec" {
    command = ""
    interpreter = ["pwsh", "-Command"]
  }
}
*/

resource "azurerm_app_service_source_control" "_app_service_source_control" {
  app_id   = azurerm_linux_web_app._web_app.id
  repo_url = ""
  branch   = "master"
  use_manual_integration = true
}


#################################### PARTIE 4 ########################################################
/*
# Création du load balancer
resource "azurerm_lb" "_lb" {
  name                = "lb_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "businessLbFrontendIp_hugo_morin"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet._as_subnet.id
  }

  depends_on = [
    azurerm_public_ip._as_ip_public
  ]
}

# Création du lien privé
resource "azurerm_private_link_service" "_private_link_service" {
  name                = "privateLink_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  

  nat_ip_configuration {
    name      = azurerm_public_ip._as_ip_public.name
    subnet_id = azurerm_subnet._as_subnet.id
    private_ip_address_version = "IPv4"
    primary   = true
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb._lb.frontend_ip_configuration.0.id,
  ]
}

# Création du point de terminaison 
resource "azurerm_private_endpoint" "_private_endpoint" {
  name                = "privateEndpoint_hugo_morin"
  location            = data.azurerm_resource_group._ressource_group.location
  resource_group_name = data.azurerm_resource_group._ressource_group.name
  subnet_id           = azurerm_subnet._as_subnet.id

  private_service_connection {
    name                           = "privateServiceConnection_hugo_morin"
    private_connection_resource_id = azurerm_private_link_service._private_link_service.id
    is_manual_connection           = false
  }
}*/
