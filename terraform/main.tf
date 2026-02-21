terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
  backend "s3" {

    #Backend confiog from the .tfbackend file
  }

}

provider "aws" {
    region = var.aws_region
    default_tags {
      tags = merge(var.tags,{
        project = var.project_name
        environment = var.environment
      })
    }
}  


