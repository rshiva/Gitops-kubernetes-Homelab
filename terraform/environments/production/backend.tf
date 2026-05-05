backend "s3"{
  bucket  =  "devopsrt-home-lab-tfstate-prod"
  key = "devopsrt-home-lab-prod/terraform.tfstate"
  region="ap-south-1"
  dynamodb_table="devopsrt-home-lab-tfstate-lock-prod"
  encrypt = true
}
