# Jumbo Application
The Architecture is as below:
![Data Flow](https://github.com/rskaradag/jumbo/blob/master/data-flow.PNG?raw=true)

The application uses asynchronous communication to generate data on EFS as persistent storage. API Gateway sends messages to SQS which triggers Lambda functions to generate files and delete message from the queue (Serverless). Container run on ECS Fargate Tasks back of ALB serves these generated files. All logs and communication stores on CloudWatch to monitor. Service and Roles authorize minimum responsibility by policies. Data flow test scenario runs after each deployment.

## Components
### AWS

The AWS infrastructure is setup using terraform in the [`./terraform`](./Terraform).

The following components are deployed:
 -  Elastic File Storage [`./efs.tf`](./Terraform/efs.tf).
 -  Apigateway [`./apigateway.tf`](./Terraform/apigateway.tf).
 -  Lambda Function [`./lambda.tf`](./Terraform/lambda.tf) & [`./consumer.py`](./Terraform/Lambda/consumer.py).
 -  Simple Queue Service [`./sqs.tf`](./Terraform/sqs.tf).
 -  ECS Cluster / ECS Service / Task Definitions [`./ecs.tf`](./Terraform/ecs.tf).
 -  Elastic Container Registry [`./ecr.tf`](./Terraform/ecr.tf).
 -  Application Load Balancer [`./lb.tf`](./Terraform/lb.tf).
 -  VPC Configuration [`./vpc.tf`](./Terraform/vpc.tf).
 -  IAM Roles [`./iam.tf`](./Terraform/iam.tf).


### CI/CD

The repository leverages the [AWS Github Actions](https://github.com/aws-actions/) maintained by AWS.

The main goal is to provide an example configuration of the following workflow:

- Run the integration tests
- Build the Docker image
- Publish it to a private ECR
- Update the corresponding ECS Service (by editing the task image)
- Execute Data Flow test

[cd-success](https://github.com/rskaradag/jumbo/actions/runs/3231143245)
