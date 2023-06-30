variable "vpc_configuration" {
  type = object({
    name       = string,
    cidr_block = string,
    subnets = list(object({
      name       = string,
      public     = bool,
      cidr_block = string
    }))
  })
  default = {
    name       = "my-vpc"
    cidr_block = "10.0.0.0/16"
    subnets = [
      {
        name       = "private-a"
        public     = false
        cidr_block = "10.0.101.0/24"
      },
      {
        name       = "private-b"
        public     = false
        cidr_block = "10.0.102.0/24"
      },
      {
        name       = "private-c"
        public     = false
        cidr_block = "10.0.103.0/24"
      },
      {
        name       = "public-a"
        public     = true
        cidr_block = "10.0.1.0/24"
      },
      {
        name       = "public-b"
        public     = true
        cidr_block = "10.0.2.0/24"
      },
      {
        name       = "public-c"
        public     = true
        cidr_block = "10.0.3.0/24"
      }
    ]
  }
}
