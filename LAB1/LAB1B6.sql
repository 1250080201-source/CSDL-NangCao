SELECT last_name, first_name, start_date
FROM s_emp
WHERE dept_id IN (SELECT dept_id FROM s_emp WHERE first_name = 'Lan')
  AND first_name != 'Lan';


SELECT id, last_name, first_name, userid
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp);


SELECT id, last_name, first_name
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp)
  AND (UPPER(first_name) LIKE '%L%'
   OR UPPER(last_name) LIKE '%L%');


SELECT c.name
FROM s_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM s_ord o
    WHERE o.customer_id = c.id
);