from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, conint
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import logging
import os
from dotenv import load_dotenv

# Load environment variables (if using a .env file)
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database connection details
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set")

# Create the database engine
engine = create_engine(DATABASE_URL)

# Create a configured "Session" class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create a base class for declarative models
Base = declarative_base()

# FastAPI app instance
app = FastAPI()

# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Suppress Root Endpoint (`/`) and hide it from Swagger UI
@app.get("/", include_in_schema=False)
def read_root():
    return ""  # Returns an empty response to suppress 404

# Suppress Favicon Endpoint (`/favicon.ico`) and hide it from Swagger UI
@app.get("/favicon.ico", include_in_schema=False)
def favicon():
    return ""  # Returns an empty response to suppress 404

# SQLAlchemy Models
class EducationLevel(Base):
    __tablename__ = "EducationLevels"

    education_level_id = Column(Integer, primary_key=True, index=True)
    level_name = Column(String(100), nullable=False, unique=True)

class TestPreparation(Base):
    __tablename__ = "TestPreparation"

    test_preparation_id = Column(Integer, primary_key=True, index=True)
    preparation_status = Column(String(20), nullable=False, unique=True)

class Student(Base):
    __tablename__ = "Students"

    student_id = Column(Integer, primary_key=True, index=True)
    gender = Column(String(10), nullable=False)
    race_ethnicity = Column(String(50), nullable=False)
    lunch = Column(String(20), nullable=False)
    education_level_id = Column(Integer, ForeignKey("EducationLevels.education_level_id"), nullable=False)
    test_preparation_id = Column(Integer, ForeignKey("TestPreparation.test_preparation_id"), nullable=False)
    math_score = Column(Integer, nullable=False)
    reading_score = Column(Integer, nullable=False)
    writing_score = Column(Integer, nullable=False)

# Pydantic Schemas
class StudentCreate(BaseModel):
    gender: str
    race_ethnicity: str
    lunch: str
    education_level_id: int
    test_preparation_id: int
    math_score: int
    reading_score: int
    writing_score: int

class StudentResponse(StudentCreate):
    student_id: int

    class Config:
        from_attributes = True  # Updated for Pydantic v2

# Ensure all tables are created in the database
Base.metadata.create_all(bind=engine)

# Populate EducationLevels and TestPreparation tables
def initialize_tables(db: Session):
    # Populate EducationLevels table
    existing_levels = {level.level_name for level in db.query(EducationLevel).all()}
    new_levels = [
        "bachelor's degree", "some college", "master's degree",
        "associate's degree", "high school", "some high school"
    ]
    for level in new_levels:
        if level not in existing_levels:
            db.add(EducationLevel(level_name=level))
    db.commit()

    # Populate TestPreparation table
    existing_statuses = {status.preparation_status for status in db.query(TestPreparation).all()}
    new_statuses = ["none", "completed"]
    for status in new_statuses:
        if status not in existing_statuses:
            db.add(TestPreparation(preparation_status=status))
    db.commit()

# Initialize tables when the application starts
initialize_tables(next(get_db()))

# Pagination Parameters Model
class PaginationParams(BaseModel):
    skip: conint(ge=0) = 0  # Must be >= 0
    limit: conint(gt=0, le=1000) = 10  # Must be > 0 and <= 1000

# CRUD Endpoints

# Create a Student (POST)
@app.post("/students/", response_model=StudentResponse)
def create_student(student: StudentCreate, db: Session = Depends(get_db)):
    try:
        db_student = Student(**student.dict())
        db.add(db_student)
        db.commit()
        db.refresh(db_student)
        logger.info(f"Created student with ID: {db_student.student_id}")
        return db_student
    except Exception as e:
        logger.error(f"Error creating student: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create student: {str(e)}")

# Read All Students (GET)
@app.get("/students/", response_model=list[StudentResponse])
def read_students(params: PaginationParams = Depends(), db: Session = Depends(get_db)):
    students = db.query(Student).offset(params.skip).limit(params.limit).all()
    return students

# Read a Single Student by ID (GET)
@app.get("/students/{student_id}", response_model=StudentResponse)
def read_student(student_id: int, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.student_id == student_id).first()
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    return student

# Update a Student (PUT)
@app.put("/students/{student_id}", response_model=StudentResponse)
def update_student(student_id: int, updated_data: StudentCreate, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.student_id == student_id).first()
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    try:
        for key, value in updated_data.dict().items():
            setattr(student, key, value)
        db.commit()
        db.refresh(student)
        logger.info(f"Updated student with ID: {student_id}")
        return student
    except Exception as e:
        logger.error(f"Error updating student: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update student: {str(e)}")

# Delete a Student (DELETE)
@app.delete("/students/{student_id}")
def delete_student(student_id: int, db: Session = Depends(get_db)):
    student = db.query(Student).filter(Student.student_id == student_id).first()
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    try:
        db.delete(student)
        db.commit()
        logger.info(f"Deleted student with ID: {student_id}")
        return {"message": "Student deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting student: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete student: {str(e)}")

# Health Check Endpoint
@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))  # Simple query to test the database connection
        return {"status": "healthy"}
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        raise HTTPException(status_code=503, detail="Database connection failed")