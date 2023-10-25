# NETWORK STRUCTURES &amp; CLOUD COMPUTING (CSYE 6225)

## PYTHON BASED WEBAPP INTEGRATED WITH POSTGRESQL DATABASE

### PREREQUISITES FOR BUILDING AND DEPLOYING LOCALLY:
- Python 3.11
- Flask
- Postgresql
- pip
- packer

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
        
      - python3 pre-installed
      - Pre-installed postgresql with a superuser
      - webapp dependencies pre-installed
      - database file in /opt
      - webapp python file pre-installed in /opt/webapp
- This AMI is private and once created, gets shared with a demo account
- You can use this AMI to create an instance with specifications mentioned above and then follow below commands to run the webapp on your instance:
    
      
      - cd /opt/webapp
      - flask --app=webapp run --host=0.0.0.0
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
