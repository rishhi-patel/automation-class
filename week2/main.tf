terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

resource "docker_image" "demo_web" {
  name = "demo-web-app:latest"
  build {
    context    = path.module
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "demo_web_container" {
  image = docker_image.demo_web.image_id
  name  = "node-web-app"
  ports {
    internal = 3000
    external = 3000
  }
}