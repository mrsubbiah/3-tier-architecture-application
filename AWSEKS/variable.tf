variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["192.168.16.0/20", "192.168.32.0/20", "192.168.0.0/20"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["192.168.48.0/20", "192.168.64.0/20", "192.168.80.0/20"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "instance_types" {
  description = "EC2 instance type"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "AWS_REGION" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}
