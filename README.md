# 🚀 AWS DevOps Infrastructure — Terraform

Terraform project to provision a complete **CI/CD infrastructure** on AWS, including a custom VPC and three dedicated servers: **Jenkins**, **Nexus**, and **SonarQube** — all running on dynamically fetched Ubuntu 22.04 LTS AMIs.

---

## 📐 Architecture Overview

```
                        ┌─────────────────────────────────────────┐
                        │               AWS VPC                   │
                        │          192.168.0.0/16                 │
                        │                                         │
                        │  ┌──────────────┐  ┌────────────────┐  │
                        │  │ Public Sub 1 │  │ Public Sub 2   │  │
                        │  │192.168.1.0/24│  │192.168.2.0/24  │  │
                        │  │              │  │                │  │
                        │  │ ┌──────────┐ │  └────────────────┘  │
                        │  │ │ Jenkins  │ │                       │
                        │  │ │ :8080    │ │  ┌────────────────┐  │
                        │  │ ├──────────┤ │  │  DB Sub 1      │  │
                        │  │ │  Nexus   │ │  │192.168.5.0/24  │  │
                        │  │ │ :8081    │ │  ├────────────────┤  │
                        │  │ ├──────────┤ │  │  DB Sub 2      │  │
                        │  │ │ SonarQube│ │  │192.168.6.0/24  │  │
                        │  │ │ :9000    │ │  └────────────────┘  │
                        │  └──────────────┘                       │
                        └──────────────┬──────────────────────────┘
                                       │
                              Internet Gateway
                                       │
                                   Internet
```

---

## 📁 Project Structure

```
.
├── provider.tf          # AWS provider configuration
├── data.tf              # Dynamic AMI lookup + Availability Zones
├── variable.tf          # All input variables with defaults
├── main.tf              # VPC, Subnets, Route Tables, Security Groups
├── iam.tf               # IAM Role, Policy Attachment, Instance Profile
├── jenkins-server.tf    # Jenkins EC2 instance
├── nexus-server.tf      # Nexus EC2 instance
├── sonar-server.tf      # SonarQube EC2 instance
├── jenkins-server.sh    # Jenkins bootstrap script (user_data)
├── nexus-server.sh      # Nexus bootstrap script (user_data)
├── sonar-server.sh      # SonarQube bootstrap script (user_data)
└── README.md
```

---

## ☁️ Resources Provisioned

| Resource | Details |
|---|---|
| **VPC** | `192.168.0.0/16` with DNS support & hostnames enabled |
| **Public Subnets** | 2 subnets across 2 AZs (`192.168.1.0/24`, `192.168.2.0/24`) |
| **Database Subnets** | 2 private subnets across 2 AZs (`192.168.5.0/24`, `192.168.6.0/24`) |
| **Internet Gateway** | Attached to VPC for public internet access |
| **Route Tables** | Public RT (with IGW route) + Database RT |
| **Security Groups** | Dedicated SGs for Jenkins, Nexus, and SonarQube |
| **IAM Role** | `Terraform-Admin` with `AdministratorAccess` for Jenkins |
| **EC2 — Jenkins** | `t3.micro`, 20GB EBS, port 8080 |
| **EC2 — Nexus** | `t3.micro`, 20GB EBS, port 8081 |
| **EC2 — SonarQube** | `t3.micro`, 20GB EBS, port 9000 |

---

## 🖥️ Server Details

### Jenkins Server
- **Installed via:** `apt` package manager
- **Java:** OpenJDK 21
- **Port:** `8080`
- **IAM Profile:** Attached (`Terraform-Admin`)
- **Extras:** Jenkins user granted passwordless sudo

### Nexus Repository Manager
- **Installed via:** Docker (`sonatype/nexus3`)
- **Port:** `8081`
- **Swap:** 2GB swap file created for memory headroom
- **JVM flags:** `-Xms256m -Xmx512m`

### SonarQube
- **Installed via:** Docker (`sonarqube:lts-community`)
- **Port:** `9000`
- **Swap:** 4GB swap file
- **Kernel tuning:** `vm.max_map_count=262144`, `fs.file-max=65536`
- **JVM flags:** `-Xms256m -Xmx512m`

---

## 🔒 Security Groups — Open Ports

| Server | Port 22 (SSH) | App Port | Port 80 (HTTP) |
|---|---|---|---|
| Jenkins | ✅ | 8080 | ✅ |
| Nexus | ✅ | 8081 | ✅ |
| SonarQube | ✅ | 9000 | ✅ |

> ⚠️ All ingress rules currently allow `0.0.0.0/0`. Restrict to your IP in production.

---

## 🔄 Dynamic AMI — No Hardcoding

The AMI is fetched automatically at plan time using a data source. No manual AMI ID updates are ever needed — Terraform always picks the latest available Ubuntu 22.04 LTS image.

```hcl
data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]  # Canonical's official AWS account
}
```

All three EC2 instances reference this via `data.aws_ami.latest.id`.

---

## ⚙️ Variables Reference

| Variable | Default | Description |
|---|---|---|
| `region` | `us-east-1` | AWS region |
| `cidr` | `192.168.0.0/16` | VPC CIDR block |
| `vpc_name` | `tcw_vpc` | VPC name tag |
| `instance_type` | `t3.micro` | EC2 instance type for all servers |
| `key_name` | `NewKey1` | EC2 Key Pair name for SSH access |
| `environment` | `dev` | Environment tag applied to resources |
| `public_subnet_cidr_1` | `192.168.1.0/24` | First public subnet CIDR |
| `public_subnet_cidr_2` | `192.168.2.0/24` | Second public subnet CIDR |
| `database_subnet_cidr_1` | `192.168.5.0/24` | First database subnet CIDR |
| `database_subnet_cidr_2` | `192.168.6.0/24` | Second database subnet CIDR |

---

## 🛠️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.0`
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with credentials
- An existing EC2 **Key Pair** in your target region (default: `NewKey1`)
- IAM permissions to create VPC, EC2, IAM, and Security Group resources

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 2. Configure AWS credentials

```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output format (json)
```

### 3. Update variables (optional)

Edit `variable.tf` to change defaults, or create a `terraform.tfvars` file:

```hcl
# terraform.tfvars
region        = "us-east-1"
key_name      = "your-key-pair-name"
instance_type = "t3.medium"
environment   = "dev"
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Preview the plan

```bash
terraform plan
```

### 6. Apply the infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Provisioning takes approximately **3–5 minutes**.

---

## 🌐 Accessing the Services

After `terraform apply` completes, grab the public IPs from the AWS Console or CLI:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=jenkins-server,nexus-server,sonar-server" \
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0],PublicIpAddress]" \
  --output table
```

| Service | URL |
|---|---|
| Jenkins | `http://<jenkins-public-ip>:8080` |
| Nexus | `http://<nexus-public-ip>:8081` |
| SonarQube | `http://<sonar-public-ip>:9000` |

> ⏳ **Note:** Nexus and SonarQube run in Docker and may take **2–5 minutes** after the instance is ready before the UI becomes available.

### Default Credentials

| Service | Username | Password |
|---|---|---|
| Jenkins | `admin` | Found at `/var/lib/jenkins/secrets/initialAdminPassword` on the instance |
| Nexus | `admin` | Found at `/nexus-data/admin.password` inside the container: `docker exec nexus-server cat /nexus-data/admin.password` |
| SonarQube | `admin` | `admin` (change on first login) |

---

## 🧹 Destroying the Infrastructure

To tear down all resources and avoid AWS charges:

```bash
terraform destroy
```

---

## 📌 Notes

- The `jenkins-server` has an IAM Instance Profile (`Terraform-Admin`) attached for AWS API access from within Jenkins pipelines.
- All bootstrap scripts run automatically via EC2 `user_data` on first boot.
- The database subnets are provisioned but currently unused — reserved for future RDS or other private resources.
- To use a different Ubuntu version, update the `name` filter pattern in `data.tf`.
