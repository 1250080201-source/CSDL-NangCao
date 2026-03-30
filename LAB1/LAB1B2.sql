SELECT name AS "Ten khach hang",
       id AS "Ma khach hang"
FROM s_customer
ORDER BY id DESC;

SELECT first_name || ' ' || last_name AS "Employees",
       dept_id
FROM s_emp
WHERE dept_id IN (10, 50)
ORDER BY first_name;

SELECT last_name, first_name
FROM s_emp
WHERE first_name LIKE '%S%'
   OR last_name LIKE '%S%';
   
SELECT userid, start_date
FROM s_emp
WHERE start_date BETWEEN TO_DATE('14/05/1990', 'DD/MM/YYYY')
                     AND TO_DATE('26/05/1991', 'DD/MM/YYYY');
                     
SELECT last_name, salary
FROM s_emp
WHERE salary BETWEEN 1000 AND 2000;

SELECT last_name || ' ' || first_name AS "Employee Name",
       salary AS "Monthly Salary"
FROM s_emp
WHERE dept_id IN (31, 42, 50)
  AND salary > 1350;
  
SELECT last_name, start_date
FROM s_emp
WHERE TO_CHAR(start_date, 'YYYY') = '1991';

SELECT last_name, first_name
FROM s_emp
WHERE id NOT IN (SELECT DISTINCT manager_id
                 FROM s_emp
                 WHERE manager_id IS NOT NULL);
                 
SELECT name
FROM s_product
WHERE name LIKE 'Pro%'
ORDER BY name ASC;

SELECT name, short_desc
FROM s_product
WHERE LOWER(short_desc) LIKE '%bicycle%';

SELECT short_desc
FROM s_product;

SELECT last_name || ' ' || first_name || ' (' || title || ')' AS "Nhan vien"
FROM s_emp;