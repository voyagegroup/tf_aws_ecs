provider "aws" {
  # https://github.com/terraform-providers/terraform-provider-aws/releases
  version = "~> 1.50"
  region  = "ap-northeast-1"
}

provider "template" {
  # https://github.com/terraform-providers/terraform-provider-template/releases
  version = "~> 1.0"
}
