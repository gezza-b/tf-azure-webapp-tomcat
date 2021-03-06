provider "azurerm" {
  version = ">= 1.6.0"
}

terraform {
  required_version = ">= 0.11.0"
}

resource "azurerm_resource_group" "rg_webapp" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.rg_tags}"
}

resource "azurerm_app_service_plan" "webserviceplan" {
  name                = "${var.service_plan_name == "" ? replace(var.name, "/[^a-z0-9]/", "") : var.service_plan_name}"
  location            = "${azurerm_resource_group.rg_webapp.location}"
  resource_group_name = "${azurerm_resource_group.rg_webapp.name}"
  
  kind                = "${var.plan_settings["kind"]}"
  
  sku {
    tier     = "${var.plan_settings["tier"]}"
    size     = "${var.plan_settings["size"]}"
    capacity = "${var.plan_settings["capacity"]}"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "${var.name}"
  location            = "${azurerm_resource_group.rg_webapp.location}"
  resource_group_name = "${azurerm_resource_group.rg_webapp.name}"
  app_service_plan_id = "${azurerm_app_service_plan.webserviceplan.id}"
  site_config         = {
    java_container = "TOMCAT"
    java_container_version = "8.5"
    java_version = "1.8"
  }
  app_settings        = "${var.app_settings}"
}