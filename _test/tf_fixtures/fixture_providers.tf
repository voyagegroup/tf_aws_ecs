provider "aws" {
  # https://github.com/terraform-providers/terraform-provider-aws/releases
  version = "~> 2.28"
  region  = "ap-northeast-1"
}

provider "template" {
  # https://github.com/terraform-providers/terraform-provider-template/releases
  version = "~> 2.1"
}
