variable "region" { type = string default = "us-east-1" }
variable "project" { type = string default = "mono2micro" }
variable "cluster_name" { type = string default = "mono2micro-cluster" }
variable "node_group_name" { type = string default = "mono2micro-ng" }
variable "node_count" { type = number default = 2 }
