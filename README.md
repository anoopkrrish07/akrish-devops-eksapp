# Python Flask Application Deployment on EKS:

This README guide provides instructions on how to deploy a Python Flask application on Amazon Elastic Kubernetes Service (EKS). This application includes an endpoint (/success) that checks the connectivity to a PostgreSQL database and returns a response based on the connection status.

## Overview
The CI/CD pipeline is built using GitHub Actions and includes steps for code scanning, infrastructure deployment via Infrastructure as Code (IaC), container image building, and deployment to EKS. Local testing is facilitated through Docker Compose.

### Pipeline Components
**Code Scanning:** Utilizes Checkov for Infrastructure as Code (IaC) scanning and Trivy for Docker image scanning, ensuring code quality and security.
**Workflow Dispatch Pipeline:** Manages IaC deployment, specifically for VPC and EKS cluster setup, allowing manual trigger of infrastructure provisioning.
**App Deployment Pipeline:** Automates the building of the Docker container image and deployment to the EKS cluster using kubectl commands.
**Local Testing:** Incorporates Docker Compose to spin up the application and PostgreSQL database containers, facilitating local development and testing.

## Architecture Diagram:
!["Architecture"](assets/architecture.png?raw=true)

## Repo Tree:
```
.
├── README.md
├── flask_app/
│   ├── Dockerfile
│   ├── app/
│   │   ├── app.py
│   │   └── requirements.txt
│   └── docker-compose.yml
├── kube_manifest/
│   ├── app/
│   │   ├── flask-deployment.yaml
│   │   └── flask-service.yaml
│   ├── infra
│   └── karpenter.yaml
└── terraform_iac/
    ├── env_iac/
    │   └── region/
    │       ├── dev/
    │       │   ├── aws-eks.tfvars
    │       │   └── aws-vpc.tfvars
    │       └── prod
    └── modules/
        ├── eks
        └── vpc
```

## Tools used:
- Terraform (1.7.4)
- EKS (1.28)
- Karpenter Chart (0.33)
- Python (3.12.2)

## Prerequisite:
- An AWS account
- Clone repository and make changes
- Add Terraform backend configuration
- AWS - GitHub OIDC access
- Add variables as GitHub secrets

## How to deploy:

### Pre-deploy steps:
1. Create AWS GitHub OIDC access for the terraform infrastructure and application deployment. Refer this link for it: [LINK](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
2. Create a S3 bucket and dynamoDB table and update the backend file (`backend.tf`) for the terraform state management.
3. Update the **.env** file if needed for the local testing
4. Add these variables in the GitHub repo
```yaml
DEV_AWS_ROLE_ARN = OIDC assume role arn
AWS_ECR_REPO  = Your ECR repo name
```

## Infrastructure Deployment
The Workflow Dispatch pipeline allows manual triggering of the IaC deployment process, setting up the necessary AWS resources including VPC and EKS cluster.

### VPC deployment:
- The GitHub Actions pipeline will be triggered using manual triggers. 
`Go to Actions > select workflow (TF AWS Infrastructure Deployment) > run workflow > add region (eg: us-east-2) > select environment > select terraform action (eg: plan or apply) > select AWS service you want to deploy > trigger using run workflow`

> Note: The pipeline does not include a resource destruction step; this must be handled manually if needed.

### EKS deployment:
- The GitHub Actions pipeline will be triggered using manual triggers. 

> Note: Please update the `aws-eks.tfvars` file with your VPC ID and the ARN for EKS read-only access before triggering the workflow. Admin access can be configured in the Terraform file or applied manually. The pipeline does not include a resource destruction step; this must be handled manually if needed.

## Application Deployment
The App Deployment pipeline automates the building of the Docker image and updates the Kubernetes deployment on EKS using the updated image, ensuring the application is deployed with the latest codebase.

### Prerequisites:
- Replace these pipeline variables according to your preference
```yaml 
AWS_REGION = your AWS region
EKS_CLUSTER_NAME = Name of the EKS cluster that you have deployed using Terraform
NAMESPACE = Namespace of your application
```

### Application job trigger
- Update the container image spec in the kubernetes deployment manifest (`flask-deployment.yaml`) with your ECR image identifier..
- App deployment will be triggered when a pull request will be merged to the main branch.

## Local testing:

For local testing I have included a docker compose file that will replicate the application container and postgresqlDB in your local machine.

### Prerequisite:

- Docker installed (latest)
- Install Docker compose CLI (3.8)

### How to run docker compose:

- Switch directory
```bash
cd flask_app
```

- Run the application
```bash
docker-compose up -d
```

- To test the application connectivity
```bash
curl localhost:5000/success
```

## Conclusion
This CI/CD pipeline setup for a Python Flask application demonstrates a comprehensive approach to application development, security scanning, and deployment. It ensures that the application is developed, tested, and deployed in a secure and efficient manner. Note: This setup is optimized for development and testing purposes. Additional considerations should be taken for a production-ready deployment, including more rigorous security practices and scalability considerations.