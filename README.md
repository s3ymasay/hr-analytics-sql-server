# HR Analytics - SQL Server

A comprehensive HR analytics database with 3 years of synthetic data and 100+ SQL practice queries.

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2016+-CC2927?logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📊 Overview

This project provides a realistic HR analytics database with:
- **98 employees** across 5 departments
- **~75,000 attendance records** (3 years of data)
- **124 salary records** with raises and bonuses
- **100+ SQL queries** from basic to advanced

Perfect for SQL practice, interview preparation, and learning business analytics.

---

## 🗃️ Database Schema

**4 Tables:**
- `departments` - 5 departments with budgets and locations
- `employees` - 98 employees with demographics and job info
- `salaries` - Salary history with bonuses and benefits
- `attendance` - Daily attendance records over 3 years

**Relationships:**
```
departments (1:N) employees (1:N) salaries
                           (1:N) attendance
employees (manager/employee hierarchy)
```

---

## 🚀 Quick Start

### Prerequisites
- SQL Server 2016 or later
- SQL Server Management Studio (SSMS)

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/hr-analytics-sql-server.git
cd hr-analytics-sql-server

# Run scripts in order (in SSMS or sqlcmd)
scripts/01_create_tables.sql
scripts/02_insert_departments.sql
scripts/03_insert_employees.sql
scripts/04_insert_salaries.sql
scripts/05_insert_attendance.sql  # Takes 2-5 seconds

# Verify
USE HRAnalytics;
SELECT COUNT(*) FROM attendance;  -- Should return ~75,000
```

---

## 📚 Practice Queries

The `practice/solutions.sql` file contains **100+ queries** organized by difficulty:

| Category | Queries | Topics |
|----------|---------|--------|
| Departments | 1-10 | Aggregations, budgets |
| Employees | 11-35 | Demographics, tenure, hierarchy |
| Salaries | 36-60 | Compensation analysis, trends |
| Attendance | 61-90 | Patterns, remote work |
| Cross-Table | 91-110 | Complex joins, correlations |

### Example Queries

**Basic: Average salary by department**
```sql
SELECT 
    d.department_name,
    ROUND(AVG(s.amount), 2) AS avg_salary
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE s.end_date IS NULL
GROUP BY d.department_name
ORDER BY avg_salary DESC;
```

**Advanced: Organizational hierarchy (Recursive CTE)**
```sql
WITH org_hierarchy AS (
    SELECT employee_id, first_name, last_name, manager_id, 0 AS level
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, h.level + 1
    FROM employees e
    JOIN org_hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM org_hierarchy ORDER BY level;
```

---

## ✨ SQL Concepts Covered

- ✅ Aggregations (SUM, AVG, COUNT, MIN, MAX)
- ✅ Joins (INNER, LEFT, CROSS)
- ✅ Window Functions (ROW_NUMBER, RANK, LAG, LEAD)
- ✅ CTEs (Common Table Expressions)
- ✅ Recursive Queries
- ✅ Date Functions (DATEDIFF, DATEADD, DATEPART)
- ✅ Subqueries
- ✅ CASE Statements

---

## 📁 Project Structure

```
hr-analytics-sql-server/
├── README.md
├── .gitignore
├── scripts/
│   ├── 01_create_tables.sql
│   ├── 02_insert_departments.sql
│   ├── 03_insert_employees.sql
│   ├── 04_insert_salaries.sql
│   └── 05_insert_attendance.sql
└── practice/
    └── solutions.sql (100+ queries)
```

---

## 📝 License

MIT License - feel free to use for learning and practice.

---

## 🙏 Acknowledgments

- Query concepts inspired by online SQL courses and adapted for this project
- Database design and synthetic data generation created independently
- PostgreSQL to SQL Server conversion and optimization
- Built for educational and portfolio purposes

---
