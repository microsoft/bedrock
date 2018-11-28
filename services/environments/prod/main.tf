module "services" {
  source = "../../modules/services"
}

module "simple-service" {
  source = "../../modules/simple-service"

  environment = "prod"

  depends_on = ["module.services"]
}
