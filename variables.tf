variable "location" {
  type    = string
  default = "\"uksouth\""
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}
