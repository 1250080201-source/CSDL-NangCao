SELECT id,
       last_name,
       ROUND(salary * 1.15, 2) AS "Luong moi"
FROM s_emp;

SELECT last_name,
       start_date,
       TO_CHAR(
           NEXT_DAY(ADD_MONTHS(start_date, 6), 'MONDAY'),
           'Ddspth "of" Month YYYY'
       ) AS "Ngay xet tang luong"
FROM s_emp;

SELECT name
FROM s_product
WHERE LOWER(name) LIKE '%ski%';


SELECT last_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, start_date)) AS "So thang tham nien"
FROM s_emp
ORDER BY MONTHS_BETWEEN(SYSDATE, start_date) ASC;


SELECT COUNT(DISTINCT manager_id) AS "So nguoi quan ly"
FROM s_emp
WHERE manager_id IS NOT NULL;


SELECT MAX(total) AS "Highest",
       MIN(total) AS "Lowest"
FROM s_ord;