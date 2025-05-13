# Deploying a Highly Available Infrastructure in AWS Using Terraform

## Project Overview
This project provisions a **highly available infrastructure** on AWS using Terraform. It simulates a production-grade environment with:

- A custom VPC with public & private subnets
- Internet Gateway and NAT Gateway
- Two EC2 instances inside private subnets
- Application Load Balancer (ALB) distributing traffic
- MySQL RDS database (Multi-AZ)
- Proper route tables and security groups
- Clean outputs for access

---

## 🔧 Tools Used
- **Terraform** (IaC)
- **AWS EC2, VPC, RDS, ALB, Subnets, Security Groups**

---

## 🌐 AWS Resources Created
### 1. **Networking**
- VPC (CIDR: 10.0.0.0/16)
- 2 Public Subnets (us-east-1a, us-east-1b)
- 2 Private Subnets (us-east-1a, us-east-1b)
- Internet Gateway
- NAT Gateway with Elastic IP
- Route Tables with correct associations

### 2. **Compute**
- 2 EC2 instances (web & app) in private subnets
- Installed Apache via `user_data`
- SSH access via imported key pair

### 3. **Load Balancer**
- Application Load Balancer
- Listener (HTTP port 80)
- Target Group + 2 Attachments

### 4. **Database**
- RDS MySQL instance (db.t3.micro)
- Multi-AZ using subnet group
- Secured via private subnets & security groups

### 5. **Security**
- WebSG for EC2 (ports 22, 80, 443)
- ALBSG (inbound 80, outbound to WebSG)
- db_sg (inbound from WebSG only)

### 6. **Outputs**
- ALB DNS name
- Private IPs for EC2
- RDS Endpoint (sensitive)

---

## Testing
- Visit ALB DNS name in browser → Should route to EC2s
- SSH to EC2 (if needed) via private IP (through bastion if you have one)
- Connect to RDS using MySQL client via internal EC2

---

## 🔚 Conclusion
This project is a foundational setup for production-grade AWS infrastructure. You can build on top of it to implement advanced DevOps pipelines, CI/CD, monitoring, GitOps, etc.

---

Built with ❤️ by @jalowaini



