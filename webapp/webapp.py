from flask import Flask, Response, request, jsonify, make_response
from numpy import genfromtxt
from sqlalchemy import create_engine, Column, String, Integer, TIMESTAMP, func, ForeignKey, CheckConstraint
from sqlalchemy_utils import database_exists, create_database
from sqlalchemy.dialects.postgresql import UUID, VARCHAR
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from sqlalchemy.engine.reflection import Inspector
import psycopg2
import uuid
from flask_bcrypt import Bcrypt
from flask_httpauth import HTTPBasicAuth


app = Flask(__name__)
bcrypt = Bcrypt(app)
auth = HTTPBasicAuth()


# Function to apply bcrypt encryption
def encrypt(password):
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    return encrypted_password

# Create Database if it does not already exist
engine = create_engine("postgresql://admin:1234@localhost:5432/webapp")
if database_exists(engine.url):
    print("Database already exist:", engine.url)
if not database_exists(engine.url):
    create_database(engine.url)
    print("Created Database: ", engine.url)


# Function to establish a connection to the database
def check_db_connection():
    try:
        if engine:
          print("Connected to the database!")

        #db_connection.close()
        return True

    except EXCEPTION as e:
        print(f"Database connection error: {e}")
        return False

# Function to add data from csv file to Account table
if check_db_connection():
        # Load data from csv
        def LoadData(file_name):
            data = genfromtxt(file_name, delimiter=',', skip_header=1, dtype=str)
            return data.tolist()

        def add_user_data():
            Session = sessionmaker(bind=engine)
            session = Session()
            try:
                file_name = "/opt/users.csv"
                data = LoadData(file_name)

                for i in data:
                    if not session.query(Account).filter_by(email = i[2]).first():
                        i[3] = encrypt(i[3])
                        record = Account(**{
                            'first_name': i[0],
                            'last_name': i[1],
                            'email': i[2],
                            'password': i[3]
                            })
                        session.add(record)
                        session.commit()
                        print("Data inserted successfully")
                    else:
                        continue
            except Exception as e:
                session.rollback()
                print("Error:", str(e))
            finally:
                session.close()

        # Create session
        Session = sessionmaker(bind=engine)
        session = Session()

        Base = declarative_base()

        #Defining table schema
        class Account(Base):
            __tablename__ = 'Account'

            id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True)
            first_name = Column(VARCHAR(80).with_variant(String(80), "postgresql"), nullable=False)
            last_name = Column(VARCHAR(80).with_variant(String(80), "postgresql"), nullable=False)
            email = Column(VARCHAR(100).with_variant(String(100), "postgresql"), nullable=False, unique=True)
            password = Column(String, nullable=False)
            account_created = Column(TIMESTAMP(), server_default=func.now())
            account_updated = Column(TIMESTAMP(), server_default=func.now())

        class Assignment(Base):
            __tablename__ = 'Assignment'

            id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, unique=True)
            name = Column(String, nullable=False, unique=True)
            points = Column(Integer, nullable=False) # must be between 1 to 100
            num_of_attempts = Column(Integer, nullable=False)# Max attempts should be 3 or 100?
            deadline = Column(TIMESTAMP(), nullable=False)
            assignment_created = Column(TIMESTAMP(), server_default=func.now())
            assignment_updated = Column(TIMESTAMP(), server_default=func.now(), onupdate=func.now())
            created_by  = Column(UUID(as_uuid=True), ForeignKey('Account.id')) # foreign key to build a relationship between Account & Assignment tables

            account = relationship('Account', backref='assignments')

            # Column level check constraints to limit value ranges for points and num_of_attempts
            __table_args__ = (CheckConstraint('points >= 1 AND points <= 100', name='check_points_range'),
                              CheckConstraint('num_of_attempts >= 1 AND num_of_attempts <=3', name='check_num_of_attempts'),
            )


        # Create all schemas
        Base.metadata.create_all(engine)

        # Add data to Account schema
        add_user_data()

@app.after_request
def set_response_headers(response):
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['Content-Type'] = 'application/json'
    return response

@app.route('/healthz', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'])
def health_check_api():
    if check_db_connection() and request.method == 'GET':
        if (request.args) or (request.data) or (request.form) or (request.files):
            response = Response(status=400)
            return response
        else:
            response = Response(status=200)
            return response
    elif not request.method == 'GET':
        response = Response(status=405)
        return response
    else:
        response = Response(status=503)
        return response


@app.route('/v1/assignments', methods=['GET'])
@auth.login_required
def get_assignments():
    if not check_db_connection():
            response = Response(status=503)
            return response
    if (request.args) or (request.data) or (request.form) or (request.files):
        response = Response(status=400)
        return response

    else:
        assignments = session.query(Assignment).all()
        output = []

        for assignment in assignments:
            assignment_data = {}
            assignment_data['id'] = assignment.id
            assignment_data['name'] = assignment.name
            assignment_data['points'] = assignment.points
            assignment_data['num_of_attempts'] = assignment.num_of_attempts
            assignment_data['deadline'] = assignment.deadline
            assignment_data['assignment_created'] = assignment.assignment_created
            assignment_data['assignment_updated'] = assignment.assignment_updated
            assignment_data['created_by'] = assignment.created_by
            output.append(assignment_data)
        response = Response(status=200)
        return jsonify({'assignments' : output})

@app.route('/v1/assignments', methods=['POST'])
@auth.login_required
def create_assignments():
    if not check_db_connection():
            response = Response(status=503)
            return response
    # Check if body is json or not
    if request.is_json:
        data = request.get_json()
        account_email = auth.current_user()
        print("account email-------------------", account_email)
        account_details = session.query(Account).filter_by(email=account_email).first()
        # Check whether points and num_of_attempts have values under their specified range
        points = int(data.get('points'))
        if not (1<= points <=100):
            response = jsonify({'error' : 'Points must be between 1 and 100 inclusively.'})
            response.status_code = 400
            return response
        num_of_attempts = int(data.get('num_of_attempts'))
        if not (1<= num_of_attempts <=3):
            response = jsonify({'error' : 'num_of_attempts must be between 1 and 3 inclusively.'})
            response.status_code = 400
            return response

        # Check if the assignment with the same name already exists
        existing_assignment = session.query(Assignment).filter_by(name = data['name']).first()

        # Return "409 Conflict" if the assignment with the same name exists
        if existing_assignment:
            response = Response(status=409)
            return response

        # Create new assignment
        else:
            new_assignment = Assignment(name=data['name'], points=data['points'], num_of_attempts=data['num_of_attempts'], deadline=data['deadline'], created_by=account_details.id)
            session.add(new_assignment)
            session.commit()
            response_data = {
                'id': str(new_assignment.id),
                'name': new_assignment.name,
                'points': new_assignment.points,
                'num_of_attempts': new_assignment.num_of_attempts,
                'deadline': new_assignment.deadline.strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
                'assignment_created': new_assignment.assignment_created.strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
                'assignment_updated': new_assignment.assignment_updated.strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
                'created_by' : account_details.id
            }

            response = jsonify(response_data)
            response.status_code = 201
            return response
    # Return "400 Bad Request" if the body is not json
    else:
        response = Response(status=400)
        return response

@app.route('/v1/assignments/<id>', methods=['GET'])
@auth.login_required
def get_one_assignment(id):
    try:
        if not check_db_connection():
            response = Response(status=503)
            return response
        # try catch block to ensure that id is of type uuid
        try:
            uuid.UUID(id)
        except ValueError:
            response = jsonify({'message' : 'Invalid UUID format for id'})
            response.status_code = 400
            return response
        # Ensure that there are no args in the request body
        if (request.args) or (request.data) or (request.form) or (request.files):
            response = Response(status=400)
            return response
        assignment = session.query(Assignment).filter_by(id=id).first()

        # If assignment id is not present in the table, return "404 Bad request"
        if not assignment:
            response = jsonify({'message' : 'No Assignment found!'})
            response.status_code = 404
            return response

        # If assignment id exist in the table, get all the data for that id
        else:
            assignment_data = {}
            assignment_data['id'] = assignment.id
            assignment_data['name'] = assignment.name
            assignment_data['points'] = assignment.points
            assignment_data['num_of_attempts'] = assignment.num_of_attempts
            assignment_data['deadline'] = assignment.deadline
            assignment_data['assignment_created'] = assignment.assignment_created
            assignment_data['assignment_updated'] = assignment.assignment_updated

            response = jsonify({'assignment' : assignment_data})
            response.status_code = 200
            return response
    except Exception as e:
        # Log the exception to help with debugging
        print(f"An error occurred: {str(e)}")
        response = Response(status=500)
        return response

@app.route('/v1/assignments/<id>', methods=['PUT'])
@auth.login_required
def modify_assignment(id):
    try:
        if not check_db_connection():
            response = Response(status=503)
            return response
        # try catch block to ensure that id is of type uuid
        try:
            uuid.UUID(id)
        except ValueError:
            response = jsonify({'message' : 'Invalid UUID format for id'})
            response.status_code = 400
            return response
        assignment = session.query(Assignment).filter_by(id=id).first()

        # If assignment id is not present in the table, return "404 Bad request"
        if not assignment:
            response = jsonify({'message' : 'No Assignment found!'})
            response.status_code = 404
            return response

        owner = assignment.created_by
        get_user = auth.current_user()
        user_details = session.query(Account).filter_by(email=get_user).first()
        user = user_details.id
        if owner == user:
            # Check if body is json or not
            if request.is_json:
                data = request.get_json()

                # Check if the JSON payload is empty or contains unexpected keys
                expected_fields = {'name', 'points', 'num_of_attempts', 'deadline', 'assignment_created', 'assignment_updated'}
                if not data or not isinstance(data, dict) or not set(data.keys()).issubset(expected_fields):
                    response = jsonify({'error': 'Invalid or missing JSON payload'})
                    response.status_code = 400
                    return response
                # Check whether points and num_of_attempts have values under their specified range
                points = int(data.get('points'))
                if not (1<= points <=100):
                    response = jsonify({'error' : 'Points must be between 1 and 100 inclusively.'})
                    response.status_code = 400
                    return response
                num_of_attempts = int(data.get('num_of_attempts'))
                if not (1<= num_of_attempts <=3):
                    response = jsonify({'error' : 'num_of_attempts must be between 1 and 3 inclusively.'})
                    response.status_code = 400
                    return response
                
                # Overwriting data to existing entry
                assignment.name = data['name']
                assignment.points = data['points']
                assignment.num_of_attempts = data['num_of_attempts']
                assignment.deadline = data['deadline']


                session.commit()

                response_data = {
                'name': assignment.name,
                'points': assignment.points,
                'num_of_attempts': assignment.num_of_attempts,
                'deadline': assignment.deadline
                }

                response = jsonify(response_data)
                response.status_code = 201
                return response
            # If any argument other than json is passed, then return "400 Bad request"
            elif (request.args) or (request.data) or (request.form) or (request.files):
                response = Response(status=400)
                return response
            # If there is not content at all, return "204 No Content"
            else:
                response = jsonify({'message' : 'No content found!'})
                response.status_code = 204
                return response
            
        # If user is not the owner of the assignment, return "403 Forbidden"
        else:
            response = jsonify({'message' : 'User forbidden!'})
            response.status_code = 403
            return response
    except Exception as e:
        # Log the exception to help with debugging
        print(f"An error occurred: {str(e)}")
        response = Response(status=500)
        return response


@app.route('/v1/assignments/<id>', methods=['DELETE'])
@auth.login_required
def delete_assignment(id):
    try:
        if not check_db_connection():
            response = Response(status=503)
            return response
        # try catch block to ensure that id is of type uuid
        try:
            uuid.UUID(id)
        except ValueError:
            response = jsonify({'message' : 'Invalid UUID format for id'})
            response.status_code = 400
            return response
        assignment = session.query(Assignment).filter_by(id=id).first()

        # If assignment id is not present in the table, return "404 Bad request"
        if not assignment:
            response = jsonify({'message' : 'No Assignment found!'})
            response.status_code = 404
            return response
        if (request.args) or (request.data) or (request.form) or (request.files):
            response = Response(status=400)
            return response
        owner = assignment.created_by
        get_user = auth.current_user()
        user_details = session.query(Account).filter_by(email=get_user).first()
        user = user_details.id
        if owner == user:
            session.delete(assignment)
            session.commit()
            response = jsonify({"message" : "Assignment deleted!"})
            response.status_code = 200
            return response
        else:
            response = jsonify({'message' : 'User forbidden!'})
            response.status_code = 403
            return response

    except Exception as e:
        # Log the exception to help with debugging
        print(f"An error occurred: {str(e)}")
        response = Response(status=500)
        return response


@auth.verify_password
def verify_password(username, password):
    account = session.query(Account).filter_by(email=username).first()
    if account:
        return bcrypt.check_password_hash(account.password, password)
    return False


if __name__ == '__main__':
    app.run()
