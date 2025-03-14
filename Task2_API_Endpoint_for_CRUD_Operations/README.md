# Student Management API

This is a FastAPI-based Student Management API that integrates with MySQL and MongoDB for managing student records, logging actions, and performing CRUD operations.

## Features
- **FastAPI Framework** for high-performance API development
- **MySQL Database** for structured data storage
- **MongoDB Logging** for tracking student-related actions
- **Pydantic Validation** for data validation and serialization
- **SQLAlchemy ORM** for database operations
- **Environment Variable Configuration** using `dotenv`
- **Pagination Support** for efficient data retrieval
- **Swagger UI & ReDoc** for API documentation

## Prerequisites
Before running this application, ensure you have:
- Python 3.8+
- MySQL Server
- MongoDB
- Installed dependencies using `pip install -r requirements.txt`
- `.env` file with:
  ```ini
  DATABASE_URL=mysql+pymysql://user:password@localhost/database_name
  MONGO_URI=mongodb://localhost:27017
  ```

## Installation
1. Clone the repository:
   ```sh
   git clone git@github.com:Geu-Pro2023/Database_Design_Peer_17.git
   cd Database_Design_Peer_17
   ```
2. Install dependencies:
   ```sh
   pip install -r requirements.txt
   ```
3. Set up the database:
   ```sh
   python -c 'from main import Base, engine; Base.metadata.create_all(bind=engine)'
   ```
4. Run the application:
   ```sh
   uvicorn main:app --reload
   ```

## API Endpoints
### Student Endpoints
| Method | Endpoint | Description |
|--------|---------|-------------|
| POST | `/students/` | Create a student |
| GET | `/students/` | Get all students with pagination |
| GET | `/students/{student_id}` | Get a student by ID |
| PUT | `/students/{student_id}` | Update a student |
| DELETE | `/students/{student_id}` | Delete a student |

### Health Check
| Method | Endpoint | Description |
|--------|---------|-------------|
| GET | `/health` | Check database health |

## ER Diagram
The database schema follows this structure:
```
+------------------+
| EducationLevels  |
+------------------+
| education_level_id (PK) |
| level_name |
+------------------+
        |
        | (FK)
        v
+------------------+
| Students        |
+------------------+
| student_id (PK) |
| gender |
| race_ethnicity |
| lunch |
| education_level_id (FK) |
| test_preparation_id (FK) |
| math_score |
| reading_score |
| writing_score |
+------------------+
        |
        | (FK)
        v
+------------------+
| TestPreparation |
+------------------+
| test_preparation_id (PK) |
| preparation_status |
+------------------+
```

## Logging
All student actions (create, update, delete) are logged in MongoDB under the `student_logs` collection.

## License
This project is licensed under the MIT License.
