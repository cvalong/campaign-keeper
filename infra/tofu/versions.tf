# Which OpenTofu and which provider versions this code expects.
# Pinning means a future provider release can't silently change behavior.
terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # any 6.x, never 7.0
    }
  }
}

# How to talk to AWS. Credentials are NOT here: they come from the
# AWS_PROFILE environment variable, so this file works on any machine.
provider "aws" {
  region = "us-west-2" 

  # Stamped onto every resource this code creates, so costs split by project.
  default_tags {
    tags = {
      project = "campaign-keeper" 
    }
  }
}
