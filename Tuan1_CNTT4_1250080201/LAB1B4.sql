SELECT p.name,
       p.id,
       i.quantity AS "ORDERED"
FROM s_product p, s_item i
WHERE p.id = i.product_id
  AND i.ord_id = 101;


SELECT c.id AS "Ma khach hang",
       o.id AS "Ma don hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id(+)
ORDER BY c.id;


SELECT o.customer_id,
       i.product_id,
       i.quantity
FROM s_ord o, s_item i
WHERE o.id = i.ord_id
  AND o.total > 100000;