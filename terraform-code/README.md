# Proposed App Deployment Plan
## Architecture
 

![Architecture](https://github.com/SatishNaidi/website/blob/master/terraform-code/Architecture.jpg)

1. Develop Terraform templates to create following resources
    - Create VPC, 2 Subnets
	- Create 2 Route tables pertaining to 1 Public Subnet and 1 Private Subnet
	- Create 2 Security Groups pertaining to each Subnet
	-  Create 1 NAT Gateway and 1 IGW
	-  Attach NAT Gateway to Private Subnet, IGW to Public Subnet

	The base Network layer with be created to deploy Infrastructure

2. Create Terraform templates to Create Following Managed resouces in AWS
	- Create PostgresSQL RDS in Private Subnet [Use Private Subnet]
	-  Create S3 Bucket to have object storage to be used Minio
	-  Create SES End point for sending emails
	-  IAM User with secrete key and Access key to be used with Minio

3. Create Deployment resources to run our CMS Application
	 - Create ECS Cluster
        [Optionally we can use code commit to manage the source code]
     - Create Code Pipeline to Manage the deployment flow
     -  Create Code Build in Code Pipeline with Trigger as Code Commit or Git Commit
     - Create Code Deploy to be linked with ECS, with arguments as PostgresSQL endpoint, s3 bucket, IAM Account and SES Endpoint
     -  Create Appspec.yml to custom deploy application such as dynamically place the postgres end point, S3 Bucket Name and other details.
     -  Modify the docker-compose.yml file for production use such as we no longer needed DB Container, Minio Run command to use "gateway" serivce instaed "server"
     -  Modify the env/webapp.env and env/minio.env files to reflect the newly created resouce endpoints and secrets


# Vendor Lock Problem:

Since we will be using many of the cloud managed services such as ECS, S3, SES, Code Deploy, Code Build and other and these are native to AWS, portability of the solution will be challenging since cloud native solution uses different provisionig methods. Using terraform as provisioning tools helps us a bit, not to extent of complete migration from one vender to other Vendor. To minimise the efforts while migrating from one cloud vender to other we should be using more of opensource tools which can run on VMs
Example: 
 - Instead using ECS, Use Kubernetes or Openshift. These can be run on any VM even AWS EC2 ir Azure VMs.
 - Instead of Code Pipeline, Code Build use Jenkins
 - Instead of Code Deploy use Ansible or chef or any other configuration management tool.

## Improvement Recomendations:

1. The docker compose is only recommended for development puposes, for Productions purposes Dockerswarm is recommended, but the cluster is to managed either Auto Scaling Groups
2. For Secrete management use Keystore management service or secretes services from docker to avoid exposing the passwords in Plain text


## Challenges:

   1. Since docker-compose [v 3.4] file is not directly supported by ECS, had to fall back on Docker on EC2 with docker compose as quick method for this task.
   2. Tested few components individually such as Minio, and is working as expected when running as s3 gateway service with env variables as minio_accesskey, minio_secretekey, But when running    
        in django app with specified environment variables got errors as **"Error: Prefix access is denied: /"**, even after adding right bucket policies and making sure IAM user has right access.
    
Since It was my first attempting in writing terraform templates, Container services and Django app, I was partially successfully creating complete solution. 

As part of the Infrastructure creation, we will be creating few managed services only once since the changes were not needed everytime we do deployment such as Postgres, S3 and SES endpoints
We will be pertaining all managed end points and will be given to the codedeploy.

## Steps to Test the solution:

### In Local Terminal

 1. Create an IAM user with all previleges to Network, EC2, S3, IAM users in console.
 2. Install awscli in terminal, "pip install awscli"
 3. Issue "aws configure" command and key in access key and secrete key,  verify the configuration by issueing "aws sts get-caller-identity"
 4. Install terraform
 5. Download the repository from "https://github.com/SatishNaidi/website.git"
 6. Navigate to folder website/terraform-code
 7. Issue command "terraform init", this will download all required executables based on files in folder
 8. Issue command "terraform plan", to verify what all changes are going to be done by terraform
 9. Issue command "terraform apply", terraform will create resoures in following order
    - create VPCs, Subnet, Security Groups
    - Creates PostgresSQL, S3 Bucket 
    - Create EC2 instance and install Docker and git, downloads the copy of source code to run applicaiton
    - Try accessing the application with pubic endpoint with port number 8000

# Caveats with this solution:
 - Scalability is the first challenge
 - Backup and restore posibility
 - Docker on EC2 is not the best way to manage the containers
