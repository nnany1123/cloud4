# 서울 tgw 생성하는 vpc
module "seoul_mgt_vpc" {
  region_name = "seoul"
  region_numeral = "10"
  region = "ap-northeast-2"
  source = "/home/ec2-user/terraform/module/vpc-tgw"
  cidr_numeral = "16"
  vpc_name ="mgt"
  availability_zones_without_b = ["ap-northeast-2a", "ap-northeast-2c"]
  cidr_numeral_public = ["24","48"]
  cidr_numeral_private = ["72","96"]
  cidr_numeral_private_tgw = ["120","144"]
  destination_cidr = "${module.seoul_prod_vpc.cidr}"
  peer_region = "${module.singapore_mgt_vpc.singapore_region_name}"
  peer_tgw = "${module.singapore_mgt_vpc.tgw}"
  peer_att = "${module.singapore_mgt_vpc.peer_att}"
  key_pair = ""
}

# 서울 생성된 tgw에 연결 하는 vpc
module "seoul_prod_vpc" {
  region_name = "seoul"
  region_numeral = "10"
  region = "ap-northeast-2"
  source = "/home/ec2-user/terraform/module/vpc-att"
  cidr_numeral = "48"
  vpc_name ="prod"
  availability_zones_without_b = ["ap-northeast-2a", "ap-northeast-2c"]
  cidr_numeral_public = ["24","48"]
  cidr_numeral_private = ["72","96"]
  cidr_numeral_private_tgw = ["120","144"]
  tgw_subnet       = "${module.seoul_mgt_vpc.tgw_subnet}"
  destination_cidr = "${module.seoul_mgt_vpc.cidr}"
  tgw              = "${module.seoul_mgt_vpc.tgw}"
  tgw_rt           = "${module.seoul_mgt_vpc.tgw_route_table_id}"
  key_pair = ""
}

# 싱가포르 tgw 생성하는 vpc
module "singapore_mgt_vpc" {
  region_name = "singapore"
  region_numeral = "20"
  region = "ap-southeast-1"
  source = "/home/ec2-user/terraform/module/vpc-tgw-peer"
  cidr_numeral = "16"
  vpc_name ="mgt"
  availability_zones_without_b = ["ap-southeast-1a", "ap-southeast-1c"]
  cidr_numeral_public = ["24","48"]
  cidr_numeral_private = ["72","96"]
  cidr_numeral_private_tgw = ["120","144"]
  seoul_account_id = "${module.seoul_mgt_vpc.account_id}"
  seoul_region     = "${module.seoul_mgt_vpc.seoul_region_name}"
  tgw              = "${module.seoul_mgt_vpc.tgw}"
  peer_att = "${module.seoul_mgt_vpc.peer_att}"
  key_pair = ""
}

terraform {
  backend "s3" {
    bucket = "terraform-state-file-cloud4"
	key    = "terraform/terraform.tfstate"
	region = "ap-northeast-2"
	dynamodb_table = "terraform-state-locks-cloud4"
	encrypt = true
	}
}
