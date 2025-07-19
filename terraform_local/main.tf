terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

resource "local_file" "demo" {
    filename = "C:/Users/DHANU WORLD/Desktop/DhanuDevopsWorld.txt"
    content = "hello dhanu"
  
}