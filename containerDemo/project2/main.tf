# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "tf-mern-demo"
  location = "eastus"
}

# Cosmos DB account
resource "azurerm_cosmosdb_account" "dbAccount" {
  name                = "tf-mern-demo-cosmosdb-account"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}


# Cosmos DB database
resource "azurerm_cosmosdb_mongo_database" "database" {
  name                = "tf-mern-demo-database"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.dbAccount.name
}

# Express container
resource "azurerm_container_group" "my_todo_backend" {
  name                = "tf-todo_backend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_address_type     = "Public"
  dns_name_label      = "tf-todo_backend"
  restart_policy      = "Always"
  os_type             = "Linux"


  container {
    name   = "tf-todo_backend"
    image  = "kritikverma2002/my_todo_backend:v1.0.1"
    cpu    = "1"
    memory = "1.5"

    environment_variables = {
      MONGO_CONNECTION_STRING = azurerm_cosmosdb_account.dbAccount.connection_strings[0]
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}
resource "azurerm_container_group" "my_todo_frontend" {
  name                = "tf-todo_frontend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_address_type     = "Public"
  dns_name_label      = "tf-todo_frontend"
  restart_policy      = "Always"
  os_type             = "Linux"


  container {
    name   = "my_todo_frontend"
    image  = "kritikverma2002/my_todo_frontend:v1.0.1"
    cpu    = "1"
    memory = "1.5"

    environment_variables = {
      BACKEND_API_URL="http://${azurerm_container_group.my_todo_backend.ip_address}:8080"
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}