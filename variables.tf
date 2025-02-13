variable "provider_credentials" {
  description = "Azure provider credentials"
  type = object({
    subscription_id  = string
    tenant_id        = string
    sp_client_id     = string
    sp_client_secret = string
  })
}

variable "location" {
  type    = string
  default = "japaneast"
}