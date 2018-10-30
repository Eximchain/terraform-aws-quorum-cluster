# This file is to be placed in the quorum-vpc-peering directory

variable "quorum_vpc_main_route_table" {
  description = "A mapping from region to the quorum VPC main route table in that region"
  type        = "map"
}