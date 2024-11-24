# 3-Tier Architecture on AWS EKS with Docker, Kubernetes, and Terraform

This repository demonstrates the deployment of a **3-tier architecture application** utilizing Docker, Kubernetes, AWS EKS (Elastic Kubernetes Service), and Infrastructure-as-Code (IaC) with Terraform. The application uses a dummy voting system with multiple services deployed across containers to showcase an understanding of these technologies.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Folder Structure](#folder-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Deployment Workflow](#deployment-workflow)
- [Accessing the Application](#accessing-the-application)
- [Terraform Infrastructure](#terraform-infrastructure)
- [CI/CD Workflow](#cicd-workflow)

## Overview

This project demonstrates the deployment of a **3-tier architecture application** where:

- **UI Pods**: The frontend allows users to vote.
- **Backend Pods**: The worker and result services consume votes and store results.
- **Database Pods**: A PostgreSQL database to store vote results.
- **Messaging Service**: Redis is used for message queueing between services.
  
This architecture is deployed on **AWS EKS** with Docker containers and Kubernetes, using **Terraform** for Infrastructure-as-Code (IaC). The deployment is fully automated through **GitHub Actions**, which builds Docker images, pushes them to **AWS ECR**, and deploys the application to EKS.

## Architecture

The application is designed with a simple distributed system approach:

- **Frontend (vote app)** - Python-based UI allowing users to vote.
- **Redis** - A message broker that collects and manages votes in real-time.
- **Worker Service** - .NET worker that consumes votes and stores results in the database.
- **PostgreSQL** - Database that stores the voting data.
- **Result Service** - Node.js service that shows the results of the voting process in real-time.

This architecture is containerized using **Docker**, orchestrated with **Kubernetes** on **AWS EKS**.

## Technologies Used

- **Frontend**: Python (Flask for UI)
- **Backend**: .NET (Worker service)
- **Database**: PostgreSQL
- **Messaging**: Redis
- **Containerization**: Docker
- **Orchestration**: Kubernetes (on AWS EKS)
- **Infrastructure-as-Code**: Terraform
- **CI/CD**: GitHub Actions
- **Cloud**: AWS EKS, Amazon ECR, AWS IAM

## Folder Structure

```shell
.
├── .github/
│   └── workflows/
│       ├── call-deployment.yaml        # GitHub Actions workflow for deploying to EKS
│       ├── call-docker-build-result.yaml  # Docker build & push for Result Service
│       ├── call-docker-build-vote.yaml    # Docker build & push for Vote Service
│       └── call-docker-build-worker.yaml  # Docker build & push for Worker Service
│
├── AWSEKS/                           # Terraform configurations for EKS setup
│   ├── ekscluster.tf
│   ├── eksnode.tf
│   ├── main.tf
│   ├── variable.tf
│
├── k8s-specifications/               # Kubernetes YAML files for each service
│   ├── db.yaml                        # DB deployment YAML
│   ├── redis.yaml                     # Redis service YAML
│   ├── result.yaml                    # Result service deployment YAML
│   ├── vote.yaml                      # Vote service deployment YAML
│   └── worker.yaml                    # Worker service deployment YAML
│
├── result/                           # Dockerfile and code for Result Service
├── vote/                             # Dockerfile and code for Vote Service
└── worker/                           # Dockerfile and code for Worker Service

```

## Prerequisites

Before you begin, ensure the following tools are installed:

- **Docker**: For containerizing services.
- **kubectl**: Kubernetes CLI to interact with your EKS cluster.
- **Terraform**: For provisioning infrastructure on AWS.
- **AWS CLI**: To manage AWS services from the command line.
- **GitHub Account**: For access to GitHub Actions workflows.

Ensure you have the necessary AWS credentials configured via GitHub Secrets.

## Setup Instructions

# 1. Clone the Repository

Clone this repository to your local machine:

```shell

git clone https://github.com/your-username/3-tier-architecture.git
cd 3-tier-architecture

```

# 2. Configure AWS Credentials

In GitHub, store the following AWS credentials in the repository’s Secrets:

- **AWS_ACCESS_KEY_ID**
- **AWS_SECRET_ACCESS_KEY**
- **AWS_REGION**
- **AWS_ACCOUNT_ID**
- **AWS_ECR_REPOSITORY_RESULT**
- **AWS_ECR_REPOSITORY_VOTE**
- **AWS_ECR_REPOSITORY_WORKER**

These will be used in the CI/CD workflow for ECR authentication.

# 3. Terraform Configuration

Before deploying to EKS, configure your Terraform scripts by setting up your AWS region and credentials.

Run the following commands to set up your EKS cluster:

```shell

terraform init
terraform apply

```

This will provision your EKS cluster.

# 4. Build and Push Docker Images

Whenever you make changes to the Dockerfiles, the GitHub Actions workflows will automatically trigger a build of Docker images and push them to AWS ECR.

**Example Workflow Trigger**:

- If you push changes to the vote directory or the related workflow YAML, it will trigger the call-docker-build-vote.yaml to build and push the vote Docker image.

## Deployment Workflow

The application deployment is fully automated using GitHub Actions:

# 1. Terraform Setup (EKS Cluster)

The terraform_setup job will create the EKS cluster using Terraform. It runs automatically when changes are pushed to the repository.

# 2. Docker Image Build & Push

For each service (vote, result, worker), the corresponding call-docker-build workflow will build Docker images and push them to AWS ECR.

# 3. Deploy to EKS

After the images are pushed, the deploy_to_eks job will deploy the Docker containers to the EKS cluster using Kubernetes manifests. This includes deploying:

- **Redis**
- **Database (PostgreSQL)**
- **Result Service**
- **Vote Service**
- **Worker Service**

The deployment will use the node ports for access after the services are up.

## Accessing the Application

Once the deployment is complete and the pods are running, you can access the services through the NodePort.

- **Vote Web App**: Available on port 31000.
- **Results Web App**: Available on port 31001.

Use the external IP of your EKS cluster to access the applications:

```shell

kubectl get svc

```

You will see the NodePort service and external IP for the applications.

## Terraform Infrastructure

Terraform is used to provision the following infrastructure:

- **EKS Cluster**: Creates an EKS cluster in AWS.
- **IAM Roles**: Configures IAM roles and policies for accessing AWS services.
- **Node Group**: Creates a node group to host your EKS workloads.

The Terraform configuration files are located in the AWSEKS/ directory.

## CI/CD Workflow

The GitHub Actions workflows are set up for continuous integration and deployment:

- **Build Docker images**: Automatically triggered on commits to main for vote, result, and worker services.
- **Deploy to EKS**: Triggered on every push to main to deploy the latest images to the AWS EKS cluster.
- **Terraform Management**: Automatically handles the provisioning and destruction of AWS resources.
