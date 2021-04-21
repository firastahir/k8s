variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
}

variable "k8s_version" {
  description = "Kubernetes version."
}

variable "vpc_id" {
  description = "The VPC the cluser should be created in"
}

variable "primary_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs, must be in at least two different availability zones"
}

variable "secondary_subnet_ids" {
  type        = list(string)
  description = "List of secondary subnet IDs, must be in at least two different availability zones, NON 1918"
}

variable "kubeconfig_path" {
  description = "Path where the config file for kubectl should be written to"
}
