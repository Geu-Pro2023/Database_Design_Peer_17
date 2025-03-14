# Student Performance API

[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white)](https://fastapi.tiangolo.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)

A complete solution for managing student academic records with predictive analytics capabilities.

## Features

- **CRUD Operations** for student records
- **Data Validation** (score ranges, foreign key constraints)
- **Audit Logging** of score changes
- **Bulk Data Import** via staging table
- **Pagination Support** (default 1000 records/page)
- **Health Monitoring** endpoint
- **Automated Prediction** pipeline

## Database Design 🗄️

```sql
-- Core Tables
CREATE TABLE EducationLevels (
    education_level_id INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE TestPreparation (
    test_preparation_id INT AUTO_INCREMENT PRIMARY KEY,
    preparation_status VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    -- other fields --
    math_score INT NOT NULL CHECK (0 <= math_score <= 100),
    reading_score INT NOT NULL CHECK (0 <= reading_score <= 100),
    writing_score INT NOT NULL CHECK (0 <= writing_score <= 100)
);

-- Audit Table
CREATE TABLE StudentScoreAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    old_math_score INT,
    new_math_score INT,
    change_date DATETIME NOT NULL,
    action VARCHAR(10) NOT NULL
);
```

## API Documentation

Base URL: https://student-performance-api-p46u.onrender.com

Endpoints
```
Endpoint	Method	Description	Parameters
/students/	POST	Create new student	JSON Body
/students/	GET	List all students	skip, limit
/students/{id}	GET	Get student by ID	Path Param
/students/{id}	PUT	Update student	JSON Body
/students/{id}	DELETE	Delete student	Path Param
/health	GET	System health check	-
```
## Setup Instructions 
1. **Clone Repository** 
```
git clone https://github.com/your-repo/student-performance-api.git
cd student-performance-api
```
2. **Install Dependencies**
```
pip install -r requirements.txt
```
3. **Database Setup**
```
mysql -u root -p < database.sql
```
4. **Configure Environment**
```
echo "DATABASE_URL=mysql+pymysql://user:password@localhost/student_project" > .env
```
5. **Run FastAPI Server**
```
uvicorn main:app --reload
```

## Usage Examples
**Create Student**
```
curl -X POST "https://student-performance-api-p46u.onrender.com/students/" \
-H "Content-Type: application/json" \
-d '{
  "gender": "female",
  "race_ethnicity": "group B",
  "lunch": "standard",
  "education_level_id": 1,
  "test_preparation_id": 2,
  "math_score": 85,
  "reading_score": 92,
  "writing_score": 89
}'
```
**Predict Performance**
```
import requests

def predict(student_id):
    response = requests.get(f"https://student-performance-api-p46u.onrender.com/students/{student_id}")
    scores = response.json()
    avg = (scores['math_score'] + scores['reading_score'] + scores['writing_score']) / 3
    return "Excellent" if avg >= 90 else "Good" if avg >= 75 else "Average" if avg >= 60 else "Needs Improvement"

print(predict(42))  # Example: Returns "Good"
```

# 🔗 Live API: https://student-performance-api-p46u.onrender.com

# 📄 Documentation: API Docs


# Team Members
1. John Deng Madit Akech
2. Geu Aguto Garang Bior
3. Kuir Juach Kuir Thuch
