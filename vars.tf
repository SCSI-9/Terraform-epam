data "aws_availability_zones" "azs" {
}




variable aws_reg {
  description = "This is aws region"
  default     = "eu-central-1"
  type        = string
}

variable "instance_count" {
  description = "The number of instances to be launched"
  default     = 2
}

#Specify 3 availability zones from the region
variable "availability_zones" {
  type = list
  default = ["eu-central-1a", "eu-central-1b"]
}



variable stack {
  description = "this is name for tags"
  default     = "Adil_Hasanov"
}

variable security_group_name {
  description = "security_group_name"
  default     = "web"
}


variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable dbname {
  description = "db name"
}

variable dbport {
  description = "db port"
}


variable ssh_key {
  default     = "~/.ssh/id_rsa.pub"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "~/.ssh/id_rsa"
  description = "Default private key"
}
