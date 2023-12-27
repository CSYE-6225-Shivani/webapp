## PYTHON BASED WEBAPP INTEGRATED WITH POSTGRESQL DATABASE

## Git Forking Workflow
> [!WARNING]
> If organization repository and forked repositories are not set, the github workflow won't work.

Please make sure to create an Organization on your GitHub and create repository in that Organization. Then fork the repo in your personal account.
Follow below steps to set it up in your backend:

     1. git clone <clone_link_to_your_forked_repo>
     2. cd <repo_name>
     3. git remote -v -> This will show you the link of your repo as origin
     4. git remote add upstream <clone_link_to_your_organization_repo>

Now each time you are making changes in your repository, you can create a merge request to your organization repo from a different branch:

    1. git checkout -b "BRANCH_NAME"
    2. Make all the changes needed
    3. git add .
    4. git commit -m "COMMIT_MESSAGE"
    5. git push origin <BRANCH_NAME>


## GitHub Setup for WEBAPP repository
Add below to your GitHub Environment variables and secrets:
- Environment Variables:
  1. AMI_USERS_PACKER
  2. AWS_REGION_PACKER
  3. DELAY_SECONDS_PACKER
  4. DEVICE_NAME_PACKER
  5. GROUP_PACKER
  6. INSTANCE_TYPE_PACKER
  7. MAX_ATTEMPTS_PACKER
  8. POSTGRES_DB
  9. REGION
  10. SOURCE_AMI_PACKER
  11. SSH_USERNAME_PACKER
  12. SUBNET_ID_PACKER
  13. USER_PACKER
  14. VOLUME_SIZE_PACKER
  15. VOLUME_TYPE_PACKER

- Environment Secrets:
  1. AWS_ACCESS_KEY_ID
  2. AWS_ACCESS_KEY_ID_DEPLOY
  3. AWS_SECRET_ACCESS_KEY
  4. AWS_SECRET_ACCESS_KEY_DEPLOY
  5. DATABASE_URL
  6. POSTGRES_PASSWORD
  7. POSTGRES_USER
  8. RDS_DATABASE
  9. RDS_HOSTNAME
  10. RDS_PASSWORD
  11. RDS_USERNAME

## Add branch protection rules 
 - Add branch protection rules on your organization WEBAPP repository and check `Require status checks to pass before merging` and `Require branches to be up to date before merging` options and select two workflows from the dropdown:

       1. pull-request-integration-test
       2. pull-request-ami-test

## Important information about IAM
> [!IMPORTANT]
> If IAM is not set up correctly then none of the things in the project will work. 

For the sake of this project, an organization was created in the root account with 2 member accounts - dev and demo. This was done to have separate environments like in industry for development and production.

We need 2 pairs of AWS ACCESS KEY ID and AWS SECRET ACCESS KEY:
1. First pair is to create AMI in dev account:
   - Add a user in dev account and attach it with below policy:
    > {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeyPair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "*"
        }
    ]
}

     - Create AWS ACCESS KEY and SECRET KEY for this user and add as environment secrets as `AWS_ACCESS_KEY_ID` and
     `AWS_SECRET_ACCESS_KEY`


2. Second pair is to update the current ASG Launch template to use the latest AMI:
    - Create a user with following AWS managed policies attached to it:
      ``` 
       1. AmazonEC2FullAccess
       2. AutoScalingFullAccess
       3. IAMFullAccess
    - Create AWS ACCESS KEY and SECRET KEY for this user and add as environment secrets as AWS_ACCESS_KEY_ID_DEPLOY and AWS_SECRET_ACCESS_KEY_DEPLOY

- The application supports below endpoints:


   - To check app health:
         
         https://<ENVIRONMENT>.<YOUR_DNS>/healthz

    - To get data:
    
    
          
          https://<ENVIRONMENT>.<YOUR_DNS>/v1/assignments

    - To post data:



          https://<ENVIRONMENT>.<YOUR_DNS>/v1/assignments
    
    - To put data in existing record:



          https://<ENVIRONMENT>.<YOUR_DNS>/v1/assignments/<assignment_id>

    - To delete existing record:


          https://<ENVIRONMENT>.<YOUR_DNS>/v1/assignments/<assignment_id>
    - To post submission of an existing assignment:

          https://<ENVIRONMENT>.<YOUR_DNS>/v1/assignments/<id>/submission


## FOR INFORMATION ONLY

### AMI:
- The workflow creates an AMI with following specifications in AWS dev account:
        
      - python3 and webapp dependencies pre-installed
      - webapp python file pre-installed in /opt/webapp
      - webapp.service in location /etc/systemd/system which has configuration to boot start application with the instance
      - cloudwatch agent pre-installed
      - cloudwatch logging and metric pre-configured (generates logs and metrics related to the app on Amazon CloudWatch)

- This AMI is private and once created in dev, it gets shared with the demo/prod account
- You can use this AMI to create EC2 instances with specifications mentioned above
- If this repository is used in conjunction with the other two repositories, then you do not have to manually use the AMI on each EC2 instance

### UNDERSTANDING EXISTENCE OF EACH FILE
        
* webapp/webapp.py:

      - This file has the python logic for:
      
          1. Developing the web application
          2. Creating a database and its schema
          3. Connecting webapp to the database to further read data from the database or manipulate the data in the database
          4. Read the data from a csv file and add it to the database
          4. It also has authentication method to ensure that person sending requests is authenticated

      - The app has following endpoints available:

          1. GET - /healthz: Checks the connection between web application and database

          2. GET - /v1/assignments: Get existing assignment/s

          3. POST - /v1/assignments: Add new assignment

          4. GET - /v1/assignments/<id>: Get a particular assignment based on its id

          5. PUT - /v1/assignments/<id>: Allows to modify an existing assignment based on its id only if the person modifying it is also its owner

          6. DELETE - /v1/assignments/<id>: Allows to delete an existing assignment based on its id only if the person attempting to delete it is also its owner

          7. POST - /v1/assignments/<id>/submission: Allows to submit a zip file in json format to an existing assignment


* webapp/install.sh:



         - This file has all the dependencies and setup packages required for us to be able to run the application


* webapp/requirements.txt:



       - This file has all the dependencies used to run the app. It is used in the github actions to perform integration testing


* webapp/users.csv:


       - It is the csv file from which the application reads data to populate the database


* webapp/webapp.service:
   


      - This file has configuration to auto start the application on an EC2 instance

* webapp/aws-debian.pkr.hcl:
          
          - This file has everything required to build the AMI:
             1. Instance specification for image
             2. Regions where the AMI should be copied
             3. Accounts with which the AMI should be shared
             4. File provisioners and shell provisioners to:
                 - Copy files from the repository during github action workflows
                 - Run install.sh
                 - Add new user and groups
                 - Use linux commands to manipulate files and directories while AMI creation

* webapp/amazon-cloudwatch-agent.json:
      

         - This file has configuration related to cloudwatch logging and metrics like:
             1. Which file to add logs to
             2. What to name the log group
             3. What to name the stream
             4. Specifications related to metric generation like ports, whether to use statsd or collectd, etc

* webapp/IntegrationTest.py:
    

        - This file has logic to test the healthz endpoint of the web application. It is specifically created to perform integration testing in github workflow actions

* .github/workflows/pull_request_check.yml:


        - This workflow is an example of Continuous Integration
        - This workflow runs the webapp/IntegrationTest.py to check the integration between the webapp and the databse
        - For performing this test, it first sets up the github runner with prerequisites needed to run the webapp and then runs IntegrationTest.py and passes only if the script pass
        - This workflow gets triggered whenever a new pull request is raised or any new commit is added to an existing pull request
        - This workflow is added in branch protection rules and hence if this workflow fails, then the pull request will have no option for it to be merged to the main code

* .github/workflows/packer_pull_request.yml:


        This workflow checks the format of the file used to create the AMI: aws-debian.pkr.hcl
        - It first sets up github runner with packer and repository code
        - It uses packer init, packer fmt, and packer validate commands to ensure that the format of the hcl file is valid
        - This workflow gets triggered whenever a new pull request is raised or any new commit is added to an existing pull request
        - This workflow is added in branch protection rules and hence if this workflow fails, then the pull request will have no option for it to be merged to the main code

* .github/workflow/packer_push.yml:
          

          - This workflow is an example of Continuous Integration, Continuous Delivery, and Continuous Deployment
          - This workflow runs integration test to double check the integration
          - Fetches AWS credentials from github secrets
          - Sets up packer on the github runner
          - Run packer build on aws-debian.pkr.hcl
          - This workflow gets triggered whenever a pull request is merged and deploys AMI to the AWS account in the region/s mentioned in hcl file
          - After the new AMI has been shared with the demo account, the 2nd job runs to deploy this AMI to the launch template of the current ASG demonstrating Continuous Deployment
