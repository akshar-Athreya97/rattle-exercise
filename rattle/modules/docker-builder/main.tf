terraform {
    required_providers {
    # We recommend pinning to the specific version of the Docker Provider you're using
    # since new versions are released frequently
        docker = {
            source  = "kreuzwerker/docker"
            version = "3.0.2"
        }
    }
}

provider docker {
  host = "unix:///Users/akshar/.docker/run/docker.sock"
  registry_auth {
    address = "docker.io"
    config_file = pathexpand("~/.docker/config.json")
  }
}

resource "docker_image" "hello-world" {
  name = var.image_name
  build {
    context = "."
    dockerfile = var.dockerfile_path
  }
}

resource "docker_registry_image" "akshar1" {
  name = var.image_name
  keep_remotely = true
}
