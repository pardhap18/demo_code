#--------guide--------

1) As a step, I created the required AWS infrastructure (VPC, Internetgateway, NACL, route table, subnets, s3 for storage, ec2 instance) with the help of terraform code.

2) Along with terraform code for infrastructure set up, I used ansible for configuration of jenkins server in ec2 instance.

3) In the same way as above, created tomcat webserver using terraform and ansible in another ec2 instance.  
