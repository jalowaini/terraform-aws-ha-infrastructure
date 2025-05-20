# Terraform AWS High Availability Infrastructure

This project provisions a production-grade, highly available infrastructure on AWS using Terraform.

It reflects a real-world DevOps setup with modular infrastructure-as-code, secure network design, and scalable components.

---

## Project Structure

```
.
├── main.tf              # Root Terraform config
├── variables.tf         # Input variables
├── outputs.tf           # Exported outputs
├── provider.tf          # AWS provider config
├── backend.tf           # Remote backend (optional)
├── .gitignore           # Ignore .terraform/, tfstate, etc.
└── README.md
```

---

## Tools Used

- **Terraform** – Infrastructure as Code  
- **AWS** – EC2, VPC, Subnets, RDS, ALB, Security Groups  
- **GitHub** – Version Control & Collaboration  

---

## AWS Resources Created

### 1. Networking
- VPC: `10.0.0.0/16`  
- 2 Public Subnets: `us-east-1a`, `us-east-1b`  
- 2 Private Subnets: `us-east-1a`, `us-east-1b`  
- Internet Gateway  
- NAT Gateway with Elastic IP  
- Route Tables with proper associations  

### 2. Compute
- 2 EC2 Instances (Web/App) in private subnets  
- Apache installed via `user_data`  
- SSH access via key pair (via Bastion if needed)  

### 3. Load Balancer
- Application Load Balancer (ALB)  
- Listener on Port 80  
- Target Group with both EC2 instances attached  

### 4. Database
- RDS MySQL instance (`db.t3.micro`)  
- Multi-AZ enabled via Subnet Group  
- Access restricted to private subnets only  
- Security Group allows access from EC2 only  

### 5. Security
- `web_sg`: Allows ports 22, 80, 443  
- `alb_sg`: Allows port 80 from the internet, targets `web_sg`  
- `db_sg`: Allows only internal MySQL traffic from EC2s  

### 6. Outputs
- ALB DNS name  
- EC2 Private IPs  
- RDS Endpoint (marked as sensitive)  

---

## Usage

> Prerequisites: Terraform installed + AWS credentials configured

```bash
# Initialize Terraform
terraform init

# Preview the plan
terraform plan

# Apply the infrastructure
terraform apply
```

---

## Testing the Setup

- Visit the ALB DNS in your browser → You should see the default Apache page.  
- Use SSH (via Bastion or port forwarding) to connect to EC2 instances.  
- Connect to RDS from EC2 using:

```bash
mysql -h <rds-endpoint> -u <username> -p
```

---

## 🔗 Author

Developed and maintained by [@jalowaini](https://github.com/jalowaini)
