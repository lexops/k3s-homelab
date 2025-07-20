variable "scylladb_user" {
  type = string
}

variable "scylladb_password" {
  type      = string
  sensitive = true
}

variable "postgresql_user" {
  type = string
}

variable "postgresql_password" {
  type      = string
  sensitive = true
}

variable "rabbitmq_user" {
  type = string
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "meili_master_key" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.meili_master_key) >= 16
    error_message = "The meili_master_key must be at least 16 characters long."
  }
}