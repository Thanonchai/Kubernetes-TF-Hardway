// This changes all the time as Canonical only publishes daily build
variable "controller_numbers" {
  type = list(number)
  default = [0, 1]
}

variable "image_id" {
  type = string
}
