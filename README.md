# NETWORK STRUCTURES &amp; CLOUD COMPUTING (CSYE 6225)

## PYTHON BASED WEBAPP INTEGRATED WITH POSTGRESQL DATABASE

### PREREQUISITES FOR BUILDING AND DEPLOYING LOCALLY:
- Python 3.11
- Flask
- Postgresql
- pip
- packer
- .env file with necessary credentials to database

### RUN WEBAPP IN YOUR LOCAL:
- Run install.sh to install and configure all dependencies:
    
      .\install.sh

- Install virtual environment by running below command:
    
    
      python3 -m venv myvenv

- Activate the virtual environment:


      For windows:
       myvenv\Scripts\activate

      For mac:
       . myvenv\bin\activate

- Install everything from requirements.txt:
      
      pip install -r requirements.txt

- Run the python file:
      
      python webapp.py

### USING CREATED AMI:
- The workflow creates an AMI with following specifications in AWS dev account:
        
      - python3 and webapp dependencies pre-installed
      - webapp python file pre-installed in /opt/webapp
      - webapp.service in location /etc/systemd/system which has configuration to boot start application with the instance
      - cloudwatch agent pre-installed
      - cloudwatch logging and metric pre-configured (generates logs and metrics related to the app on Amazon CloudWatch)

- This AMI is private and once created, gets shared with a demo account
- You can use this AMI to create an instance with specifications mentioned above

- Now get the public address of your machine and hit below endpoints on postman or other API testing software to use the app.


   - To check app health:
   
         
         http://<public_address>:<port_where_its_running>/healthz

    - To get data:
    
    
          
          http://<public_address>:<port_where_its_running>/v1/assignments

    - To post data:



          http://<public_address>:<port_where_its_running>/v1/assignments
    
    - To put data in existing record:



          http://<public_address>:<port_where_its_running>/v1/assignments/<assignment_id>

    - To existing record:


          http://<public_address>:<port_where_its_running>/v1/assignments/<assignment_id>



## FOR INFORMATION ONLY


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
          

          - This workflow is an example of Continuous Delivery
          - This workflow runs integration test to double check the integration
          - Fetches AWS credentials from github secrets
          - Sets up packer on the github runner
          - Run packer build on aws-debian.pkr.hcl 
          - This workflow gets triggered whenever a pull request is merged and deploys AMI to the AWS account in the region/s mentioned in hcl file
