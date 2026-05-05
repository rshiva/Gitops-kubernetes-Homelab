terraform{
  required_version = ">=1.14.0"
    required_providers{
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.92"
    }
  }


  backend "s3"{
    bucket  =  "devopsrt-home-lab-tfstate-dev"
    key = "devopsrt-home-lab-dev/terraform.tfstate"
    region="ap-south-1"
    dynamodb_table="devopsrt-home-lab-tfstate-lock-dev"
    encrypt = true
  }
}
