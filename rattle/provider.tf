terraform {
    required_providers {
    # We recommend pinning to the specific version of the Docker Provider you're using
    # since new versions are released frequently
        docker = {
            source  = "kreuzwerker/docker"
            version = "3.0.2"
        }
        aws = {
            source = "hashicorp/aws"
            version = "5.39.1"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "2.27.0"
        }
    }
}

provider docker {
    host = "unix:///Users/akshar/.docker/run/docker.sock"
    registry_auth {
        address = "registry-1.docker.io"
        config_file = pathexpand("~/.docker/config.json")
    }
}

provider "aws" {
    region = "us-west-2"
    profile = "test"
} 

provider "kubernetes" {
    config_path = pathexpand("~/.kube/config")
}