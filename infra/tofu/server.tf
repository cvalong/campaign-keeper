# A resource CREATES and owns something: made on apply, deleted on destroy.
# Pattern: resource "<type>" "<name>" — the name is our label, AWS never sees it.

# The PUBLIC half of your SSH key, uploaded to AWS.
# EC2 copies it onto the instance so your private key can log in.
resource "aws_key_pair" "laptop" {
  key_name = "campaign-keeper-laptop" # the name AWS shows in the console

  # file() reads a file into a string; pathexpand() turns ~ into your home folder.
  public_key = file(pathexpand("~/.ssh/campaign-keeper.pub"))
}

# A variable is an input. Its value comes from terraform.tfvars (gitignored).
variable "my_ip" {
  description = "Your public IP as a CIDR block, e.g. 1.2.3.4/32"
  type        = string
}

# A firewall around the instance. Everything incoming is blocked unless a rule allows it.
resource "aws_security_group" "server" {
  name        = "campaign-keeper-server"
  description = "SSH from my IP only"

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22 # a port range; 22 to 22 means just SSH
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "All outbound (package downloads, Docker images)"
    protocol    = "-1" # -1 means every protocol
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Look up the newest official Ubuntu 24.04 image for ARM (Graviton) chips.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical, Ubuntu's publisher — so no look-alike images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }
}

# The server. With no subnet given, it lands in the default VPC.
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.micro"
  key_name = aws_key_pair.laptop.key_name
  vpc_security_group_ids = [aws_security_group.server.id]

  tags = { Name = "campaign-keeper" } # the name shown in the EC2 console
}

# Print the address to SSH into after apply.
output "server_ip" {
  value = aws_instance.server.public_ip
}
