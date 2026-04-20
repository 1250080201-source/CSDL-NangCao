

CREATE TABLE phongban (
    maphg NUMBER(2) PRIMARY KEY,
    tenphg NVARCHAR2(30),
    trphg VARCHAR2(5), 
    ng_nhanchuc DATE
);

CREATE TABLE nhanvien (
    manv VARCHAR2(5) PRIMARY KEY,
    honv NVARCHAR2(15),
    tenlot NVARCHAR2(15),
    tennv NVARCHAR2(15),
    ngsinh DATE,
    dchi NVARCHAR2(50),
    phai NVARCHAR2(3),
    luong NUMBER(10),
    ma_nql VARCHAR2(5),
    phg NUMBER(2),
    CONSTRAINT fk_nv_phg FOREIGN KEY (phg) REFERENCES phongban(maphg),
    CONSTRAINT fk_nv_nql FOREIGN KEY (ma_nql) REFERENCES nhanvien(manv)
);

ALTER TABLE phongban ADD CONSTRAINT fk_phg_nv FOREIGN KEY (trphg) REFERENCES nhanvien(manv);

CREATE TABLE diadiem_phg (
    maphg NUMBER(2),
    diadiem NVARCHAR2(30),
    CONSTRAINT pk_diadiem_phg PRIMARY KEY (maphg, diadiem),
    CONSTRAINT fk_diadiem_phg FOREIGN KEY (maphg) REFERENCES phongban(maphg)
);

CREATE TABLE dean (
    mada NUMBER(3) PRIMARY KEY,
    tenda NVARCHAR2(50),
    ddiem_da NVARCHAR2(30),
    phong NUMBER(2),
    CONSTRAINT fk_dean_phg FOREIGN KEY (phong) REFERENCES phongban(maphg)
);

CREATE TABLE phancong (
    ma_nvien VARCHAR2(5),
    mada NUMBER(3),
    thoigian NUMBER(5,1),
    CONSTRAINT pk_phancong PRIMARY KEY (ma_nvien, mada),
    CONSTRAINT fk_pc_nv FOREIGN KEY (ma_nvien) REFERENCES nhanvien(manv),
    CONSTRAINT fk_pc_da FOREIGN KEY (mada) REFERENCES dean(mada)
);

CREATE TABLE thannhan (
    ma_nvien VARCHAR2(5),
    tentn NVARCHAR2(15),
    phai NVARCHAR2(3),
    ngsinh DATE,
    quanhe NVARCHAR2(15),
    CONSTRAINT pk_thannhan PRIMARY KEY (ma_nvien, tentn),
    CONSTRAINT fk_tn_nv FOREIGN KEY (ma_nvien) REFERENCES nhanvien(manv)
);



INSERT INTO phongban VALUES (1, N'Nghiên cứu', NULL, TO_DATE('22/05/2018','DD/MM/YYYY'));
INSERT INTO phongban VALUES (2, N'Sản xuất 1', NULL, TO_DATE('01/01/2015','DD/MM/YYYY'));
INSERT INTO phongban VALUES (3, N'Sản xuất 2', NULL, TO_DATE('19/06/2019','DD/MM/YYYY'));
INSERT INTO phongban VALUES (4, N'Điều hành', NULL, TO_DATE('01/01/2020','DD/MM/YYYY'));
INSERT INTO phongban VALUES (5, N'Quản lý', NULL, TO_DATE('01/01/2021','DD/MM/YYYY'));
INSERT INTO phongban VALUES (6, N'IT', NULL, TO_DATE('15/05/2018','DD/MM/YYYY'));
INSERT INTO phongban VALUES (7, N'Kế toán', NULL, TO_DATE('10/10/2016','DD/MM/YYYY'));
INSERT INTO phongban VALUES (8, N'Nhân sự', NULL, TO_DATE('12/12/2017','DD/MM/YYYY'));
INSERT INTO phongban VALUES (9, N'Marketing', NULL, TO_DATE('05/09/2019','DD/MM/YYYY'));
INSERT INTO phongban VALUES (10, N'Bán hàng', NULL, TO_DATE('20/11/2020','DD/MM/YYYY'));
INSERT INTO phongban VALUES (11, N'Hỗ trợ khách hàng', NULL, TO_DATE('02/02/2021','DD/MM/YYYY'));
INSERT INTO phongban VALUES (12, N'Vận chuyển', NULL, TO_DATE('14/04/2015','DD/MM/YYYY'));
INSERT INTO phongban VALUES (13, N'Kho bãi', NULL, TO_DATE('28/08/2016','DD/MM/YYYY'));
INSERT INTO phongban VALUES (14, N'Pháp lý', NULL, TO_DATE('09/09/2018','DD/MM/YYYY'));
INSERT INTO phongban VALUES (15, N'Thiết kế', NULL, TO_DATE('17/07/2019','DD/MM/YYYY'));
INSERT INTO phongban VALUES (16, N'Đào tạo', NULL, TO_DATE('25/12/2020','DD/MM/YYYY'));
INSERT INTO phongban VALUES (17, N'Bảo trì', NULL, TO_DATE('30/04/2017','DD/MM/YYYY'));
INSERT INTO phongban VALUES (18, N'Kiểm tra chất lượng', NULL, TO_DATE('01/05/2018','DD/MM/YYYY'));
INSERT INTO phongban VALUES (19, N'Mua sắm', NULL, TO_DATE('02/09/2019','DD/MM/YYYY'));
INSERT INTO phongban VALUES (20, N'Đối ngoại', NULL, TO_DATE('10/10/2022','DD/MM/YYYY'));

INSERT INTO nhanvien VALUES ('NV001', N'Nguyễn', N'Thanh', N'Tùng', TO_DATE('20/08/1980','DD/MM/YYYY'), N'TP HCM', N'Nam', 50000, NULL, 4);
INSERT INTO nhanvien VALUES ('NV002', N'Lê', N'Thị', N'Hương', TO_DATE('15/01/1985','DD/MM/YYYY'), N'Hà Nội', N'Nữ', 30000, 'NV001', 5);
INSERT INTO nhanvien VALUES ('NV003', N'Trần', N'Văn', N'Bình', TO_DATE('22/10/1990','DD/MM/YYYY'), N'Đà Nẵng', N'Nam', 25000, 'NV002', 1);
INSERT INTO nhanvien VALUES ('NV004', N'Phạm', N'Thị', N'Mai', TO_DATE('05/05/1995','DD/MM/YYYY'), N'Cần Thơ', N'Nữ', 15000, 'NV002', 6);
INSERT INTO nhanvien VALUES ('NV005', N'Hoàng', N'Văn', N'Nam', TO_DATE('12/12/1992','DD/MM/YYYY'), N'Huế', N'Nam', 18000, 'NV001', 7);
INSERT INTO nhanvien VALUES ('NV006', N'Đinh', N'Trọng', N'Khánh', TO_DATE('18/03/1988','DD/MM/YYYY'), N'Hải Phòng', N'Nam', 22000, 'NV003', 2);
INSERT INTO nhanvien VALUES ('NV007', N'Vũ', N'Thị', N'Hà', TO_DATE('25/07/1994','DD/MM/YYYY'), N'Nha Trang', N'Nữ', 14000, 'NV003', 3);
INSERT INTO nhanvien VALUES ('NV008', N'Lý', N'Gia', N'Thành', TO_DATE('08/08/1982','DD/MM/YYYY'), N'Đồng Nai', N'Nam', 28000, 'NV001', 8);
INSERT INTO nhanvien VALUES ('NV009', N'Bùi', N'Quang', N'Đại', TO_DATE('14/02/1991','DD/MM/YYYY'), N'Bình Dương', N'Nam', 16000, 'NV008', 9);
INSERT INTO nhanvien VALUES ('NV010', N'Châu', N'Thị', N'Mỹ', TO_DATE('19/09/1996','DD/MM/YYYY'), N'Vũng Tàu', N'Nữ', 13000, 'NV008', 10);
INSERT INTO nhanvien VALUES ('NV011', N'Trịnh', N'Văn', N'Quyết', TO_DATE('30/04/1986','DD/MM/YYYY'), N'Thanh Hóa', N'Nam', 26000, 'NV002', 11);
INSERT INTO nhanvien VALUES ('NV012', N'Mai', N'Thị', N'Hoa', TO_DATE('02/09/1993','DD/MM/YYYY'), N'Nghệ An', N'Nữ', 15000, 'NV011', 12);
INSERT INTO nhanvien VALUES ('NV013', N'Đoàn', N'Dự', N'Châu', TO_DATE('11/11/1989','DD/MM/YYYY'), N'Hà Tĩnh', N'Nam', 21000, 'NV011', 13);
INSERT INTO nhanvien VALUES ('NV014', N'Phan', N'Mạnh', N'Quỳnh', TO_DATE('20/10/1990','DD/MM/YYYY'), N'Quảng Bình', N'Nam', 19000, 'NV002', 14);
INSERT INTO nhanvien VALUES ('NV015', N'Ngô', N'Thị', N'Bích', TO_DATE('01/06/1997','DD/MM/YYYY'), N'Quảng Trị', N'Nữ', 12000, 'NV014', 15);
INSERT INTO nhanvien VALUES ('NV016', N'Tô', N'Chấn', N'Phong', TO_DATE('15/12/1984','DD/MM/YYYY'), N'Quy Nhơn', N'Nam', 27000, 'NV001', 16);
INSERT INTO nhanvien VALUES ('NV017', N'Hồ', N'Thị', N'Ngọc', TO_DATE('08/03/1998','DD/MM/YYYY'), N'Đà Lạt', N'Nữ', 11000, 'NV016', 17);
INSERT INTO nhanvien VALUES ('NV018', N'Cao', N'Thái', N'Sơn', TO_DATE('22/07/1987','DD/MM/YYYY'), N'Phan Thiết', N'Nam', 23000, 'NV016', 18);
INSERT INTO nhanvien VALUES ('NV019', N'Đào', N'Bá', N'Lộc', TO_DATE('14/05/1992','DD/MM/YYYY'), N'Bến Tre', N'Nam', 17000, 'NV003', 19);
INSERT INTO nhanvien VALUES ('NV020', N'Lương', N'Bích', N'Hữu', TO_DATE('09/09/1995','DD/MM/YYYY'), N'Tiền Giang', N'Nữ', 14500, 'NV003', 20);

UPDATE phongban SET trphg = 'NV003' WHERE maphg = 1;
UPDATE phongban SET trphg = 'NV006' WHERE maphg = 2;
UPDATE phongban SET trphg = 'NV007' WHERE maphg = 3;
UPDATE phongban SET trphg = 'NV001' WHERE maphg = 4;
UPDATE phongban SET trphg = 'NV002' WHERE maphg = 5;
UPDATE phongban SET trphg = 'NV004' WHERE maphg = 6;
UPDATE phongban SET trphg = 'NV005' WHERE maphg = 7;
UPDATE phongban SET trphg = 'NV008' WHERE maphg = 8;
UPDATE phongban SET trphg = 'NV009' WHERE maphg = 9;
UPDATE phongban SET trphg = 'NV010' WHERE maphg = 10;
UPDATE phongban SET trphg = 'NV011' WHERE maphg = 11;
UPDATE phongban SET trphg = 'NV012' WHERE maphg = 12;
UPDATE phongban SET trphg = 'NV013' WHERE maphg = 13;
UPDATE phongban SET trphg = 'NV014' WHERE maphg = 14;
UPDATE phongban SET trphg = 'NV015' WHERE maphg = 15;
UPDATE phongban SET trphg = 'NV016' WHERE maphg = 16;
UPDATE phongban SET trphg = 'NV017' WHERE maphg = 17;
UPDATE phongban SET trphg = 'NV018' WHERE maphg = 18;
UPDATE phongban SET trphg = 'NV019' WHERE maphg = 19;
UPDATE phongban SET trphg = 'NV020' WHERE maphg = 20;

INSERT INTO diadiem_phg VALUES (1, N'Hà Nội');
INSERT INTO diadiem_phg VALUES (2, N'Hải Phòng');
INSERT INTO diadiem_phg VALUES (3, N'Bắc Ninh');
INSERT INTO diadiem_phg VALUES (4, N'TP HCM');
INSERT INTO diadiem_phg VALUES (5, N'Đà Nẵng');
INSERT INTO diadiem_phg VALUES (6, N'Cần Thơ');
INSERT INTO diadiem_phg VALUES (7, N'Huế');
INSERT INTO diadiem_phg VALUES (8, N'Đồng Nai');
INSERT INTO diadiem_phg VALUES (9, N'Bình Dương');
INSERT INTO diadiem_phg VALUES (10, N'Vũng Tàu');
INSERT INTO diadiem_phg VALUES (11, N'Thanh Hóa');
INSERT INTO diadiem_phg VALUES (12, N'Nghệ An');
INSERT INTO diadiem_phg VALUES (13, N'Hà Tĩnh');
INSERT INTO diadiem_phg VALUES (14, N'Quảng Bình');
INSERT INTO diadiem_phg VALUES (15, N'Quảng Trị');
INSERT INTO diadiem_phg VALUES (16, N'Quy Nhơn');
INSERT INTO diadiem_phg VALUES (17, N'Đà Lạt');
INSERT INTO diadiem_phg VALUES (18, N'Phan Thiết');
INSERT INTO diadiem_phg VALUES (19, N'Bến Tre');
INSERT INTO diadiem_phg VALUES (20, N'Tiền Giang');

INSERT INTO dean VALUES (101, N'Sản phẩm X', N'Vũng Tàu', 5);
INSERT INTO dean VALUES (102, N'Sản phẩm Y', N'Nha Trang', 1);
INSERT INTO dean VALUES (103, N'Sản phẩm Z', N'TP HCM', 5);
INSERT INTO dean VALUES (104, N'Tin học hóa', N'Hà Nội', 6);
INSERT INTO dean VALUES (105, N'Kế toán số', N'Đà Nẵng', 7);
INSERT INTO dean VALUES (106, N'Mở rộng Cần Thơ', N'Cần Thơ', 10);
INSERT INTO dean VALUES (107, N'Marketing Q3', N'Bình Dương', 9);
INSERT INTO dean VALUES (108, N'Tuyển dụng 2026', N'Đồng Nai', 8);
INSERT INTO dean VALUES (109, N'Bảo trì máy móc', N'Hải Phòng', 17);
INSERT INTO dean VALUES (110, N'Kiểm định ISO', N'Bắc Ninh', 18);
INSERT INTO dean VALUES (111, N'Nâng cấp hạ tầng', N'Hà Nội', 6);
INSERT INTO dean VALUES (112, N'Thiết kế bao bì', N'Quảng Trị', 15);
INSERT INTO dean VALUES (113, N'Tối ưu kho bãi', N'Hà Tĩnh', 13);
INSERT INTO dean VALUES (114, N'Giao hàng nhanh', N'Nghệ An', 12);
INSERT INTO dean VALUES (115, N'Chăm sóc KH', N'Thanh Hóa', 11);
INSERT INTO dean VALUES (116, N'Pháp lý hợp đồng', N'Quảng Bình', 14);
INSERT INTO dean VALUES (117, N'Đào tạo nội bộ', N'Quy Nhơn', 16);
INSERT INTO dean VALUES (118, N'Cung ứng vật tư', N'Bến Tre', 19);
INSERT INTO dean VALUES (119, N'Hợp tác quốc tế', N'Tiền Giang', 20);
INSERT INTO dean VALUES (120, N'Nghiên cứu thị trường', N'Đà Lạt', 1);

INSERT INTO phancong VALUES ('NV001', 103, 20.5);
INSERT INTO phancong VALUES ('NV002', 101, 15.0);
INSERT INTO phancong VALUES ('NV003', 102, 30.0);
INSERT INTO phancong VALUES ('NV004', 104, 40.0);
INSERT INTO phancong VALUES ('NV005', 105, 25.5);
INSERT INTO phancong VALUES ('NV006', 109, 10.0);
INSERT INTO phancong VALUES ('NV007', 110, 15.0);
INSERT INTO phancong VALUES ('NV008', 108, 20.0);
INSERT INTO phancong VALUES ('NV009', 107, 35.0);
INSERT INTO phancong VALUES ('NV010', 106, 40.0);
INSERT INTO phancong VALUES ('NV011', 115, 25.0);
INSERT INTO phancong VALUES ('NV012', 114, 30.0);
INSERT INTO phancong VALUES ('NV013', 113, 10.0);
INSERT INTO phancong VALUES ('NV014', 116, 15.0);
INSERT INTO phancong VALUES ('NV015', 112, 20.0);
INSERT INTO phancong VALUES ('NV016', 117, 35.0);
INSERT INTO phancong VALUES ('NV017', 109, 25.0);
INSERT INTO phancong VALUES ('NV018', 110, 30.0);
INSERT INTO phancong VALUES ('NV019', 118, 10.0);
INSERT INTO phancong VALUES ('NV020', 119, 15.0);

INSERT INTO thannhan VALUES ('NV001', N'Lan', N'Nữ', TO_DATE('15/04/2010','DD/MM/YYYY'), N'Con gái');
INSERT INTO thannhan VALUES ('NV002', N'Nam', N'Nam', TO_DATE('20/08/2015','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV003', N'Hoa', N'Nữ', TO_DATE('01/01/1992','DD/MM/YYYY'), N'Vợ');
INSERT INTO thannhan VALUES ('NV004', N'Minh', N'Nam', TO_DATE('10/10/2020','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV005', N'Hồng', N'Nữ', TO_DATE('05/05/1995','DD/MM/YYYY'), N'Vợ');
INSERT INTO thannhan VALUES ('NV006', N'Khang', N'Nam', TO_DATE('12/12/2018','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV007', N'Hương', N'Nữ', TO_DATE('08/08/1965','DD/MM/YYYY'), N'Mẹ');
INSERT INTO thannhan VALUES ('NV008', N'Thảo', N'Nữ', TO_DATE('15/09/2012','DD/MM/YYYY'), N'Con gái');
INSERT INTO thannhan VALUES ('NV009', N'Phong', N'Nam', TO_DATE('22/11/1960','DD/MM/YYYY'), N'Bố');
INSERT INTO thannhan VALUES ('NV010', N'Linh', N'Nữ', TO_DATE('14/02/2022','DD/MM/YYYY'), N'Con gái');
INSERT INTO thannhan VALUES ('NV011', N'Quang', N'Nam', TO_DATE('30/04/2015','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV012', N'Mai', N'Nữ', TO_DATE('02/09/1962','DD/MM/YYYY'), N'Mẹ');
INSERT INTO thannhan VALUES ('NV013', N'Cường', N'Nam', TO_DATE('11/11/2016','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV014', N'Trang', N'Nữ', TO_DATE('20/10/1992','DD/MM/YYYY'), N'Vợ');
INSERT INTO thannhan VALUES ('NV015', N'An', N'Nam', TO_DATE('01/06/2021','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV016', N'Bình', N'Nam', TO_DATE('15/12/1958','DD/MM/YYYY'), N'Bố');
INSERT INTO thannhan VALUES ('NV017', N'Ngân', N'Nữ', TO_DATE('08/03/1970','DD/MM/YYYY'), N'Mẹ');
INSERT INTO thannhan VALUES ('NV018', N'Tú', N'Nam', TO_DATE('22/07/2019','DD/MM/YYYY'), N'Con trai');
INSERT INTO thannhan VALUES ('NV019', N'Ly', N'Nữ', TO_DATE('14/05/2020','DD/MM/YYYY'), N'Con gái');
INSERT INTO thannhan VALUES ('NV020', N'Khoa', N'Nam', TO_DATE('09/09/1965','DD/MM/YYYY'), N'Bố');

COMMIT;