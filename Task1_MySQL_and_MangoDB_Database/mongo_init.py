from pymongo import MongoClient
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# MongoDB connection
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

# Insert sample log
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