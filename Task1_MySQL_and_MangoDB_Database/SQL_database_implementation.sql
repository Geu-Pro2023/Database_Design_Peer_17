-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS student_project;
USE student_project;

-- Step 2: Create Tables

-- EducationLevels Table
CREATE TABLE IF NOT EXISTS EducationLevels (
    education_level_id INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE
);

-- TestPreparation Table
CREATE TABLE IF NOT EXISTS TestPreparation (
    test_preparation_id INT AUTO_INCREMENT PRIMARY KEY,
    preparation_status VARCHAR(20) NOT NULL UNIQUE
);

-- Students Table
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

-- Audit Table for Logging Score Changes
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

-- Step 3: Stored Procedure to Insert Data into Students Table
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

-- Step 4: Trigger to Log Changes in Student Scores
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

-- Step 5: Staging Table for Bulk Import
CREATE TABLE IF NOT EXISTS StudentStaging (
    gender VARCHAR(10),
    race_ethnicity VARCHAR(50),
    parental_level_of_education VARCHAR(100),
    lunch VARCHAR(20),
    test_preparation_course VARCHAR(20),
    math_score INT,
    reading_score INT,
    writing_score INT
);

-- Step 6: Import Procedure to Load Data from Staging Table
DELIMITER //
CREATE PROCEDURE ImportStudentData()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'An error occurred during the import process.' AS ErrorMessage;
    END;

    START TRANSACTION;

    -- Insert Education Levels
    INSERT INTO EducationLevels (level_name)
    SELECT DISTINCT parental_level_of_education
    FROM StudentStaging
    WHERE parental_level_of_education NOT IN (SELECT level_name FROM EducationLevels);

    -- Insert Test Preparation Status
    INSERT INTO TestPreparation (preparation_status)
    SELECT DISTINCT test_preparation_course
    FROM StudentStaging
    WHERE test_preparation_course NOT IN (SELECT preparation_status FROM TestPreparation);

    -- Insert Students
    INSERT INTO Students (
        gender, race_ethnicity, lunch, education_level_id, test_preparation_id,
        math_score, reading_score, writing_score
    )
    SELECT 
        s.gender, s.race_ethnicity, s.lunch,
        e.education_level_id, t.test_preparation_id,
        s.math_score, s.reading_score, s.writing_score
    FROM StudentStaging s
    INNER JOIN EducationLevels e ON s.parental_level_of_education = e.level_name
    INNER JOIN TestPreparation t ON s.test_preparation_course = t.preparation_status
    WHERE s.math_score BETWEEN 0 AND 100
      AND s.reading_score BETWEEN 0 AND 100
      AND s.writing_score BETWEEN 0 AND 100;

    COMMIT;

    -- Optional Cleanup
    -- TRUNCATE TABLE StudentStaging;
END //
DELIMITER ;

CALL ImportStudentData();

-- Step 7: Final Queries for Verification
SHOW DATABASES;
SELECT COUNT(*) AS TotalStudents FROM Students;
SELECT COUNT(*) FROM students;
