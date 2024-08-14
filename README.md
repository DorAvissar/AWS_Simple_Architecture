# Terraform way to run AWS EC2 instances in a Private Subnet and Load Balancing with an Application Load Balancer

### This example walks you through the steps to use terraform to spin up AWS EC2 instances in a private subnet and expose the application running on the EC2 instances using an Application Load Balancer. 

### Additionally, we will be setting up an Internet Gateway and a NAT Gateway to route inbound and outbound traffic to the internet from the private network. 

### For testing, we will be installing docker on the EC2 instance and running NGINX on port 80.

## Objective:
- Automate the cloud infrastructure using Terraform.
     - Setup VPC with two public subnets and two private subnets in two different availability zones for high-availability

    - Setup an Internet Gateway for internet traffic.

    - Attach a NAT Gateway to the private subnets, so the private subnets can connect to the internet.

    - Setup an EC2 instance

    - Setup security groups and route tables to enable traffic between subnets, NAT, and Internet Gateways.

    - Setup an Application Load Balancer for the EC2 

    - Setup an autoscaling group and launch templates to the EC2 Instances (optinal , in this demo i didnt do it)

## Architecture


## Pricing
!! Warning !!

This example uses services that are not included in the free tier, for example, NAT Gateway. You may end up paying a couple of dollars if you run the services for a day, but keep in mind to shutdown if it is unnecessary.

To avoid getting a huge bill at the end of the month, it's always a good practice you tear down the infrastructure completely after the experimenting, if you don’t intend to run the services for a longer time. 

## Prerequisites:
- AWS Account 
- Install AWS CLI
- Install Terraform
- Setup AWS credentials

## Terraform as IaC and Configuration
Terraform is an open-source, infrastructure-as-code, software tool created by HashiCorp. 

Users define and provide data center and Cloud infrastructure using a declarative configuration language known as HashiCorp Configuration Language (HCL).

## Files: 
After completing all the steps, you should be having the following files created under the terraform project folder.
  - provider.tf
  - variables.tf
  - network.tf
  - keypair.tf
  - securitygroups.tf
  - ec2.tf
  - outputs.tf
  - loadbalancer.tf
### optinal: (instead of the ec2.tf, not include in this project)
  - launchconfigurations.tf
  - autoscaling.tf

### Provider.tf:
Create a project folder of your choice. All of the code (files) will go under the newly created project folder.

Create a file under the new folder with the name ‘provider.tf’ and add the following code in the file.

```
provider "aws" {
  region = var.region
}
```
This code adds AWS as a provider. 

Open a terminal and navigate to the terraform project directory. Run the following command first:  
```
terraform configure
```
and then run the following command to initializ: 
```
terraform init
```

This step may take a few seconds to minutes to download the Terraform/AWS library.

### Variables.tf
Create the set of variables to externalize the configuration which will be referenced in the following steps.

### Network.tf:
This step builds the Virtual Private Cloud (VPC) with 2 public subnets which can be accessed via the internet using the Internet Gateway.

2 private subnets which are not exposed to the internet and are private to the VPC.

Create a NAT Gateway in the public subnet and attach it to the private subnets using the route tables, so the private subnets can access the internet.

### Security Groups.tf:
Create two security groups.

Security Group for EC2 instances — Allows all inbound traffic on port 22 for SSH, allows all traffic only from the Application Load Balancer, and allows all outbound traffic.

Security Group for the Application Load Balancer (ALB) — Allows all inbound traffic on port 80 and allows all outbound traffic.

Note: In an ideal scenario the ALB should also be receiving traffic from HTTPs (port 443), which requires issuing the certificate and validation before we can attach it to the Load Balancer. For simplicity, Im using only port 80.


### Load Balancer
This step adds a Load Balancer, listeners, for the Load Balancer, adds Target Groups to route the traffic, and attaches to the autoscaling group which we will be creating in the next couple of steps.

### EC2
this Terraform step provisions an EC2 instance in a private subnet, installs Docker, and runs an NGINX web server within a Docker container. The instance is secured by a specified security group, does not have a public IP address, and automatically starts NGINX on launch. The purpose is to deploy a web server in a controlled, private environment, accessible only through specified internal routes, such as a load balancer.

### Outputs:
The below code prints the Application Load Balancer DNS name. Copy the printed value, we will be using this to test the NGINX server running on the EC2 instance.

## Optional

### Launch Configuration
This step spins up an EC2 instance in the public subnet and assigns a public IP address. This instance can be used to SSH to the instances on the private subnets. Optionally the aws_instance named ‘Bastion’ can be removed.

The Launch Configuration also defines an EC2 launch template which is used in the autoscaling group created in the next step.

The user data field in the launch template will install docker, set the permissions, and download and run an NGINX server in the EC2 instance.

The optional step — creates IAM policy, and instance role and applied to the EC2 instance profile.

### Autoscaling

Autoscaling definitions, help define the scalability based on the workload CPU and memory utilization. Defines how many instances to run initially and the maximum number of instances that can be created across the attached subnets. The min, max, and desired values can be adjusted in the variables.tf file.

## How to run it?
Run terraform plan before applying, to review the changes that will be applied in AWS.
```
terraform plan
```

Run terraform apply to apply the changes in AWS. Type ‘yes’ if prompted to confirm.
```
terraform apply
```

or to skip confirmation
```
terraform apply -auto-approve
```

Navigate to the AWS console and verify all the resources are created.

Open a new window in the browser and copy and paste the output generated in after running terraform apply. Copy the Application Load Balancer URL and paste it into the browser.

### You should see ‘Welcome to NGINX’ Home page.  

## Troubleshooting:
If you don’t see the page, please verify the EC2 instances are up and the health checks are passed.

Verify the VPC, subnets configurations, route tables, and security groups.

Verify if the Internet Gateway and the NAT Gateway are enabled.

## Teardown the Infrastructure:
Always teardown the infrastructure if not needed to avoid bills for unnecessary workloads.

To tear down the infrastructure run the following command and type ‘yes’ if prompted for confirmation.
```
terraform destroy
``` 
or
```
terraform destroy -auto-approve
```

## Conclusion:
You have successfully completed setting up a VPC and running EC2 instances on your private network and have the Application Load Balancer to route the traffic to the instance.

