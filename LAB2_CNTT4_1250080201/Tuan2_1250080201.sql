-- 1
SELECT last_name, salary 
FROM employees 
WHERE salary > 12000;

-- 2
SELECT last_name, salary 
FROM employees 
WHERE salary < 5000 OR salary > 12000;

-- 3
SELECT last_name, job_id, hire_date 
FROM employees 
WHERE hire_date BETWEEN TO_DATE('20/02/1998','DD/MM/YYYY') AND TO_DATE('01/05/1998', 'DD/MM/YYYY') 
ORDER BY hire_date ASC;

-- 4
SELECT last_name, department_id 
FROM employees 
WHERE department_id IN (20, 50) 
ORDER BY last_name ASC;

-- 5
SELECT last_name, hire_date 
FROM employees 
WHERE TO_CHAR(hire_date, 'YYYY') = '1994';

-- 6
SELECT last_name, job_id 
FROM employees 
WHERE manager_id IS NULL;

-- 7
SELECT last_name, salary, commission_pct 
FROM employees 
WHERE commission_pct IS NOT NULL 
ORDER BY salary DESC, commission_pct DESC;

-- 8
SELECT last_name 
FROM employees 
WHERE last_name LIKE '__a%';

-- 9
SELECT last_name 
FROM employees 
WHERE last_name LIKE '%a%' AND last_name LIKE '%e%';

-- 10
SELECT last_name, job_id, salary 
FROM employees 
WHERE job_id IN ('SA_REP', 'ST_CLERK') 
AND salary NOT IN (2500, 3500, 7000);

-- 11
SELECT employee_id, last_name, ROUND(salary * 1.15, 0) AS "New Salary" 
FROM employees;

-- 12
SELECT INITCAP(last_name) AS "Ten Nhan Vien", LENGTH(last_name) AS "Chieu Dai" 
FROM employees 
WHERE SUBSTR(last_name, 1, 1) IN ('J', 'A', 'L', 'M') 
ORDER BY last_name ASC;

-- 13
SELECT last_name, TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)) AS "So Thang Lam Viec" 
FROM employees 
ORDER BY MONTHS_BETWEEN(SYSDATE, hire_date) ASC;

-- 14
SELECT last_name || ' earns ' || TO_CHAR(salary, '$99,999') || ' monthly but wants ' || TO_CHAR(salary*3, '$99,999') AS "Dream Salaries" 
FROM employees;

-- 15
SELECT last_name, NVL(TO_CHAR(commission_pct), 'No commission') AS "Commission" 
FROM employees;

-- 16
SELECT job_id, 
       DECODE(job_id, 'AD_PRES', 'A', 'ST_MAN', 'B', 'IT_PROG', 'C', 'SA_REP', 'D', 'ST_CLERK', 'E', '0') AS "GRADE" 
FROM employees;

-- 17
SELECT e.last_name, e.department_id, d.department_name 
FROM employees e, departments d, locations l 
WHERE e.department_id = d.department_id 
  AND d.location_id = l.location_id 
  AND UPPER(l.city) = 'TORONTO';

-- 18
SELECT e.employee_id AS "Ma NV", e.last_name AS "Ten NV", 
       m.employee_id AS "Ma Quan Ly", m.last_name AS "Ten Quan Ly" 
FROM employees e, employees m 
WHERE e.manager_id = m.employee_id;

-- 19
SELECT e1.last_name AS "Nhan Vien 1", e2.last_name AS "Nhan Vien 2", e1.department_id AS "Phong Ban" 
FROM employees e1, employees e2 
WHERE e1.department_id = e2.department_id 
  AND e1.employee_id < e2.employee_id 
ORDER BY e1.department_id, e1.last_name;

-- 20
SELECT last_name, hire_date 
FROM employees 
WHERE hire_date > (SELECT hire_date FROM employees WHERE last_name = 'Davies');

-- 21
SELECT e.last_name AS "Nhan Vien", e.hire_date AS "Ngay Vao", 
       m.last_name AS "Quan Ly", m.hire_date AS "Quan Ly Vao" 
FROM employees e, employees m 
WHERE e.manager_id = m.employee_id 
  AND e.hire_date < m.hire_date;

-- 22
SELECT job_id, MIN(salary) AS "Luong Thap Nhat", MAX(salary) AS "Luong Cao Nhat", 
       ROUND(AVG(salary), 2) AS "Luong Trung Binh", SUM(salary) AS "Tong Luong" 
FROM employees 
GROUP BY job_id 
ORDER BY job_id;

-- 23
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS "So Nhan Vien" 
FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id 
GROUP BY d.department_id, d.department_name 
ORDER BY d.department_id;

-- 24
SELECT COUNT(*) AS "Tong NV", 
       SUM(CASE WHEN TO_CHAR(hire_date, 'YYYY') = '1995' THEN 1 ELSE 0 END) AS "Nam 1995", 
       SUM(CASE WHEN TO_CHAR(hire_date, 'YYYY') = '1996' THEN 1 ELSE 0 END) AS "Nam 1996", 
       SUM(CASE WHEN TO_CHAR(hire_date, 'YYYY') = '1997' THEN 1 ELSE 0 END) AS "Nam 1997", 
       SUM(CASE WHEN TO_CHAR(hire_date, 'YYYY') = '1998' THEN 1 ELSE 0 END) AS "Nam 1998" 
FROM employees;

-- 25
SELECT last_name, hire_date 
FROM employees 
WHERE department_id = (SELECT department_id FROM employees WHERE last_name = 'Zlotkey') 
  AND last_name <> 'Zlotkey';

-- 26
SELECT last_name, department_id, job_id 
FROM employees 
WHERE department_id IN (SELECT department_id FROM departments WHERE location_id = 1700);

-- 27
SELECT last_name, manager_id 
FROM employees 
WHERE manager_id IN (SELECT employee_id FROM employees WHERE last_name = 'King');

-- 28
SELECT last_name, salary, department_id 
FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees) 
  AND department_id IN (SELECT department_id FROM employees WHERE last_name LIKE '%n');

-- 29
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS "SO NV" 
FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id 
GROUP BY d.department_id, d.department_name 
HAVING COUNT(e.employee_id) < 3 
ORDER BY d.department_id;

-- 30
SELECT department_id, COUNT(*) AS "So Nhan Vien", 'Dong nhat' AS "Loai" 
FROM employees 
GROUP BY department_id 
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM employees GROUP BY department_id) 
UNION ALL 
SELECT department_id, COUNT(*), 'It nhat' 
FROM employees 
GROUP BY department_id 
HAVING COUNT(*) = (SELECT MIN(COUNT(*)) FROM employees GROUP BY department_id);

-- 31
SELECT last_name, hire_date, TO_CHAR(hire_date, 'Day') AS "Thu trong tuan" 
FROM employees 
WHERE TO_CHAR(hire_date, 'Day') = (
    SELECT TO_CHAR(hire_date, 'Day') 
    FROM employees 
    GROUP BY TO_CHAR(hire_date, 'Day') 
    HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM employees GROUP BY TO_CHAR(hire_date, 'Day'))
);

-- 32
SELECT last_name, salary 
FROM (SELECT last_name, salary FROM employees ORDER BY salary DESC) 
WHERE ROWNUM <= 3;

-- 33
SELECT e.last_name, e.department_id 
FROM employees e, departments d, locations l 
WHERE e.department_id = d.department_id 
  AND d.location_id = l.location_id 
  AND UPPER(l.state_province) = 'CALIFORNIA';

-- 34
UPDATE employees SET last_name = 'Drexler' WHERE employee_id = 3;
COMMIT;

-- 35
SELECT e1.last_name, e1.salary, e1.department_id 
FROM employees e1 
WHERE e1.salary < (SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id) 
ORDER BY e1.department_id;

-- 36
UPDATE employees SET salary = salary + 100 WHERE salary < 900;
COMMIT;

-- 37
DELETE FROM departments WHERE department_id = 500;
COMMIT;

-- 38
DELETE FROM departments d 
WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.department_id = d.department_id);
COMMIT;