variable "length" {
  type = string
#   default = "5"
}

resource "random_pet" "name" {
 length    = "9"
 separator = "-"
}

 resource "random_pet" "name44" {
  length    = var.length
  separator = "-"
 }


resource "null_resource" "helloWorld" {
  provisioner "local-exec" {
    command = "echo ${random_pet.name.id}"
  }
}

output "random_pet_name" {
  value       = random_pet.name.id
}

output "random_pet_name44" {
  value       = random_pet.name44.id
}
