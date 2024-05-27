locals {
   subnet_id_frontend = element(split(",",data.aws_ssm_parameter.public_subnet_ids.value),0)
   subnet_id_backend = element(split(",",data.aws_ssm_parameter.private_subnet_ids.value),0)
}