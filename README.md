# Student Performance Database

## Overview
The **Student Performance Database** is a relational database schema designed to manage and analyze student data. It includes tables for tracking education levels, test preparation, student scores, and audit logs for score changes. The database serves as the foundation for a FastAPI-based backend application that provides RESTful APIs for interacting with the data.

This project is ideal for educational institutions, researchers, or developers who need a scalable system to store and retrieve student performance metrics.

#### Dataset: https://www.kaggle.com/code/spscientist/student-performance-in-exams/input

---

## Features
- Tracks student performance across multiple metrics (math, reading, writing scores).
- Logs changes to student scores using the `StudentScoreAudit` table.
- Supports relationships between students, education levels, and test preparation statuses.
- Designed for scalability and integration with machine learning models (future enhancements).
- **CRUD Operations** for student records
- **Data Validation** (score ranges, foreign key constraints)
- **Audit Logging** of score changes
- **Bulk Data Import** via staging table
- **Pagination Support** (default 1000 records/page)
- **Health Monitoring** endpoint
- **Automated Prediction** pipeline
  
---

## Database Design 🗄️

### **1. MySQl Implementation**

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
### **2. MongoDB Implementation**
a). **Install MongoDB Locally**
```
Install MongoDB Locally
# macOS (using Homebrew)
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community
```
b). **Use MongoDB Atlas**
```
Sign up for MongoDB Atlas .
Create a cluster and get the connection string.
```

c). **Update the Database Connection**
**Using pymongo**:
```
from pymongo import MongoClient
# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Replace with your MongoDB URI
db = client["student_project"]
students_collection = db["students"]
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

## Make Predictions
Use the following Python script to load the trained model and scaler, preprocess the input data, and make predictions:
```
import pandas as pd
import joblib

# Load the trained model and scaler
model = joblib.load("best_student_performance_model.pkl")
scaler = joblib.load("scaler.pkl")

# Define input data
input_data = {
    "gender": "male",
    "race/ethnicity": "group C",
    "parental level of education": "bachelor's degree",
    "lunch": "standard",
    "test preparation course": "none"
}

# Convert input data to DataFrame
df_input = pd.DataFrame([input_data])

# Perform One-Hot Encoding
df_input = pd.get_dummies(df_input, columns=["gender", "race/ethnicity", "parental level of education", "lunch", "test preparation course"], drop_first=True)

# Scale the input data
input_scaled = scaler.transform(df_input)

# Make prediction
predicted_score = model.predict(input_scaled)
print(f"Predicted Average Score: {predicted_score[0]:.2f}")
```
**Example Output**
```
Predicted Average Score: 72.50
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

## Documentation
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white)](https://fastapi.tiangolo.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)

---

## Team Members and Contributions
1. **Geu Aguto Garang** - TASK 1: Create a Database in SQL and Mongo
2. **Kuir Juach Kuir** - Task 2: Create API Endpoints for CRUD Operations
3. **John Akech** - Task 3: Create a Script to Fetch Data for Prediction

---
