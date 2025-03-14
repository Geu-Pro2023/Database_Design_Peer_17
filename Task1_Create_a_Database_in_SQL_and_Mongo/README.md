# Student Project Database

This project sets up a **MySQL relational database** and integrates **MongoDB** for logging student-related activities. It includes tables for storing student performance data and ensures **data integrity** with constraints, triggers, and stored procedures.

## ER Diagram
The **Entity-Relationship (ER) Diagram** illustrates the structure and relationships of the database.

![ER Diagram](![Uploading image.png…]()
) *(Replace with actual path to the ER diagram image)*

---
## 1️⃣ MySQL Database Setup
### Step 1: Create Database
```sql
CREATE DATABASE IF NOT EXISTS student_project;
USE student_project;
```

### Step 2: Create Tables
#### EducationLevels Table
```sql
CREATE TABLE IF NOT EXISTS EducationLevels (
    education_level_id INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE
);
```

#### TestPreparation Table
```sql
CREATE TABLE IF NOT EXISTS TestPreparation (
    test_preparation_id INT AUTO_INCREMENT PRIMARY KEY,
    preparation_status VARCHAR(20) NOT NULL UNIQUE
);
```

#### Students Table
```sql
CREATE TABLE IF NOT EXISTS Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    gender VARCHAR(10) NOT NULL,
    race_ethnicity VARCHAR(50) NOT NULL,
    lunch VARCHAR(20) NOT NULL,
    education_level_id INT NOT NULL,
    test_preparation_id INT NOT NULL,
    math_score INT NOT NULL CHECK (math_score BETWEEN 0 AND 100),
    reading_score INT NOT NULL CHECK (reading_score BETWEEN 0 AND 100),
    writing_score INT NOT NULL CHECK (writing_score BETWEEN 0 AND 100),
    FOREIGN KEY (education_level_id) REFERENCES EducationLevels(education_level_id) ON DELETE CASCADE,
    FOREIGN KEY (test_preparation_id) REFERENCES TestPreparation(test_preparation_id) ON DELETE CASCADE
);
```

### Step 3: Student Score Audit Log
```sql
CREATE TABLE IF NOT EXISTS StudentScoreAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    old_math_score INT,
    new_math_score INT,
    old_reading_score INT,
    new_reading_score INT,
    old_writing_score INT,
    new_writing_score INT,
    change_date DATETIME NOT NULL,
    action VARCHAR(10) NOT NULL
);
```

### Step 4: Stored Procedures & Triggers
#### Insert Student Procedure
```sql
DELIMITER //
CREATE PROCEDURE InsertStudent(
    IN p_gender VARCHAR(10),
    IN p_race_ethnicity VARCHAR(50),
    IN p_lunch VARCHAR(20),
    IN p_education_level_id INT,
    IN p_test_preparation_id INT,
    IN p_math_score INT,
    IN p_reading_score INT,
    IN p_writing_score INT
)
BEGIN
    INSERT INTO Students (
        gender, race_ethnicity, lunch, education_level_id, test_preparation_id,
        math_score, reading_score, writing_score
    )
    VALUES (
        p_gender, p_race_ethnicity, p_lunch, p_education_level_id, p_test_preparation_id,
        p_math_score, p_reading_score, p_writing_score
    );
END //
DELIMITER ;
```

#### Trigger: Log Score Changes
```sql
DELIMITER //
CREATE TRIGGER AfterUpdateStudentScores
AFTER UPDATE ON Students
FOR EACH ROW
BEGIN
    IF OLD.math_score != NEW.math_score OR OLD.reading_score != NEW.reading_score OR OLD.writing_score != NEW.writing_score THEN
        INSERT INTO StudentScoreAudit (
            student_id, old_math_score, new_math_score,
            old_reading_score, new_reading_score,
            old_writing_score, new_writing_score,
            change_date, action
        )
        VALUES (
            OLD.student_id, OLD.math_score, NEW.math_score,
            OLD.reading_score, NEW.reading_score,
            OLD.writing_score, NEW.writing_score,
            NOW(), 'UPDATE'
        );
    END IF;
END //
DELIMITER ;
```

### Step 5: Import Student Data from Staging Table
```sql
DELIMITER //
CREATE PROCEDURE ImportStudentData()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'An error occurred during the import process.' AS ErrorMessage;
    END;

    START TRANSACTION;

    INSERT INTO EducationLevels (level_name)
    SELECT DISTINCT parental_level_of_education FROM StudentStaging
    WHERE parental_level_of_education NOT IN (SELECT level_name FROM EducationLevels);

    INSERT INTO TestPreparation (preparation_status)
    SELECT DISTINCT test_preparation_course FROM StudentStaging
    WHERE test_preparation_course NOT IN (SELECT preparation_status FROM TestPreparation);

    INSERT INTO Students (gender, race_ethnicity, lunch, education_level_id, test_preparation_id, math_score, reading_score, writing_score)
    SELECT s.gender, s.race_ethnicity, s.lunch, e.education_level_id, t.test_preparation_id, s.math_score, s.reading_score, s.writing_score
    FROM StudentStaging s
    INNER JOIN EducationLevels e ON s.parental_level_of_education = e.level_name
    INNER JOIN TestPreparation t ON s.test_preparation_course = t.preparation_status
    WHERE s.math_score BETWEEN 0 AND 100 AND s.reading_score BETWEEN 0 AND 100 AND s.writing_score BETWEEN 0 AND 100;

    COMMIT;
END //
DELIMITER ;
```

---
## 2️⃣ MongoDB Integration
### Setup MongoDB with Python
#### Install Dependencies
```bash
pip install pymongo python-dotenv
```

#### Connect to MongoDB
```python
from pymongo import MongoClient
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()
MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    raise ValueError("MONGO_URI environment variable is not set")

mongo_client = MongoClient(MONGO_URI)
mongo_db = mongo_client['student_project']

# Initialize collections
collections = ["student_logs", "unstructured_data"]
for collection in collections:
    if collection not in mongo_db.list_collection_names():
        mongo_db.create_collection(collection)
        print(f"Created collection: {collection}")
```

#### Insert Sample Log
```python
log_data = {
    "student_id": 1,
    "action": "CREATE",
    "details": {
        "gender": "male",
        "race_ethnicity": "group A",
        "lunch": "standard",
        "education_level": "bachelor's degree",
        "test_preparation": "completed",
        "math_score": 90,
        "reading_score": 85,
        "writing_score": 88
    },
    "timestamp": "2023-10-01T12:00:00Z"
}
mongo_db["student_logs"].insert_one(log_data)
print("Inserted sample log into MongoDB.")
```

---
## 📌 Final Queries for Verification
```sql
SHOW DATABASES;
SELECT COUNT(*) AS TotalStudents FROM Students;
SELECT COUNT(*) FROM students;
```


