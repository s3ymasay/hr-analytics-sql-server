/*
===============================================================================
INSERT DATA - Attendance Records (3 Years)
===============================================================================
Script Purpose:
    This script generates attendance data for all employees for the past 3 years.
    Creates approximately 75,000 attendance records with realistic patterns.
    
Prerequisites:
    - Database 'HRAnalytics' must exist
    - Table 'attendance' must be created
    - Employees must be inserted first

Usage:
    Execute this script in SQL Server Management Studio (SSMS)
    This may take a few minutes to complete.
===============================================================================
*/

USE HRAnalytics;
GO

PRINT '=========================================='
PRINT 'Generating Attendance Data (3 Years)'
PRINT 'This may take a few minutes...'
-- Clear existing attendance records (if any)
IF EXISTS (SELECT 1 FROM dbo.attendance)
BEGIN
    PRINT 'Clearing existing attendance records...'
    DELETE FROM dbo.attendance;
    DBCC CHECKIDENT ('dbo.attendance', RESEED, 0);
END;
GO
PRINT '=========================================='
PRINT ''
GO

DECLARE @start_date DATE = DATEADD(YEAR, -3, GETDATE());
DECLARE @end_date DATE = GETDATE();
DECLARE @current_date DATE;
DECLARE @employee_id INT;
DECLARE @hire_date DATE;
DECLARE @dow INT;
DECLARE @rand FLOAT;
DECLARE @status VARCHAR(20);
DECLARE @check_in TIME;
DECLARE @check_out TIME;
DECLARE @work_hours DECIMAL(5,2);
DECLARE @overtime_hours DECIMAL(5,2);
DECLARE @notes NVARCHAR(MAX);
DECLARE @is_holiday BIT;
DECLARE @hour_diff FLOAT;

-- Create temp table for holidays
CREATE TABLE #holidays (holiday_date DATE);

INSERT INTO #holidays VALUES
-- 2021 holidays
('2021-01-01'), ('2021-01-18'), ('2021-02-15'), ('2021-05-31'), ('2021-07-05'), 
('2021-09-06'), ('2021-10-11'), ('2021-11-11'), ('2021-11-25'), ('2021-12-24'), 
('2021-12-25'), ('2021-12-31'),
-- 2022 holidays
('2022-01-01'), ('2022-01-17'), ('2022-02-21'), ('2022-05-30'), ('2022-07-04'), 
('2022-09-05'), ('2022-10-10'), ('2022-11-11'), ('2022-11-24'), ('2022-12-26'), 
('2022-12-31'),
-- 2023 holidays
('2023-01-01'), ('2023-01-16'), ('2023-02-20'), ('2023-05-29'), ('2023-06-19'), 
('2023-07-04'), ('2023-09-04'), ('2023-10-09'), ('2023-11-10'), ('2023-11-23'), 
('2023-12-25'), ('2023-12-31'),
-- 2024 holidays
('2024-01-01'), ('2024-01-15'), ('2024-02-19'), ('2024-05-27'), ('2024-06-19'), 
('2024-07-04'), ('2024-09-02'), ('2024-10-14'), ('2024-11-11'), ('2024-11-28'), 
('2024-12-25'), ('2024-12-31');

-- Cursor to loop through employees
DECLARE employee_cursor CURSOR FOR 
SELECT employee_id, hire_date FROM dbo.employees;

OPEN employee_cursor;
FETCH NEXT FROM employee_cursor INTO @employee_id, @hire_date;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Start from hire date or 3 years ago, whichever is later
    SET @current_date = CASE 
        WHEN @hire_date > @start_date THEN @hire_date 
        ELSE @start_date 
    END;
    
    -- Loop through each day
    WHILE @current_date <= @end_date
    BEGIN
        -- Get day of week (1=Sunday, 7=Saturday)
        SET @dow = DATEPART(WEEKDAY, @current_date);
        
        -- Check if holiday
        SET @is_holiday = CASE 
            WHEN EXISTS (SELECT 1 FROM #holidays WHERE holiday_date = @current_date) 
            THEN 1 ELSE 0 
        END;
        
        -- Generate random number for status
        SET @rand = RAND(CHECKSUM(NEWID()));
        
        -- Skip weekends for most employees (10% chance of weekend work)
        IF (@dow NOT IN (1, 7)) OR (@dow IN (1, 7) AND @rand < 0.1)
        BEGIN
            -- Determine status
            IF @is_holiday = 1
            BEGIN
                SET @status = CASE WHEN @rand < 0.95 THEN 'Holiday' ELSE 'Present' END;
            END
            ELSE IF @dow IN (1, 7)
            BEGIN
                SET @status = 'Present'; -- Working on weekend
            END
            ELSE
            BEGIN
                SET @status = CASE 
                    WHEN @rand < 0.85 THEN 'Present'
                    WHEN @rand < 0.90 THEN 'Work From Home'
                    WHEN @rand < 0.95 THEN 'Sick Leave'
                    WHEN @rand < 0.98 THEN 'Vacation'
                    ELSE 'Absent'
                END;
            END;
            
            -- Generate times and hours based on status
            IF @status IN ('Present', 'Work From Home')
            BEGIN
                -- Check in time: 8:00 AM + random 0-60 minutes
                SET @check_in = DATEADD(MINUTE, FLOOR(@rand * 60), '08:00:00');
                
                -- Random number for overtime decision
                SET @rand = RAND(CHECKSUM(NEWID()));
                
                -- 20% chance of overtime
                IF @rand < 0.2
                BEGIN
                    SET @check_out = DATEADD(MINUTE, FLOOR(@rand * 180), '17:00:00');
                    SET @hour_diff = DATEDIFF(MINUTE, @check_in, @check_out) / 60.0;
                    SET @work_hours = CASE WHEN @hour_diff > 8 THEN 8 ELSE @hour_diff END;
                    SET @overtime_hours = CASE WHEN @hour_diff > 8 THEN @hour_diff - 8 ELSE 0 END;
                END
                ELSE
                BEGIN
                    SET @check_out = DATEADD(MINUTE, FLOOR(@rand * 60) - 30, '17:00:00');
                    SET @hour_diff = DATEDIFF(MINUTE, @check_in, @check_out) / 60.0;
                    SET @work_hours = @hour_diff;
                    SET @overtime_hours = 0;
                END;
                
                -- 5% chance of leaving early
                SET @rand = RAND(CHECKSUM(NEWID()));
                IF @rand < 0.05
                BEGIN
                    SET @check_out = DATEADD(MINUTE, FLOOR(@rand * 240), @check_in);
                    SET @work_hours = DATEDIFF(MINUTE, @check_in, @check_out) / 60.0;
                    SET @overtime_hours = 0;
                    SET @notes = 'Left early';
                END
                ELSE
                BEGIN
                    SET @notes = NULL;
                END;
            END
            ELSE IF @status = 'Half Day'
            BEGIN
                SET @rand = RAND(CHECKSUM(NEWID()));
                IF @rand < 0.5
                BEGIN
                    -- Morning half day
                    SET @check_in = DATEADD(MINUTE, FLOOR(@rand * 30), '08:00:00');
                    SET @check_out = DATEADD(MINUTE, FLOOR(@rand * 60), '12:00:00');
                END
                ELSE
                BEGIN
                    -- Afternoon half day
                    SET @check_in = DATEADD(MINUTE, FLOOR(@rand * 60), '12:00:00');
                    SET @check_out = DATEADD(MINUTE, FLOOR(@rand * 30), '17:00:00');
                END;
                
                SET @work_hours = DATEDIFF(MINUTE, @check_in, @check_out) / 60.0;
                SET @overtime_hours = 0;
                SET @notes = 'Half day';
            END
            ELSE
            BEGIN
                -- Not working
                SET @check_in = NULL;
                SET @check_out = NULL;
                SET @work_hours = 0;
                SET @overtime_hours = 0;
                
                SET @notes = CASE @status
                    WHEN 'Sick Leave' THEN 'Sick leave'
                    WHEN 'Vacation' THEN 'Vacation'
                    WHEN 'Absent' THEN 'Unplanned absence'
                    WHEN 'Holiday' THEN 'Company holiday'
                    ELSE NULL
                END;
            END;
            
            -- Insert attendance record
            INSERT INTO dbo.attendance (
                employee_id, 
                attendance_date, 
                check_in, 
                check_out, 
                status, 
                work_hours, 
                overtime_hours, 
                notes
            ) VALUES (
                @employee_id,
                @current_date,
                @check_in,
                @check_out,
                @status,
                @work_hours,
                @overtime_hours,
                @notes
            );
        END;
        
        -- Next day
        SET @current_date = DATEADD(DAY, 1, @current_date);
    END;
    
    FETCH NEXT FROM employee_cursor INTO @employee_id, @hire_date;
END;

CLOSE employee_cursor;
DEALLOCATE employee_cursor;

DROP TABLE #holidays;
GO

PRINT ''
PRINT '=========================================='
PRINT 'Attendance Data Generated Successfully!'
PRINT '=========================================='
PRINT ''
DECLARE @att_count INT = (SELECT COUNT(*) FROM dbo.attendance);
PRINT 'Total attendance records: ' + CAST(@att_count AS NVARCHAR)
PRINT ''
PRINT 'Database ready for analysis!'
PRINT '=========================================='
GO
