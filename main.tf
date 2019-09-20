resource "random_pet" "name" {
 length    = "39"
 separator = "-"
}


resource "null_resource" "helloWorld" {
  provisioner "local-exec" {
    command = "echo ${random_pet.name.id}"
  }
}
