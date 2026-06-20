USE Employee_management_System_project;
-- #Analysis Questions
SELECT * FROM Employee;
SELECT * FROM JobDepartment;
SELECT * FROM Leaves;
SELECT * FROM Payroll;
SELECT * FROM Qualification;
SELECT * FROM SalaryBonus;

-- ##1. EMPLOYEE INSIGHTS
-- 1.1. How many unique employees are currently in the system?
SELECT COUNT(*) AS total_employees
FROM Employee;


-- 1.2. Which departments have the highest number of employees?
SELECT jd.jobdept,
		COUNT(e.emp_id) AS total_employees
FROM employee e
JOIN jobdepartment jd
	ON e.job_id = jd.job_id
GROUP BY jd.jobdept
ORDER BY total_employees DESC;


-- 1.3. What is the average salary per department?
SELECT jd.jobdept,
       ROUND(AVG(p.total_amount),2) AS average_salary
FROM Payroll p
JOIN Employee e ON p.emp_ID = e.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;


-- 1.4. Who are the top 5 highest-paid employees?
SELECT e.emp_ID, e.firstname, e.lastname, 
	   jd.jobdept, SUM(p.total_amount) AS total_paid 
FROM Payroll p 
JOIN Employee e 
	ON p.emp_ID = e.emp_ID 
JOIN JobDepartment jd 
	ON e.Job_ID = jd.Job_ID 
GROUP BY e.emp_ID, e.firstname, e.lastname, jd.jobdept 
ORDER BY total_paid 
DESC LIMIT 5;


-- 1.5. What is the total salary expenditure across the company?
SELECT SUM(total_amount) AS total_salary_expenditure
FROM Payroll;


-- ##2. JOB ROLE AND DEPARTMENT ANALYSIS
-- 2.1. How many different job roles exist in each department?
SELECT jobdept, COUNT(DISTINCT name) AS Total_diff_jobs
FROM jobdepartment
GROUP BY jobdept
ORDER BY Total_diff_jobs DESC;


-- 2.2 What is the average salary range per department?
SELECT jd.jobdept,
ROUND(AVG(amount),2) AS avg_salary
FROM jobdepartment jd
JOIN SalaryBonus sb
	ON sb.job_ID = jd.job_ID
GROUP BY jd.jobdept;


-- 2.3 Which job roles offer the highest salary?
SELECT jd.name AS role,
       MAX(sb.amount) AS max_salary
FROM SalaryBonus sb
JOIN JobDepartment jd
     ON sb.job_ID = jd.job_ID
GROUP BY jd.name
ORDER BY max_salary DESC
LIMIT 1;


-- 2.4 Which departments have the highest total salary allocation?
SELECT jd.jobdept, 
		SUM(sb.amount) AS total_dept_salary
FROM SalaryBonus sb
JOIN JobDepartment jd
	ON sb.job_ID = jd.job_ID
GROUP BY jd.jobdept
ORDER BY total_dept_salary DESC;


-- ##3. QUALIFICATION AND SKILLS ANALYSIS
-- 3.1 How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM Qualification;


-- 3.2 Which positions require the most qualifications?
SELECT Position,
       COUNT(*) AS total_qualifications
FROM Qualification
GROUP BY Position
ORDER BY total_qualifications DESC
;


--  3.3 Which employees have the highest number of qualifications?
SELECT q.Emp_ID,
	   e.firstname, e.lastname,
       COUNT(*) AS qualification_count
FROM Qualification q
JOIN Employee e
	ON q.Emp_ID = e.Emp_ID
GROUP BY Emp_ID,e.firstname, e.lastname
ORDER BY qualification_count DESC;


-- ##4. LEAVE AND ABSENCE PATTERNS
-- 4.1 Which year had the most employees taking leaves?
SELECT YEAR(date) AS leave_year,
       COUNT(*) AS total_leaves
FROM Leaves
GROUP BY leave_year
ORDER BY total_leaves DESC;


-- 4.2 What is the average number of leave days taken by its employees per department?
SELECT 	jd.jobdept,
		ROUND(avg(emp_leave_count),2) AS avg_leaves
FROM (
		SELECT e.emp_id,
				e.job_id,
                COUNT(l.leave_id) AS emp_leave_count
		FROM employee e
        LEFT JOIN leaves l
			ON 	e.emp_id = l.emp_id
		GROUP BY e.emp_id, e.job_id) AS emp_leaves
JOIN jobdepartment jd
		ON emp_leaves.job_id = jd.job_id
GROUP BY jd.jobdept;


-- 4.3 Which employees have taken the most leaves?
SELECT e.emp_id,
		e.firstname,
		COUNT(l.leave_id) AS emp_leave_count
FROM employee e
LEFT JOIN leaves l
		ON 	e.emp_id = l.emp_id
GROUP BY e.emp_id, e.firstname
ORDER BY emp_leave_count DESC;


-- 4.4 What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;


-- 4.5 How do leave days correlate with payroll amounts?
SELECT e.emp_id,
       e.firstname,
       COUNT(l.leave_id) AS total_leave_days,
       SUM(p.total_amount) AS total_payroll
FROM Employee e
LEFT JOIN Leaves l USING (emp_id)
LEFT JOIN Payroll p USING (emp_id)
GROUP BY e.emp_id, e.firstname
ORDER BY total_leave_days DESC;


-- ##5. PAYROLL AND COMPENSATION ANALYSIS
-- 5.1 What is the total monthly payroll processed?
SELECT DATE_FORMAT(date, '%Y-%m') AS payroll_month,
       SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY payroll_month
ORDER BY payroll_month;


-- 5.2What is the average bonus given per department?
SELECT jd.jobdept, AVG(s.bonus) AS average_bonus_dept
FROM salarybonus s
JOIN jobdepartment jd
		ON s.job_id = jd.job_id
GROUP BY jd.jobdept
ORDER BY average_bonus_dept DESC;


-- 5.3 Which department receives the highest total bonuses?
SELECT jd.jobdept, SUM(s.bonus) AS total_bonus_dept
FROM salarybonus s
JOIN jobdepartment jd
USING(job_id)
GROUP BY jd.jobdept
ORDER BY total_bonus_dept DESC
LIMIT 1;


-- 5.4 What is the average value of total_amount after considering leave deductions?
SELECT e.emp_id,
       e.firstname,
       COUNT(l.leave_id) AS total_leave_days,
       ROUND(AVG(p.total_amount), 2) AS avg_payroll
FROM Employee e
LEFT JOIN Leaves l USING (emp_id)
LEFT JOIN Payroll p USING (emp_id)
GROUP BY e.emp_id, e.firstname;

