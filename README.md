# Terraform AWS High Availability Infrastructure

This project provisions a production-grade, highly available infrastructure in AWS using Terraform.

It simulates a real-world environment with:

- Custom VPC with public & private subnets across 2 Availability Zones
- Internet Gateway + NAT Gateway
- Application Load Balancer (ALB)
- Auto Scaling Group-ready EC2 Web Servers
- RDS MySQL Database (Multi-AZ)

---

## Project Structure

```bash
.
├── main.tf              # Root Terraform config
├── variables.tf         # Input variables
├── outputs.tf           # Exported outputs
├── provider.tf          # AWS provider config
├── backend.tf           # Remote backend (optional)
├── .gitignore           # Ignore .terraform/, tfstate, etc.
└── README.md

🛠️ Tools Used
Terraform – Infrastructure as Code

AWS – EC2, VPC, Subnets, RDS, ALB, Security Groups

GitHub – Version Control & Collaboration

AWS Resources Created
1. Networking
VPC: 10.0.0.0/16

2 Public Subnets: us-east-1a, us-east-1b

2 Private Subnets: us-east-1a, us-east-1b

Internet Gateway

NAT Gateway with Elastic IP

Route Tables with correct associations

2. Compute
2 EC2 instances (web/app) in private subnets

Apache installed via user_data

SSH access via key pair (through bastion if needed)

3. Load Balancer
Application Load Balancer (ALB)

Listener on port 80

Target Group with both EC2s attached

4. Database
RDS MySQL instance (db.t3.micro)

Multi-AZ enabled via subnet group

Private subnet access only

Security group restricts access from EC2 only

5. Security
web_sg: Allows ports 22, 80, 443

alb_sg: Allows port 80 from internet, targets web_sg

db_sg: Allows only internal MySQL traffic from EC2s

6. Outputs
ALB DNS name

EC2 Private IPs

RDS Endpoint (sensitive)

Usage
⚠️ Prerequisites: Terraform installed + AWS credentials configured.

bash
نسخ
تحرير
# Initialize Terraform
terraform init

# Preview the infrastructure plan
terraform plan

# Apply the changes
terraform apply
Testing the Setup
 Visit the ALB DNS in your browser → You should see the default Apache page.

Use SSH (via bastion or port-forward) to connect to EC2 instances.

Connect to RDS from EC2 using:

bash
نسخ
تحرير
mysql -h <rds-endpoint> -u <username> -p
💡 Recommendations
Store state remotely using S3 + DynamoDB for collaboration and locking.

Use Terraform modules for cleaner, reusable infrastructure.

Add CI/CD integration for automated deployments.

Built with ❤️ by @jalowaini
