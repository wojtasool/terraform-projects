variable "keycloak_url" {
  type    = string
  default = "https://github.com/keycloak/keycloak/releases/download/"
}
variable "keycloak_version" {
  type    = string
  default = "14.0.0"
}
variable "default_memory" {
  type    = string
  default = "2048"
}
variable "default_cpu" {
  type    = string
  default = "2"
}
variable "default_os_disk" {
  default = "/opt/RAID10/base_image/base_oel7uek_template.qcow2"
  type    = string
}
