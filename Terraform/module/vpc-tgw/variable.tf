
variable "region" {
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "cidr_numeral" {
  description = "The VPC CIDR numeral (10.x.0.0/16)" # x에 들어갈 1자리만
}

variable "aws_region" {
  default = "ap-northeast-2"
}


variable "region_name" {

}






variable "cidr_numeral_public" { # 요 디폴트 순서대로 count.index로 순서대로 값 할당됨.
}


variable "region_numeral" {

}



variable "cidr_numeral_private" {

}


#variable "cidr_numeral_private_db" {


variable "private_subnet" {
  default = "2"


}


#variable "cluster-name" {
#  type    = string
#}




variable "availability_zones_without_b" {
  type        = list(string)
  description = "A comma-delimited list of availability zones except for ap-northeast-2b"#["ap-northeast-2a" , "ap-northeast-2c"]
}



variable "key_pair" {
}



variable "destination_cidr" {
  description = "destination_cidr"
}



variable "peer_region" {}

variable "peer_tgw" {}

variable "peer_att" {}

variable "private_subnet_tgw" {
  default = "2"
}

variable "cidr_numeral_private_tgw" {
}