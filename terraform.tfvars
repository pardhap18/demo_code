#---------terra-tfvars----

aws_profile = "quickee"
aws_region = "us-west-2"
vpc_cidr = "10.115.0.0/16"
cidrs = {
   public1 = "10.115.1.0/24"
   public2 = "10.115.2.0/24"
   private1 = "10.115.3.0/24"
   private2 = "10.115.4.0/24"
   private3 = "10.115.5.0/24"
}

domain_name = "labserver"

jenk_instance_type = "t2.micro"

jenk_ami = "ami-18726478"

public_key_path = "/root/.ssh/joyful.pub"

key_name = "pardha"
