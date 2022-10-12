# Jumbo Application
The Architecture is as below:
![Data Flow](https://github.com/rskaradag/jumbo/blob/master/data-flow.PNG?raw=true)

The application uses asynchronous communication to generate data on EFS as persistent storage. API Gateway sends messages to SQS which triggers Lambda functions to generate files and delete message from the queue (Serverless). Container run on ECS Fargate Tasks back of ALB serves these generated files. All logs and communication stores on CloudWatch to monitor. Service and Roles authorize minimum responsibility by policies. Data flow test scenario runs after each deployment.

## Components
### AWS

The AWS infrastructure is setup using terraform in the [`./terraform`](./Terraform).

The following components are deployed:
