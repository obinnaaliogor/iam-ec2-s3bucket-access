variable "instance_type" {
  type = list(string)
  default = [ "t2.micro", "t2.medium" ]
}

variable "key_pair" {
  type = string
  default = "demo"
}