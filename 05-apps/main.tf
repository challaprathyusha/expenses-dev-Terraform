#creating frontend using terraform aws ec2 opensource module
module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "${var.project_name}-${var.environment}-frontend"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  #convert stringlist to list(string) and get the first element
  subnet_id              = local.subnet_id_frontend

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-frontend"
    }
  )
}

#creating backend using terraform aws ec2 opensource module
module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "${var.project_name}-${var.environment}-backend"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #convert stringlist to list(string) and get the first element
  subnet_id              = local.subnet_id_backend

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-backend"
    }
  )
}

#creating ansible using terraform aws ec2 opensource module
module "ansible" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "${var.project_name}-${var.environment}-ansible"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.ansible_sg_id.value]
#convert stringlist to list(string) and get the first element
  subnet_id              = local.subnet_id_frontend
#we are launching ansible server with userdata so that it will automatically configures frontend and backend servers
#userdata runs only when terraform creates ansible server in aws
  user_data = file("expenses.sh")

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-ansible"
    }
  )
#explicit dependency 
#terraform creates frontend and backend first and then ansible
  depends_on = [ module.backend,module.frontend ]
}

#creating route53 records for frontend and backend using opensource module
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "" #expensesnote.site
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.public_ip
      ]
    },
    {
      name    = "frontend"
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.private_ip
      ]
    },
    {
      name    = "backend"
      type    = "A"
      ttl     = 1
      records = [
        module.backend.private_ip
      ]
    }
  ]

}