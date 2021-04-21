variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default     = "eks-demo"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-west-2"
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
  default     = "~/.kube"
}

variable "k8s_version" {
  description = "kubernetes version"
  default = "1.19"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "vpc-df52fab9"
}

variable "primary_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs, must be in at least two different availability zones"
  default     = ["subnet-1bda207d"]
}

variable "secondary_subnet_ids" {
  type        = list(string)
  description = "List of secondary subnet IDs, must be in at least two different availability zones, NON 1918"
  default     = ["subnet-de362a97"]
}