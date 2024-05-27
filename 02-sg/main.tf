#SG for db instance that gets launched in DB subnet
module "db" {
    source = "git::https://github.com/challaprathyusha/terraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "db"
    sg_desc = "SG for DB instance"
    vpc_id = data.aws_ssm_parameter.vpc_id.value

}
#SG for backend instance that gets launched in private subnet
module "backend" {
    source = "git::https://github.com/challaprathyusha/terraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "backend"
    sg_desc = "SG for backend instance"
    vpc_id = data.aws_ssm_parameter.vpc_id.value

}
#SG for frontend instance that gets launched in public subnet
module "frontend" {
    source = "git::https://github.com/challaprathyusha/terraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "frontend"
    sg_desc = "SG for frontend instance"
    vpc_id = data.aws_ssm_parameter.vpc_id.value

}
#SG for bastion host that gets launched in public subnet
module "bastion" {
    source = "git::https://github.com/challaprathyusha/terraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "bastion"
    sg_desc = "SG for bastion host"
    vpc_id = data.aws_ssm_parameter.vpc_id.value

}
#SG for ansible that gets launched in public subnet
module "ansible" {
    source = "git::https://github.com/challaprathyusha/terraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "ansible"
    sg_desc = "SG for ansible instance"
    vpc_id = data.aws_ssm_parameter.vpc_id.value

}

#SG rules for DB security group
#inbound rules for db accepting connections from backend
resource "aws_security_group_rule" "db-backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id  = module.backend.sg_id
  security_group_id = module.db.sg_id
}
#inbound rules for db accepting connections from bastion
resource "aws_security_group_rule" "db-bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id  = module.bastion.sg_id
  security_group_id = module.db.sg_id
}


#SG rule for backend security group
#inbound rules for backend accepting connections from frontend
resource "aws_security_group_rule" "backend-frontend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id  = module.frontend.sg_id
  security_group_id = module.backend.sg_id
}
#inbound rules for backend accepting connections from ansible
resource "aws_security_group_rule" "backend-ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.ansible.sg_id
  security_group_id = module.backend.sg_id
}
#inbound rules for backend accepting connections from bastion host
resource "aws_security_group_rule" "backend-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}


#SG rule for frontend security group
#inbound rules for frontend accepting connections from public
resource "aws_security_group_rule" "frontend-user" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = module.frontend.sg_id
}
#inbound rules for frontend accepting connections from ansible
resource "aws_security_group_rule" "frontend-ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.ansible.sg_id
  security_group_id = module.frontend.sg_id
}
#inbound rules for frontend accepting connections from bastion
resource "aws_security_group_rule" "frontend-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

#SG rule for ansible security group
#inbound rules for ansible accepting connections from public
resource "aws_security_group_rule" "ansible-public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = module.ansible.sg_id
}

#SG rule for bastion security group
#inbound rules for bastion accepting connections from public
resource "aws_security_group_rule" "bastion-public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = module.bastion.sg_id
}