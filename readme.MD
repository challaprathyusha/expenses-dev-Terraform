![alt text](expenses-dev-terraform.jpg)

## expenses project using terraform

In every project provisioning the infrastructure is the first step we do.In this project we will  deploy 3-tier architecture in AWS using terraform and ansible.For high availability,fault tolerance and disaster recovery, we deploy the application in multiple availability zones in us-east-1 region. By using terraform provisioning the infrastructure, using ansible configuring the frontend and backend servers. To provision vpc,we are using our own VPC module. To provision security groups, we are using our own SG module. To provision frontend and backend server, we are using open source module. To provision db server, we are using Amazon RDS service.Amazon RDS creates db servers in the  To configure frontend and backend servers we are integrating terraform with ansible. To configure Db server, we are using opensource RDS module.


# VPC - virtual private cloud

By using vpc module we are creating below resources in aws

* VPC in us-east region
* IGW to give public access to our vpc
* IGW attachment to VPC
* 2 public subnets in two azs for HA 
* 2 private subnets in two azs for HA 
* 2 database subnets in two azs for HA 
* Database subnet group for all the DB subnets created
* Elastic ip address to provide static IP for NAT gateway
* NAT gateway to give access to the instances running in private and db subnets. 
    * Public NAT gateway should be associated with an Elastic IP. As AWS frequently changes the     public IP addresses of the resources created in public subnet, we should associate an elastic IP to the NAT gateway
* public route table for 2 public subnets 
* private route table for 2 private subnets
* database route table for 2 db subnets
* adding routes to all the route tables in vpc
* public route table and public subnets associations
* private route table and private subnets associations
* database route table and db subnets associations
* peering if required
* adding routes in route tables of all the subnets in vpc for peering connection between requestor and acceptor vpc

# Security Groups

By using SG module we are creating SG for each instance. In our project we have a requirement to create SG for each instance that gets created

* SG for db instance that gets launched in DB subnet
* SG for backend instance that gets launched in private subnet
* SG for frontend instance that gets launched in public subnet
* SG for bastion host that gets launched in public subnet
* SG for ansible that gets launched in public subnet
* SG inbound rules for db security group
    * inbound rules for db accepting connections from backend
    * inbound rules for db accepting connections from bastion
* SG inbound rules for backend security group
    * inbound rules for backend accepting connections from frontend
    * inbound rules for backend accepting connections from ansible
    * inbound rules for backend accepting connections from bastion host
* SG inbound rules for frontend security group
    * inbound rules for frontend accepting connections from public
    * inbound rules for frontend accepting connections from ansible
    * inbound rules for frontend accepting connections from bastion
* SG inbound rules for ansible security group
    * inbound rules for ansible accepting connections from public
* SG inbound rules for bastion security group
    * inbound rules for bastion accepting connections from public

# Instances

By using open source module we create 
- bastion host in public subnet
- frontend server public subnet
- backend server private subnet
- Ansible server public subnet

By using Amazon RDS we create
- db server in db subnet

* Backend and db servers are not accessible to anyone outside of vpc, so we use bastion host to connect to backend and db server.
* User will access bastion using ssh and from bastion he can access backend on port 22,db on 3306
* Bastion host is launched in public subnet so that backend,db running in private subets can be   accessed through it to.
* Frontend and backend servers should be launched before the ansible.
* Ansible server is launched in public subnet to configure frontend and backend servers.
* db server is configured by Amazon RDS automatically.
* If ansible connects to frontend using its public IP, the request from ansible goes outside vpc and comes to frontend from somewhere but not from ansible.Hence in ansible inventory file we should provide private IP of frontend.

# route53 records

After launching the servers we create route 53 records using open source module
- route53 record for db server using its endpoint 
- route53 record for backend using its private IP
- rouete53 record for frontend using its public IP

===========================================================================================
* When we connect to frontend by using its public IP through bastion host that's running with in vpc, the request from bastion goes outside vpc and comes back to frontend from somewhare in the internet, then frontend could not read where the connection is from and it throws connection timeout error.So the servers running in same network should connect using only private IP's not with public IP's.


* By implementing this architecture, we successfully deploy 3-tier application into aws using terraform.
* Now the application will be accessible to public through frontend.
* This is the basic application architecture that we designed and implemented.
* This implementation don't address the HA and downtime of application.
* Load balancers and autoscaling provide HA and scalability for the application.
* But if there are multiple servers accepting connections from users, we should address that using load balancers and auto scaling.
* If there are any deployments, we must use load balancers and auto scaling concepts which will address the downtime of the application.


