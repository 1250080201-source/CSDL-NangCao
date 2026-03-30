
SHOW USER;
SELECT table_name FROM all_tables WHERE owner = 'HOANGCONGTOAN';


CREATE TABLE s_region (
    id NUMBER(7) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL
);

CREATE TABLE s_title (
    title VARCHAR2(50) PRIMARY KEY
);

CREATE TABLE s_dept (
    id NUMBER(7) PRIMARY KEY,
    name VARCHAR2(25) NOT NULL,
    region_id NUMBER(7) REFERENCES s_region(id)
);

CREATE TABLE s_emp (
    id NUMBER(7) PRIMARY KEY,
    last_name VARCHAR2(25) NOT NULL,
    first_name VARCHAR2(25),
    userid VARCHAR2(8) UNIQUE,
    start_date DATE,
    comments VARCHAR2(255),
    manager_id NUMBER(7) REFERENCES s_emp(id),
    title VARCHAR2(50) REFERENCES s_title(title),
    dept_id NUMBER(7) REFERENCES s_dept(id),
    salary NUMBER(11,2),
    commission_pct NUMBER(4,2)
);

CREATE TABLE s_customer (
    id NUMBER(7) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    phone VARCHAR2(20),
    address VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    country VARCHAR2(50),
    zip_code VARCHAR2(20),
    credit_rating VARCHAR2(20),
    sales_rep_id NUMBER(7) REFERENCES s_emp(id),
    region_id NUMBER(7) REFERENCES s_region(id),
    comments VARCHAR2(255)
);

CREATE TABLE s_warehouse (
    id NUMBER(7) PRIMARY KEY,
    region_id NUMBER(7) REFERENCES s_region(id),
    address VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    country VARCHAR2(50),
    zip_code VARCHAR2(20),
    phone VARCHAR2(20),
    manager_id NUMBER(7) REFERENCES s_emp(id)
);

CREATE TABLE s_image (
    id NUMBER(7) PRIMARY KEY,
    format VARCHAR2(20),
    use_filename VARCHAR2(1),
    filename VARCHAR2(50),
    image BLOB
);

CREATE TABLE s_longtext (
    id NUMBER(7) PRIMARY KEY,
    use_filename VARCHAR2(1),
    filename VARCHAR2(50),
    text CLOB
);

CREATE TABLE s_product (
    id NUMBER(7) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    short_desc VARCHAR2(255),
    longtext_id NUMBER(7) REFERENCES s_longtext(id),
    image_id NUMBER(7) REFERENCES s_image(id),
    suggested_whlsl_price NUMBER(11,2),
    whlsl_units VARCHAR2(20)
);

CREATE TABLE s_ord (
    id NUMBER(7) PRIMARY KEY,
    customer_id NUMBER(7) REFERENCES s_customer(id),
    date_ordered DATE,
    date_shipped DATE,
    sales_rep_id NUMBER(7) REFERENCES s_emp(id),
    total NUMBER(11,2),
    payment_type VARCHAR2(20),
    order_filled VARCHAR2(1)
);

CREATE TABLE s_item (
    ord_id NUMBER(7) REFERENCES s_ord(id),
    item_id NUMBER(7),
    product_id NUMBER(7) REFERENCES s_product(id),
    price NUMBER(11,2),
    quantity NUMBER(7),
    quantity_shipped NUMBER(7),
    PRIMARY KEY (ord_id, item_id)
);

CREATE TABLE s_inventory (
    product_id NUMBER(7) REFERENCES s_product(id),
    warehouse_id NUMBER(7) REFERENCES s_warehouse(id),
    amount_in_stock NUMBER(7),
    reorder_point NUMBER(7),
    max_in_stock NUMBER(7),
    out_of_stock_explanation VARCHAR2(255),
    restock_date DATE,
    PRIMARY KEY (product_id, warehouse_id)
);

DESC s_emp;
DESC s_ord;


INSERT INTO s_region VALUES (1, 'North America');
INSERT INTO s_region VALUES (2, 'South America');
INSERT INTO s_region VALUES (3, 'Asia');
INSERT INTO s_region VALUES (4, 'Europe');
INSERT INTO s_region VALUES (5, 'Africa');
INSERT INTO s_region VALUES (6, 'Vietnam');
INSERT INTO s_region VALUES (7, 'Japan');
INSERT INTO s_region VALUES (8, 'South Korea');
INSERT INTO s_region VALUES (9, 'China');
INSERT INTO s_region VALUES (10, 'Singapore');
INSERT INTO s_region VALUES (11, 'Thailand');
INSERT INTO s_region VALUES (12, 'Malaysia');
INSERT INTO s_region VALUES (13, 'Indonesia');
INSERT INTO s_region VALUES (14, 'India');
INSERT INTO s_region VALUES (15, 'United States');
INSERT INTO s_region VALUES (16, 'Canada');
INSERT INTO s_region VALUES (17, 'United Kingdom');
INSERT INTO s_region VALUES (18, 'France');
INSERT INTO s_region VALUES (19, 'Germany');
INSERT INTO s_region VALUES (20, 'Australia');

INSERT INTO s_title VALUES ('President');
INSERT INTO s_title VALUES ('VP, Sales');
INSERT INTO s_title VALUES ('Sales Representative');
INSERT INTO s_title VALUES ('Stock Clerk');
INSERT INTO s_title VALUES ('Manager');
INSERT INTO s_title VALUES ('Director');
INSERT INTO s_title VALUES ('Accountant');
INSERT INTO s_title VALUES ('HR Specialist');
INSERT INTO s_title VALUES ('IT Support');
INSERT INTO s_title VALUES ('Software Engineer');
INSERT INTO s_title VALUES ('Data Analyst');
INSERT INTO s_title VALUES ('Marketing Executive');
INSERT INTO s_title VALUES ('Security Officer');
INSERT INTO s_title VALUES ('CEO');
INSERT INTO s_title VALUES ('CFO');
INSERT INTO s_title VALUES ('CTO');
INSERT INTO s_title VALUES ('CMO');
INSERT INTO s_title VALUES ('Intern');
INSERT INTO s_title VALUES ('Consultant');
INSERT INTO s_title VALUES ('Technician');

INSERT INTO s_dept VALUES (10, 'Finance', 1);
INSERT INTO s_dept VALUES (31, 'Sales US', 1);
INSERT INTO s_dept VALUES (42, 'Sales EU', 4);
INSERT INTO s_dept VALUES (50, 'Administration', 3);
INSERT INTO s_dept VALUES (101, 'IT Department', 6);
INSERT INTO s_dept VALUES (102, 'Marketing', 2);
INSERT INTO s_dept VALUES (103, 'Human Resources', 3);
INSERT INTO s_dept VALUES (104, 'Customer Support', 7);
INSERT INTO s_dept VALUES (105, 'R&D', 8);
INSERT INTO s_dept VALUES (106, 'Logistics', 9);
INSERT INTO s_dept VALUES (107, 'Legal', 10);
INSERT INTO s_dept VALUES (108, 'Production', 11);
INSERT INTO s_dept VALUES (109, 'Quality Assurance', 12);
INSERT INTO s_dept VALUES (110, 'Public Relations', 13);
INSERT INTO s_dept VALUES (111, 'Procurement', 14);
INSERT INTO s_dept VALUES (112, 'Operations', 15);
INSERT INTO s_dept VALUES (113, 'Business Dev', 16);
INSERT INTO s_dept VALUES (114, 'Design', 17);
INSERT INTO s_dept VALUES (115, 'Engineering', 18);
INSERT INTO s_dept VALUES (116, 'Training', 19);

INSERT INTO s_emp VALUES (1, 'Nguyen', 'Sếp Tổng', 'sep', TO_DATE('01/01/1985', 'DD/MM/YYYY'), 'Tốt', NULL, 'President', 10, 9000, NULL);
INSERT INTO s_emp VALUES (2, 'Tran', 'Lan', 'tlan', TO_DATE('14/05/1990', 'DD/MM/YYYY'), 'Tốt', 1, 'Sales Representative', 31, 1500, NULL);
INSERT INTO s_emp VALUES (3, 'Le', 'Son', 'lson', TO_DATE('15/10/1991', 'DD/MM/YYYY'), 'Tốt', 1, 'Stock Clerk', 50, 1400, NULL);
INSERT INTO s_emp VALUES (4, 'Smith', 'John', 'jsmith', TO_DATE('20/05/1991', 'DD/MM/YYYY'), 'Tốt', 1, 'Sales Representative', 42, 1600, NULL);
INSERT INTO s_emp VALUES (5, 'Hoang', 'Long', 'hlong', TO_DATE('15/05/1991', 'DD/MM/YYYY'), 'Tốt', 1, 'IT Support', 101, 1360, NULL);
INSERT INTO s_emp VALUES (6, 'Pham', 'Lan', 'plan', TO_DATE('01/01/1992', 'DD/MM/YYYY'), 'Tốt', 1, 'Accountant', 31, 1100, NULL);
INSERT INTO s_emp VALUES (7, 'Vu', 'Sang', 'vsang', TO_DATE('10/02/1991', 'DD/MM/YYYY'), 'Tốt', 1, 'Data Analyst', 50, 1200, NULL);
INSERT INTO s_emp VALUES (8, 'Do', 'Quyen', 'dquyen', TO_DATE('11/11/1990', 'DD/MM/YYYY'), 'Tốt', 1, 'HR Specialist', 103, 1450, NULL);
INSERT INTO s_emp VALUES (9, 'Bui', 'Tuan', 'btuan', TO_DATE('12/12/1991', 'DD/MM/YYYY'), 'Tốt', 1, 'Manager', 42, 1800, NULL);
INSERT INTO s_emp VALUES (10, 'Dang', 'Khoa', 'dkhoa', TO_DATE('13/01/1993', 'DD/MM/YYYY'), 'Tốt', 1, 'Director', 102, 2500, NULL);
INSERT INTO s_emp VALUES (11, 'Ngo', 'Bao', 'nbao', TO_DATE('14/02/1994', 'DD/MM/YYYY'), 'Tốt', 1, 'Intern', 101, 500, NULL);
INSERT INTO s_emp VALUES (12, 'Ly', 'Nam', 'lnam', TO_DATE('15/03/1995', 'DD/MM/YYYY'), 'Tốt', 1, 'Technician', 115, 1300, NULL);
INSERT INTO s_emp VALUES (13, 'Ho', 'Ngoc', 'hngoc', TO_DATE('16/04/1996', 'DD/MM/YYYY'), 'Tốt', 1, 'Marketing Executive', 102, 1700, NULL);
INSERT INTO s_emp VALUES (14, 'Duong', 'Qua', 'dqua', TO_DATE('17/05/1997', 'DD/MM/YYYY'), 'Tốt', 1, 'Security Officer', 50, 900, NULL);
INSERT INTO s_emp VALUES (15, 'Mai', 'Phuong', 'mphuong', TO_DATE('18/06/1998', 'DD/MM/YYYY'), 'Tốt', 1, 'Consultant', 113, 2100, NULL);
INSERT INTO s_emp VALUES (16, 'Dao', 'Ba', 'dba', TO_DATE('19/07/1999', 'DD/MM/YYYY'), 'Tốt', 1, 'Software Engineer', 101, 3000, NULL);
INSERT INTO s_emp VALUES (17, 'Phan', 'Dinh', 'pdinh', TO_DATE('20/08/2000', 'DD/MM/YYYY'), 'Tốt', 1, 'Sales Representative', 31, 1400, NULL);
INSERT INTO s_emp VALUES (18, 'Trinh', 'Xuan', 'txuan', TO_DATE('21/09/2001', 'DD/MM/YYYY'), 'Tốt', 1, 'Accountant', 10, 1500, NULL);
INSERT INTO s_emp VALUES (19, 'Dinh', 'Tien', 'dtien', TO_DATE('22/10/2002', 'DD/MM/YYYY'), 'Tốt', 1, 'HR Specialist', 103, 1600, NULL);
INSERT INTO s_emp VALUES (20, 'Lam', 'Xung', 'lxung', TO_DATE('23/11/2003', 'DD/MM/YYYY'), 'Tốt', 1, 'Technician', 106, 1200, NULL);
INSERT INTO s_emp VALUES (21, 'Chau', 'Tinh', 'ctinh', TO_DATE('24/12/2004', 'DD/MM/YYYY'), 'Tốt', 1, 'Stock Clerk', 108, 1100, NULL);
INSERT INTO s_emp VALUES (22, 'Vo', 'Song', 'vsong', TO_DATE('25/01/2005', 'DD/MM/YYYY'), 'Tốt', NULL, 'CEO', 10, 9999, NULL);

INSERT INTO s_product VALUES (1, 'Pro Max 15', 'Dien thoai cao cap', NULL, NULL, 1500, 'Cai');
INSERT INTO s_product VALUES (2, 'Probook HP 450', 'Laptop doanh nhan sieu ben', NULL, NULL, 800, 'Cai');
INSERT INTO s_product VALUES (3, 'Mountain Bike', 'Xe dap the thao bicycle dia hinh', NULL, NULL, 500, 'Chiec');
INSERT INTO s_product VALUES (4, 'Water skis', 'Van truot nuoc ski chuyen nghiep', NULL, NULL, 300, 'Cai');
INSERT INTO s_product VALUES (5, 'Snow ski boards', 'Van truot tuyet ski mua dong', NULL, NULL, 400, 'Cai');
INSERT INTO s_product VALUES (6, 'City bicycle', 'Xe dap bicycle di dao pho', NULL, NULL, 200, 'Chiec');
INSERT INTO s_product VALUES (7, 'Sony TV 65', 'Tivi man hinh phang', NULL, NULL, 1000, 'Cai');
INSERT INTO s_product VALUES (8, 'Samsung Fridge', 'Tu lanh inverter', NULL, NULL, 1200, 'Cai');
INSERT INTO s_product VALUES (9, 'Daikin AC', 'Dieu hoa nhiet do', NULL, NULL, 600, 'Cai');
INSERT INTO s_product VALUES (10, 'Canon EOS', 'May anh ky thuat so', NULL, NULL, 2000, 'Cai');
INSERT INTO s_product VALUES (11, 'Logitech Mouse', 'Chuot khong day', NULL, NULL, 50, 'Cai');
INSERT INTO s_product VALUES (12, 'Mechanical Keyboard', 'Ban phim co', NULL, NULL, 100, 'Cai');
INSERT INTO s_product VALUES (13, 'JBL Speaker', 'Loa bluetooth', NULL, NULL, 150, 'Cai');
INSERT INTO s_product VALUES (14, 'Airpods Pro', 'Tai nghe chong on', NULL, NULL, 250, 'Cai');
INSERT INTO s_product VALUES (15, 'Apple Watch', 'Dong ho thong minh', NULL, NULL, 400, 'Cai');
INSERT INTO s_product VALUES (16, 'Ipad Air', 'May tinh bang', NULL, NULL, 600, 'Cai');
INSERT INTO s_product VALUES (17, 'Nike Air Force', 'Giay the thao', NULL, NULL, 100, 'Doi');
INSERT INTO s_product VALUES (18, 'Adidas Ultraboost', 'Giay chay bo', NULL, NULL, 120, 'Doi');
INSERT INTO s_product VALUES (19, 'Rayban Glasses', 'Kinh mat thoi trang', NULL, NULL, 150, 'Cai');
INSERT INTO s_product VALUES (20, 'Casio G-Shock', 'Dong ho the thao', NULL, NULL, 200, 'Cai');

INSERT INTO s_customer VALUES (1, 'Cong Ty Dien Tu A', '0901234567', 'Q1, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Good', 2, 6, NULL);
INSERT INTO s_customer VALUES (2, 'Tap Doan Thuong Mai B', '0912345678', 'Ba Dinh, HN', 'Hanoi', 'HN', 'Vietnam', '100000', 'Excellent', 4, 6, NULL);
INSERT INTO s_customer VALUES (3, 'Cua Hang Ban Le C', '0923456789', 'Da Nang', 'Da Nang', 'DN', 'Vietnam', '500000', 'Good', 2, 6, NULL);
INSERT INTO s_customer VALUES (4, 'Global Tech LLC', '1234567890', 'NY City', 'New York', 'NY', 'USA', '10001', 'Excellent', 4, 15, NULL);
INSERT INTO s_customer VALUES (5, 'Samsung HQ', '0987654321', 'Seoul', 'Seoul', 'SE', 'South Korea', '01123', 'Good', 2, 8, NULL);
INSERT INTO s_customer VALUES (6, 'Sony Corp', '1122334455', 'Tokyo', 'Tokyo', 'TK', 'Japan', '100-0001', 'Excellent', 4, 7, NULL);
INSERT INTO s_customer VALUES (7, 'Vinamilk', '0283948576', 'Q7, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Good', 2, 6, NULL);
INSERT INTO s_customer VALUES (8, 'FPT Shop', '0243999888', 'Cau Giay, HN', 'Hanoi', 'HN', 'Vietnam', '100000', 'Good', 4, 6, NULL);
INSERT INTO s_customer VALUES (9, 'The Gioi Di Dong', '0281112223', 'Thu Duc, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Excellent', 2, 6, NULL);
INSERT INTO s_customer VALUES (10, 'Shopee', '0284445556', 'Q4, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Good', 4, 6, NULL);
INSERT INTO s_customer VALUES (11, 'Lazada', '0287778889', 'Q1, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Good', 2, 6, NULL);
INSERT INTO s_customer VALUES (12, 'Tiki', '0289990001', 'Tan Binh, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Excellent', 4, 6, NULL);
INSERT INTO s_customer VALUES (13, 'Amazon', '1999888777', 'Seattle', 'Washington', 'WA', 'USA', '98109', 'Excellent', 2, 15, NULL);
INSERT INTO s_customer VALUES (14, 'Alibaba', '8611122233', 'Hangzhou', 'Zhejiang', 'ZJ', 'China', '310000', 'Good', 4, 9, NULL);
INSERT INTO s_customer VALUES (15, 'Tencent', '8644455566', 'Shenzhen', 'Guangdong', 'GD', 'China', '518000', 'Good', 2, 9, NULL);
INSERT INTO s_customer VALUES (16, 'Grab', '6511122233', 'Cecil St', 'Singapore', 'SG', 'Singapore', '069547', 'Excellent', 4, 10, NULL);
INSERT INTO s_customer VALUES (17, 'Gojek', '6211122233', 'Jakarta', 'Jakarta', 'JK', 'Indonesia', '10110', 'Good', 2, 13, NULL);
INSERT INTO s_customer VALUES (18, 'VNG Corp', '0283334445', 'Q7, HCM', 'HCM', 'HCM', 'Vietnam', '700000', 'Good', 4, 6, NULL);
INSERT INTO s_customer VALUES (19, 'VNPAY', '0245556667', 'Dong Da, HN', 'Hanoi', 'HN', 'Vietnam', '100000', 'Excellent', 2, 6, NULL);
INSERT INTO s_customer VALUES (20, 'KHACH HANG Y (CHUA MUA GI)', '0900000000', 'Ca Mau', 'Ca Mau', 'CM', 'Vietnam', '900000', 'Poor', NULL, 6, 'KH nay khong co don hang');

INSERT INTO s_ord VALUES (101, 1, SYSDATE-10, SYSDATE-8, 2, 50000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (102, 2, SYSDATE-15, SYSDATE-10, 4, 150000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (103, 3, SYSDATE-20, SYSDATE-18, 2, 25000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (104, 4, SYSDATE-5, NULL, 4, 120000, 'Credit', 'N');
INSERT INTO s_ord VALUES (105, 5, SYSDATE-30, SYSDATE-28, 2, 80000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (106, 6, SYSDATE-40, SYSDATE-35, 4, 200000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (107, 7, SYSDATE-2, NULL, 2, 15000, 'Cash', 'N');
INSERT INTO s_ord VALUES (108, 8, SYSDATE-60, SYSDATE-55, 4, 300000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (109, 9, SYSDATE-12, SYSDATE-10, 2, 45000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (110, 10, SYSDATE-8, SYSDATE-6, 4, 110000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (111, 11, SYSDATE-25, SYSDATE-20, 2, 60000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (112, 12, SYSDATE-3, NULL, 4, 180000, 'Credit', 'N');
INSERT INTO s_ord VALUES (113, 13, SYSDATE-50, SYSDATE-45, 2, 90000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (114, 14, SYSDATE-18, SYSDATE-15, 4, 220000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (115, 15, SYSDATE-7, SYSDATE-5, 2, 35000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (116, 16, SYSDATE-1, NULL, 4, 130000, 'Credit', 'N');
INSERT INTO s_ord VALUES (117, 17, SYSDATE-22, SYSDATE-20, 2, 75000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (118, 18, SYSDATE-9, SYSDATE-7, 4, 160000, 'Credit', 'Y');
INSERT INTO s_ord VALUES (119, 19, SYSDATE-14, SYSDATE-12, 2, 40000, 'Cash', 'Y');
INSERT INTO s_ord VALUES (120, 1, SYSDATE-4, NULL, 4, 105000, 'Credit', 'N');

INSERT INTO s_item VALUES (101, 1, 1, 1500, 10, 10);
INSERT INTO s_item VALUES (101, 2, 3, 500, 5, 5);
INSERT INTO s_item VALUES (102, 1, 2, 800, 20, 20);
INSERT INTO s_item VALUES (103, 1, 4, 300, 2, 2);
INSERT INTO s_item VALUES (104, 1, 5, 400, 10, 0);
INSERT INTO s_item VALUES (105, 1, 6, 200, 5, 5);
INSERT INTO s_item VALUES (106, 1, 7, 1000, 15, 15);
INSERT INTO s_item VALUES (107, 1, 8, 1200, 1, 0);
INSERT INTO s_item VALUES (108, 1, 9, 600, 30, 30);
INSERT INTO s_item VALUES (109, 1, 10, 2000, 2, 2);
INSERT INTO s_item VALUES (110, 1, 11, 50, 50, 50);
INSERT INTO s_item VALUES (111, 1, 12, 100, 10, 10);
INSERT INTO s_item VALUES (112, 1, 13, 150, 20, 0);
INSERT INTO s_item VALUES (113, 1, 14, 250, 15, 15);
INSERT INTO s_item VALUES (114, 1, 15, 400, 25, 25);
INSERT INTO s_item VALUES (115, 1, 16, 600, 3, 3);
INSERT INTO s_item VALUES (116, 1, 17, 100, 40, 0);
INSERT INTO s_item VALUES (117, 1, 18, 120, 12, 12);
INSERT INTO s_item VALUES (118, 1, 19, 150, 30, 30);
INSERT INTO s_item VALUES (119, 1, 20, 200, 5, 5);
INSERT INTO s_item VALUES (120, 1, 1, 1500, 8, 0);

COMMIT;