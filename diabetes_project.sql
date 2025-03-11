CREATE DATABASE IF NOT EXISTS diabetes_project;
USE diabetes_project;

-- Patients Table
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    Age INT NOT NULL CHECK (Age BETWEEN 18 AND 120),
    Sex TINYINT NOT NULL,
    Education TINYINT NOT NULL,
    Income TINYINT NOT NULL
);

-- HealthIndicators Table
CREATE TABLE IF NOT EXISTS HealthIndicators (
    indicator_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    HighBP TINYINT NOT NULL,
    HighChol TINYINT NOT NULL,
    CholCheck TINYINT NOT NULL,
    BMI DECIMAL(5,2) NOT NULL,
    Smoker TINYINT NOT NULL,
    Stroke TINYINT NOT NULL,
    HeartDiseaseorAttack TINYINT NOT NULL,
    PhysActivity TINYINT NOT NULL,
    Fruits TINYINT NOT NULL,
    Veggies TINYINT NOT NULL,
    HvyAlcoholConsump TINYINT NOT NULL,
    AnyHealthcare TINYINT NOT NULL,
    NoDocbcCost TINYINT NOT NULL,
    GenHlth TINYINT NOT NULL,
    MentHlth INT NOT NULL,
    PhysHlth INT NOT NULL,
    DiffWalk TINYINT NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE
);

-- DiabetesDiagnosis Table
CREATE TABLE IF NOT EXISTS DiabetesDiagnosis (
    diagnosis_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    Diabetes_binary TINYINT NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE
);

-- Audit Table
CREATE TABLE IF NOT EXISTS DiabetesDiagnosisAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    diagnosis_id INT,
    patient_id INT,
    old_status TINYINT,
    new_status TINYINT,
    change_date DATETIME,
    action VARCHAR(10)
);

DELIMITER //
CREATE TRIGGER after_diabetes_update
AFTER UPDATE ON DiabetesDiagnosis
FOR EACH ROW
BEGIN
    INSERT INTO DiabetesDiagnosisAudit (diagnosis_id, patient_id, old_status, new_status, change_date, action)
    VALUES (OLD.diagnosis_id, OLD.patient_id, OLD.Diabetes_binary, NEW.Diabetes_binary, NOW(), 'UPDATE');
END //
DELIMITER ;

-- Permanent Staging Table
CREATE TABLE IF NOT EXISTS CSV_Staging (
    Diabetes_binary TINYINT,
    HighBP TINYINT,
    HighChol TINYINT,
    CholCheck TINYINT,
    BMI DECIMAL(5,2),
    Smoker TINYINT,
    Stroke TINYINT,
    HeartDiseaseorAttack TINYINT,
    PhysActivity TINYINT,
    Fruits TINYINT,
    Veggies TINYINT,
    HvyAlcoholConsump TINYINT,
    AnyHealthcare TINYINT,
    NoDocbcCost TINYINT,
    GenHlth TINYINT,
    MentHlth INT,
    PhysHlth INT,
    DiffWalk TINYINT,
    Sex TINYINT,
    Age INT,
    Education TINYINT,
    Income TINYINT
);

-- Enhanced Import Procedure
DELIMITER //
CREATE PROCEDURE ImportFromCSV()
BEGIN
    -- Insert Patients with validation
    INSERT INTO Patients (Age, Sex, Education, Income)
    SELECT Age, Sex, Education, Income
    FROM CSV_Staging
    WHERE Age BETWEEN 18 AND 120;  -- Data validation

    -- Insert Health Indicators
    INSERT INTO HealthIndicators (
        patient_id, HighBP, HighChol, CholCheck, BMI, Smoker,
        Stroke, HeartDiseaseorAttack, PhysActivity, Fruits, Veggies,
        HvyAlcoholConsump, AnyHealthcare, NoDocbcCost, GenHlth,
        MentHlth, PhysHlth, DiffWalk
    )
    SELECT 
        p.patient_id,
        s.HighBP, s.HighChol, s.CholCheck, s.BMI, s.Smoker,
        s.Stroke, s.HeartDiseaseorAttack, s.PhysActivity, s.Fruits, s.Veggies,
        s.HvyAlcoholConsump, s.AnyHealthcare, s.NoDocbcCost, s.GenHlth,
        s.MentHlth, s.PhysHlth, s.DiffWalk
    FROM CSV_Staging s
    INNER JOIN Patients p 
        ON p.Age = s.Age
        AND p.Sex = s.Sex
        AND p.Education = s.Education
        AND p.Income = s.Income;

    -- Insert Diagnoses
    INSERT INTO DiabetesDiagnosis (patient_id, Diabetes_binary)
    SELECT p.patient_id, s.Diabetes_binary
    FROM CSV_Staging s
    INNER JOIN Patients p 
        ON p.Age = s.Age
        AND p.Sex = s.Sex
        AND p.Education = s.Education
        AND p.Income = s.Income;

    -- Cleanup
    DROP TABLE CSV_Staging;
END //
DELIMITER ;

-- Select patient data for verification
SELECT * FROM Patients WHERE patient_id = 1;
SELECT * FROM HealthIndicators WHERE patient_id = 1;
SELECT * FROM DiabetesDiagnosis WHERE patient_id = 1;
SELECT * FROM DiabetesDiagnosisAudit;

CALL ImportFromCSV();


