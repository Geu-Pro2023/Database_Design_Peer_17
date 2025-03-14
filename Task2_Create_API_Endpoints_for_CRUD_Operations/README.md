# FastAPI Student Management System

This project is a Student Management System built using FastAPI, SQLAlchemy, and MongoDB. It provides a RESTful API for managing student records, including creating, reading, updating, and deleting student information.

## Features

- Create, read, update, and delete student records.
  
- Store student data in a SQL database (MySQL).
  
- Log actions in a MongoDB database.
  
- Health check endpoint to monitor the status of the application.

## Technologies Used

- FastAPI
  
- SQLAlchemy
  
- Pydantic
  
- MongoDB
  
- MySQL
  
- Python
  
- dotenv for environment variable management

## Prerequisites

- Python 3.7 or higher
  
- MySQL database
  
- MongoDB database
 
- `pip` for installing Python packages

## Installation

1. Clone the repository:

 
   git clone https://github.com/yourusername/Database_Design_Peer_17.git
   cd Database_Design_Peer_17
   
Create a virtual environment (optional but recommended):


python -m venv venv

source venv/bin/activate  # On Windows use `venv\Scripts\activate`

Install the required packages:


pip install -r requirements.txt

Create a .env file in the root directory and add your database connection strings:


DATABASE_URL=mysql+pymysql://username:password@localhost/db_name

MONGO_URI=mongodb://localhost:27017

Replace username, password, and db_name with your MySQL credentials and database name.

Running the Application

To run the FastAPI application, use the following command:

uvicorn main:app --reload

The application will be available at http://127.0.0.1:8000.

API Endpoints

Health Check

GET /health

Checks the health of the application and the database connection.

Students

Create a Student

POST /students/
Request Body:

{
  "gender": "string",
  
  "race_ethnicity": "string",
  
  "lunch": "string",
  
  "education_level_id": 1,
  
  "test_preparation_id": 1,
  
  "math_score": 90,
  
  "reading_score": 85,
  
  "writing_score": 88
}
Read All Students

GET /students/
Query Parameters: skip, limit

Read a Single Student by ID

GET /students/{student_id}

Update a Student

PUT /students/{student_id}

Request Body:

{
  "gender": "string",
  
  "race_ethnicity": "string",
  
  "lunch": "string",
  
  "education_level_id": 1,
  
  "test_preparation_id": 1,
  
  "math_score": 90,
  
  "reading_score": 85,

  "writing_score": 88
}
Delete a Student

DELETE /students/{student_id}

Logging

All actions related to student records are logged in a MongoDB collection named student_logs.


Acknowledgments

FastAPI documentation: FastAPI

SQLAlchemy documentation: SQLAlchemy

MongoDB documentation: MongoDB
