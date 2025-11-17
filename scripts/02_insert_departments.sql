/*
===============================================================================
INSERT DATA - Departments
===============================================================================
Script Purpose:
    This script inserts department data into the HR Analytics database.
    
Prerequisites:
    - Database 'HRAnalytics' must exist
    - Table 'departments' must be created (run hr_01_create_tables.sql first)

Usage:
    Execute this script in SQL Server Management Studio (SSMS)
===============================================================================
*/

USE HRAnalytics;
GO

-- Clear existing departments (if any)
IF EXISTS (SELECT 1 FROM dbo.departments)
BEGIN
    PRINT 'Clearing existing departments...'
    DELETE FROM dbo.departments;
    DBCC CHECKIDENT ('dbo.departments', RESEED, 0);
END;
GO

PRINT 'Inserting departments...'

-- Note: IDENTITY_INSERT is ON to use explicit department_id values
SET IDENTITY_INSERT dbo.departments ON;

INSERT INTO dbo.departments (department_id, department_name, department_head, location, budget) VALUES
(1, 'Human Resources', 'Jennifer Thompson', 'Floor 3, West Wing', 750000.00),
(2, 'Engineering', 'Michael Chen', 'Floor 2, North Wing', 2500000.00),
(3, 'Marketing', 'Sarah Johnson', 'Floor 1, East Wing', 1500000.00),
(4, 'Finance', 'Robert Wilson', 'Floor 4, South Wing', 1800000.00),
(5, 'Sales', 'David Rodriguez', 'Floor 1, South Wing', 2200000.00);

SET IDENTITY_INSERT dbo.departments OFF;
GO

DECLARE @dept_count INT = (SELECT COUNT(*) FROM dbo.departments);
PRINT 'Departments inserted successfully!'
PRINT 'Total departments: ' + CAST(@dept_count AS NVARCHAR)
GO
