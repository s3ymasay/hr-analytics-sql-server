/*
===============================================================================
CREATE DATABASE AND TABLES - HR Analytics Database
===============================================================================
Script Purpose:
    This script creates the HR Analytics database and all required tables for
    tracking and analyzing human resources information.
    
    Tables created:
    - departments: Organizational structure and departmental information
    - employees: Comprehensive employee data and organizational relationships
    - salaries: Historical and current compensation data
    - attendance: Daily attendance records with status and work hours

WARNING:
    Running this script will drop the entire 'HRAnalytics' database if it exists.
    All data in the database will be permanently deleted.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'HRAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'HRAnalytics')
BEGIN
    ALTER DATABASE HRAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HRAnalytics;
END;
GO

-- Create the 'HRAnalytics' database
CREATE DATABASE HRAnalytics;
GO

USE HRAnalytics;
GO

-- =====================================================================
-- Table: departments
-- =====================================================================
-- Purpose: Central repository for organizational structure and departmental information
-- =====================================================================

IF OBJECT_ID('dbo.departments', 'U') IS NOT NULL
    DROP TABLE dbo.departments;
GO

CREATE TABLE dbo.departments (
    department_id     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    department_name   NVARCHAR(100)     NOT NULL,
    department_head   NVARCHAR(100)     NULL,
    location          NVARCHAR(100)     NULL,
    budget            DECIMAL(15,2)     NULL,
    created_at        DATETIME2         NOT NULL DEFAULT GETDATE(),
    updated_at        DATETIME2         NOT NULL DEFAULT GETDATE()
);
GO

-- =====================================================================
-- Table: employees
-- =====================================================================
-- Purpose: Core HR table containing comprehensive employee data and organizational relationships
-- =====================================================================

IF OBJECT_ID('dbo.employees', 'U') IS NOT NULL
    DROP TABLE dbo.employees;
GO

CREATE TABLE dbo.employees (
    employee_id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    department_id           INT               NOT NULL,
    first_name              NVARCHAR(50)      NOT NULL,
    last_name               NVARCHAR(50)      NOT NULL,
    email                   NVARCHAR(100)     NOT NULL UNIQUE,
    phone                   NVARCHAR(20)      NULL,
    hire_date               DATE              NOT NULL,
    birth_date              DATE              NULL,
    gender                  NVARCHAR(10)      NULL,
    address                 NVARCHAR(200)     NULL,
    city                    NVARCHAR(100)     NULL,
    state                   NVARCHAR(50)      NULL,
    country                 NVARCHAR(50)      NULL,
    postal_code             NVARCHAR(20)      NULL,
    job_title               NVARCHAR(100)     NOT NULL,
    employment_status       NVARCHAR(20)      NOT NULL DEFAULT 'Active',  -- Active, On Leave, Terminated
    manager_id              INT               NULL,  -- Self-reference to employee_id
    education_level         NVARCHAR(50)      NULL,
    years_of_experience     INT               NULL,
    emergency_contact_name  NVARCHAR(100)     NULL,
    emergency_contact_phone NVARCHAR(20)      NULL,
    created_at              DATETIME2         NOT NULL DEFAULT GETDATE(),
    updated_at              DATETIME2         NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_employees_department FOREIGN KEY (department_id) REFERENCES dbo.departments(department_id),
    CONSTRAINT FK_employees_manager FOREIGN KEY (manager_id) REFERENCES dbo.employees(employee_id)
);
GO

-- =====================================================================
-- Table: salaries
-- =====================================================================
-- Purpose: Historical and current compensation data
-- =====================================================================

IF OBJECT_ID('dbo.salaries', 'U') IS NOT NULL
    DROP TABLE dbo.salaries;
GO

CREATE TABLE dbo.salaries (
    salary_id                INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    employee_id              INT               NOT NULL,
    effective_date           DATE              NOT NULL,
    end_date                 DATE              NULL,
    amount                   DECIMAL(12,2)     NOT NULL,
    bonus                    DECIMAL(12,2)     NOT NULL DEFAULT 0,
    allowance                DECIMAL(12,2)     NOT NULL DEFAULT 0,
    tax_percentage           DECIMAL(5,2)      NULL,
    retirement_contribution  DECIMAL(12,2)     NOT NULL DEFAULT 0,
    health_insurance         DECIMAL(12,2)     NOT NULL DEFAULT 0,
    created_at               DATETIME2         NOT NULL DEFAULT GETDATE(),
    updated_at               DATETIME2         NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_salaries_employee FOREIGN KEY (employee_id) REFERENCES dbo.employees(employee_id)
);
GO

-- =====================================================================
-- Table: attendance
-- =====================================================================
-- Purpose: Daily attendance records with status and work hours
-- =====================================================================

IF OBJECT_ID('dbo.attendance', 'U') IS NOT NULL
    DROP TABLE dbo.attendance;
GO

CREATE TABLE dbo.attendance (
    attendance_id    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    employee_id      INT               NOT NULL,
    attendance_date  DATE              NOT NULL,
    check_in         TIME              NULL,
    check_out        TIME              NULL,
    status           NVARCHAR(20)      NOT NULL,  -- Present, Absent, Half Day, Work From Home, Sick Leave, Vacation, Holiday
    work_hours       DECIMAL(5,2)      NULL,
    overtime_hours   DECIMAL(5,2)      NOT NULL DEFAULT 0,
    notes            NVARCHAR(MAX)     NULL,
    created_at       DATETIME2         NOT NULL DEFAULT GETDATE(),
    updated_at       DATETIME2         NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_attendance_employee FOREIGN KEY (employee_id) REFERENCES dbo.employees(employee_id)
);
GO

-- =====================================================================
-- Create Indexes for Query Performance
-- =====================================================================

CREATE INDEX IX_employees_department ON dbo.employees(department_id);
CREATE INDEX IX_salaries_employee ON dbo.salaries(employee_id);
CREATE INDEX IX_attendance_employee ON dbo.attendance(employee_id);
CREATE INDEX IX_attendance_date ON dbo.attendance(attendance_date);
CREATE INDEX IX_salaries_effective_date ON dbo.salaries(effective_date);
GO

-- =====================================================================
-- Verification: Display table information
-- =====================================================================

SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO

PRINT '=========================================='
PRINT 'HR Analytics Database Created Successfully!'
PRINT '=========================================='
PRINT ''
PRINT 'Tables created:'
PRINT '  - departments'
PRINT '  - employees'
PRINT '  - salaries'
PRINT '  - attendance'
PRINT ''
PRINT 'Next step: Load data using INSERT scripts'
PRINT '=========================================='
GO
