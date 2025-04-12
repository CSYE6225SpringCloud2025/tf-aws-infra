# tf-aws-infra

# AWS Infrastructure Deployment with Terraform

This project automates the deployment of AWS infrastructure including VPC, subnets, security components, and application resources using Terraform.

## Project Structure

```
├── main.tf             # Main infrastructure configuration
├── variables.tf        # Input variables declaration
├── terraform.tfvars    # Variable values
├── provider.tf         # AWS provider configuration
├── outputs.tf          # Output values
├── packer/             # AMI building configurations
└── README.md           # Project documentation
```

## Requirements

- Terraform v1.0+
- AWS CLI configured with appropriate credentials
- AWS account with required permissions
- Packer (for building custom AMIs)

## Usage

### 1. Initialize Terraform

```sh
terraform init
```

### 2. Plan Infrastructure Changes

```sh
terraform plan -var-file="terraform.tfvars"
```

### 3. Apply Configuration

```sh
terraform apply -var-file="terraform.tfvars"
```

### 4. Build Custom AMI

```sh
cd packer
packer build -var-file=variables.pkrvars.hcl ami.pkr.hcl
```

### 5. Import SSL Certificate

```sh
aws acm import-certificate \
  --certificate fileb://path/to/certificate.pem \
  --private-key fileb://path/to/privatekey.pem \
  --certificate-chain fileb://path/to/chain.pem \
  --region us-east-1
```

You can also import the certificate using Terraform:

```hcl
resource "aws_acm_certificate" "cert" {
  private_key       = file("${path.module}/ssl/private-key.pem")
  certificate_body  = file("${path.module}/ssl/certificate.pem")
  certificate_chain = file("${path.module}/ssl/certificate-chain.pem")
  
  tags = {
    Name = "${var.project_name}-certificate"
  }
}
```

### 6. Destroy Resources

```sh
terraform destroy -var-file="terraform.tfvars"
```