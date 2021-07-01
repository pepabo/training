resource "aws_instance" "test" {
  ami           = "ami-0ac80df6eff0e70b5"
  instance_type = "t2.micro"
  subnet_id = "subnet-0f82350780ed8c71b"
  vpc_security_group_ids = ["sg-03cffe5ebe505e62f"]
  tags = {
    Name = "training-takutaka"
  }
}
