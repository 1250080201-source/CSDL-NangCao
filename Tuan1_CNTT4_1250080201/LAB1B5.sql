SELECT manager_id AS "Ma quan ly",
       COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY manager_id;


SELECT manager_id AS "Ma quan ly",
       COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING COUNT(id) >= 20;



SELECT r.id AS "Ma vung",
       r.name AS "Ten vung",
       COUNT(d.id) AS "So phong ban"
FROM s_region r, s_dept d
WHERE r.id = d.region_id
GROUP BY r.id, r.name
ORDER BY r.id;


SELECT c.name AS "Ten khach hang",
       COUNT(o.id) AS "So don dat hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.name;


SELECT c.name, COUNT(o.id) AS "So don hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING COUNT(o.id) = (
    SELECT MAX(COUNT(id))
    FROM s_ord
    GROUP BY customer_id
);


SELECT c.name, SUM(o.total) AS "Tong tien"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.total) = (
    SELECT MAX(SUM(total))
    FROM s_ord
    GROUP BY customer_id
);