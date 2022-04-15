
#Create key-pair
resource "aws_key_pair" "keypair1" {
  key_name   = "${var.stack}-keypairs"
  public_key = file(var.ssh_key)
}

#Create DB
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.dbname
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  skip_final_snapshot    = true
}

# Crate EC2
resource "aws_instance" "ec2" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  count         = length(var.availability_zones)
  depends_on    = [
       aws_db_instance.mysql,
  ]

  key_name                    = aws_key_pair.keypair1.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  subnet_id     = aws_subnet.my_subnet[count.index].id

  user_data = file("files/userdata.sh")

  tags = {
    Name = "${var.stack}_EC2 Instance"
  }

  provisioner "file" {
    source      = "files/userdata.sh"
    destination = "/home/ubuntu/userdata.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/userdata.sh",
      "/home/ubuntu/userdata.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }
}
  # Creating EFS file system
resource "aws_efs_file_system" "efs" {
creation_token = "my-efs"
tags = {
Name = "Adil_Hasanov_EFS"
  }
}

# Creating Mount target of EFSresource "aws_efs_mount_target" "mount"
resource "aws_efs_mount_target" "mount" {
count      = length(var.availability_zones)
file_system_id = aws_efs_file_system.efs.id
subnet_id      = aws_subnet.my_subnet[count.index].id
security_groups = [aws_security_group.web.id]
}

# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
count      = length(var.availability_zones)
depends_on = [aws_efs_mount_target.mount]
connection {
type     = "ssh"
user     = "ubuntu"
private_key = file(var.ssh_priv_key)
# host     = aws_instance.ec2.*.public_ip
host     = aws_instance.ec2[count.index].public_ip
 }

 provisioner "remote-exec" {
inline = [
"sudo service nfs-server start && sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/  /usr/share/nginx/html/"]
 # "sudo su -c \"echo '${module.efs_mount.file_system_dns_name}:/ /mnt/efs nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\""
 }
}
#Load Balancer
resource "aws_elb" "elb" {
  name               = "elb"
  subnets = ["${aws_subnet.my_subnet.*.id[0]}", "${aws_subnet.my_subnet.*.id[1]}"]
  security_groups = ["${aws_security_group.web.id}"]

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

}

module "attachment" {
  source = "./attach"
  attachment_count = length(var.availability_zones)
  instance_ids = ["${aws_instance.ec2.*.id[0]}", "${aws_instance.ec2.*.id[1]}"]
  elb_id = "${aws_elb.elb.id}"
}





