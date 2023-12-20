# Cloud-Native Flask API on AWS using IaC

This repository contains code for building a Cloud-native web application, creating an Amazon Machine Image, setting up Amazon CloudWatch logging and metrics, enabling Systemd autorun of the web app on an Amazon EC2 instance, and implementing GitHub Actions workflows for integration testing and CI/CD in production.

## Use with Related Repositories

1. [iac-pulumi](https://github.com/CSYE-6225-Shivani/iac-pulumi): Contains IaC using Pulumi code.
2. [serverless](https://github.com/CSYE-6225-Shivani/serverless): Contains code for Lambda function.

## Tech Stack

| **Category**                 | **Technology/Tool**                                     |
|------------------------------|---------------------------------------------------------|
| **Programming Language**     | Python (Flask)                                           |
| **Database**                 | PostgreSQL                                              |
| **Cloud Services**           | AWS (EC2, RDS, VPC, IAM, Route53, CloudWatch, SNS, Lambda, ELB, ASG) |
| **Infrastructure as Code**   | Pulumi                                                  |
| **Image Creation**           | Packer (Custom AMIs)                                     |
| **Version Control**          | Git                                                     |
| **CI/CD**                    | GitHub Actions                                          |
| **Additional Tools**         | Mailgun, Google Cloud Platform (GCP)                     |

## Read through [webapp](docs/webapp.md) documentation for detailed information on setting up webapp respository


## How does the repositories work together
1. Clone iac-pulumi repository (assuming that it is set up as guided in its documentation)
2. Clone serverless respository and follow instructions in its README.md