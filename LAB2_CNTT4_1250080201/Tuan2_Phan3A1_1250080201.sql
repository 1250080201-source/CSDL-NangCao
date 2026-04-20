
CREATE TABLE dmkhoa (
    makhoa CHAR(2) PRIMARY KEY,
    tenkhoa NVARCHAR2(30)
);

CREATE TABLE dmmh (
    mamh CHAR(2) PRIMARY KEY,
    tenmh NVARCHAR2(35),
    sotiet NUMBER(3)
);

CREATE TABLE dmsv (
    masv CHAR(3) PRIMARY KEY,
    hosv NVARCHAR2(30),
    tensv NVARCHAR2(10),
    phai NVARCHAR2(3),
    ngaysinh DATE,
    noisinh NVARCHAR2(25),
    makh CHAR(2),
    hocbong NUMBER(10,0),
    CONSTRAINT fk_dmsv_khoa FOREIGN KEY (makh) REFERENCES dmkhoa(makhoa)
);

CREATE TABLE ketqua (
    masv CHAR(3),
    mamh CHAR(2),
    diem NUMBER(4,2), 
    CONSTRAINT pk_ketqua PRIMARY KEY (masv, mamh),
    CONSTRAINT fk_kq_sv FOREIGN KEY (masv) REFERENCES dmsv(masv),
    CONSTRAINT fk_kq_mh FOREIGN KEY (mamh) REFERENCES dmmh(mamh)
);


INSERT INTO dmkhoa VALUES ('CN', N'Công nghệ thông tin');
INSERT INTO dmkhoa VALUES ('KT', N'Kế toán - Kiểm toán');
INSERT INTO dmkhoa VALUES ('QT', N'Quản trị kinh doanh');
INSERT INTO dmkhoa VALUES ('NN', N'Ngoại ngữ');
INSERT INTO dmkhoa VALUES ('DT', N'Điện tử viễn thông');
INSERT INTO dmkhoa VALUES ('XD', N'Kỹ thuật Xây dựng');
INSERT INTO dmkhoa VALUES ('CK', N'Cơ khí chế tạo máy');
INSERT INTO dmkhoa VALUES ('SH', N'Công nghệ Sinh học');
INSERT INTO dmkhoa VALUES ('MT', N'Kỹ thuật Môi trường');
INSERT INTO dmkhoa VALUES ('TO', N'Toán tin ứng dụng');
INSERT INTO dmkhoa VALUES ('VL', N'Vật lý kỹ thuật');
INSERT INTO dmkhoa VALUES ('HH', N'Công nghệ Hóa học');
INSERT INTO dmkhoa VALUES ('DL', N'Quản trị Du lịch');
INSERT INTO dmkhoa VALUES ('LS', N'Lịch sử học');
INSERT INTO dmkhoa VALUES ('VH', N'Văn hóa học');
INSERT INTO dmkhoa VALUES ('TH', N'Triết học');
INSERT INTO dmkhoa VALUES ('YD', N'Y Dược');
INSERT INTO dmkhoa VALUES ('DP', N'Sư phạm');
INSERT INTO dmkhoa VALUES ('NH', N'Tài chính Ngân hàng');
INSERT INTO dmkhoa VALUES ('TC', N'Toán cơ');

INSERT INTO dmmh VALUES ('M1', N'Cơ sở dữ liệu', 45);
INSERT INTO dmmh VALUES ('M2', N'Mạng máy tính', 45);
INSERT INTO dmmh VALUES ('M3', N'Nguyên lý kế toán', 60);
INSERT INTO dmmh VALUES ('M4', N'Marketing căn bản', 45);
INSERT INTO dmmh VALUES ('M5', N'Tiếng Anh giao tiếp', 30);
INSERT INTO dmmh VALUES ('M6', N'Lập trình Java', 60);
INSERT INTO dmmh VALUES ('M7', N'Cấu trúc dữ liệu', 45);
INSERT INTO dmmh VALUES ('M8', N'Toán rời rạc', 45);
INSERT INTO dmmh VALUES ('M9', N'Toán cao cấp A1', 60);
INSERT INTO dmmh VALUES ('MA', N'Toán cao cấp A2', 60);
INSERT INTO dmmh VALUES ('MB', N'Kinh tế vĩ mô', 45);
INSERT INTO dmmh VALUES ('MC', N'Kinh tế vi mô', 45);
INSERT INTO dmmh VALUES ('MD', N'Vật lý đại cương', 60);
INSERT INTO dmmh VALUES ('ME', N'Hóa học đại cương', 45);
INSERT INTO dmmh VALUES ('MF', N'Xác suất thống kê', 45);
INSERT INTO dmmh VALUES ('MG', N'Triết học Mác Lênin', 45);
INSERT INTO dmmh VALUES ('MH', N'Pháp luật đại cương', 30);
INSERT INTO dmmh VALUES ('MI', N'Giao tiếp kinh doanh', 30);
INSERT INTO dmmh VALUES ('MJ', N'Hệ điều hành', 45);
INSERT INTO dmmh VALUES ('MK', N'Trí tuệ nhân tạo', 60);

INSERT INTO dmsv VALUES ('S01', N'Nguyễn Văn', N'An', N'Nam', TO_DATE('01/01/2005','DD/MM/YYYY'), N'Hà Nội', 'CN', 1000000);
INSERT INTO dmsv VALUES ('S02', N'Trần Thị', N'Bình', N'Nữ', TO_DATE('15/05/2004','DD/MM/YYYY'), N'Hải Phòng', 'KT', 0);
INSERT INTO dmsv VALUES ('S03', N'Lê Văn', N'Cường', N'Nam', TO_DATE('20/10/2005','DD/MM/YYYY'), N'Nam Định', 'QT', 500000);
INSERT INTO dmsv VALUES ('S04', N'Phạm Thị', N'Dung', N'Nữ', TO_DATE('08/03/2006','DD/MM/YYYY'), N'Thanh Hóa', 'NN', 1500000);
INSERT INTO dmsv VALUES ('S05', N'Hoàng Văn', N'Em', N'Nam', TO_DATE('12/12/2004','DD/MM/YYYY'), N'Nghệ An', 'DT', 0);
INSERT INTO dmsv VALUES ('S06', N'Đỗ Minh', N'Hiếu', N'Nam', TO_DATE('11/11/2005','DD/MM/YYYY'), N'Đà Nẵng', 'XD', 0);
INSERT INTO dmsv VALUES ('S07', N'Vũ Thị', N'Giang', N'Nữ', TO_DATE('22/02/2005','DD/MM/YYYY'), N'Quảng Ninh', 'CK', 1200000);
INSERT INTO dmsv VALUES ('S08', N'Bùi Quang', N'Huy', N'Nam', TO_DATE('13/07/2004','DD/MM/YYYY'), N'Hưng Yên', 'SH', 0);
INSERT INTO dmsv VALUES ('S09', N'Đặng Thu', N'Hà', N'Nữ', TO_DATE('09/09/2006','DD/MM/YYYY'), N'Bắc Ninh', 'MT', 800000);
INSERT INTO dmsv VALUES ('S10', N'Ngô Tấn', N'Tài', N'Nam', TO_DATE('18/04/2005','DD/MM/YYYY'), N'TP HCM', 'TO', 0);
INSERT INTO dmsv VALUES ('S11', N'Lý Lan', N'Hương', N'Nữ', TO_DATE('25/08/2004','DD/MM/YYYY'), N'Cần Thơ', 'VL', 2000000);
INSERT INTO dmsv VALUES ('S12', N'Đinh Xuân', N'Trường', N'Nam', TO_DATE('30/01/2005','DD/MM/YYYY'), N'Ninh Bình', 'HH', 0);
INSERT INTO dmsv VALUES ('S13', N'Mai Thanh', N'Thảo', N'Nữ', TO_DATE('14/06/2006','DD/MM/YYYY'), N'Bình Dương', 'DL', 500000);
INSERT INTO dmsv VALUES ('S14', N'Phan Đình', N'Phùng', N'Nam', TO_DATE('02/09/2004','DD/MM/YYYY'), N'Huế', 'LS', 0);
INSERT INTO dmsv VALUES ('S15', N'Trịnh Yến', N'Nhi', N'Nữ', TO_DATE('19/12/2005','DD/MM/YYYY'), N'Đồng Nai', 'VH', 1000000);
INSERT INTO dmsv VALUES ('S16', N'Đoàn Bảo', N'Châu', N'Nữ', TO_DATE('27/03/2006','DD/MM/YYYY'), N'Vũng Tàu', 'TH', 0);
INSERT INTO dmsv VALUES ('S17', N'Tô Hiệp', N'Phát', N'Nam', TO_DATE('05/11/2004','DD/MM/YYYY'), N'Cà Mau', 'YD', 1800000);
INSERT INTO dmsv VALUES ('S18', N'Hồ Trọng', N'Nghĩa', N'Nam', TO_DATE('16/05/2005','DD/MM/YYYY'), N'Hà Tĩnh', 'DP', 0);
INSERT INTO dmsv VALUES ('S19', N'Cao Mỹ', N'Lệ', N'Nữ', TO_DATE('21/10/2006','DD/MM/YYYY'), N'Vĩnh Long', 'NH', 300000);
INSERT INTO dmsv VALUES ('S20', N'Châu Tinh', N'Trì', N'Nam', TO_DATE('08/08/2004','DD/MM/YYYY'), N'Lạng Sơn', 'TC', 0);

INSERT INTO ketqua VALUES ('S01', 'M1', 8.5);
INSERT INTO ketqua VALUES ('S01', 'M2', 7.0);
INSERT INTO ketqua VALUES ('S02', 'M3', 9.0);
INSERT INTO ketqua VALUES ('S03', 'M4', 6.5);
INSERT INTO ketqua VALUES ('S04', 'M5', 10.0);
INSERT INTO ketqua VALUES ('S05', 'M6', 5.5);
INSERT INTO ketqua VALUES ('S06', 'M7', 8.0);
INSERT INTO ketqua VALUES ('S07', 'M8', 7.5);
INSERT INTO ketqua VALUES ('S08', 'M9', 4.0);
INSERT INTO ketqua VALUES ('S09', 'MA', 9.5);
INSERT INTO ketqua VALUES ('S10', 'MB', 6.0);
INSERT INTO ketqua VALUES ('S11', 'MC', 8.5);
INSERT INTO ketqua VALUES ('S12', 'MD', 7.0);
INSERT INTO ketqua VALUES ('S13', 'ME', 9.0);
INSERT INTO ketqua VALUES ('S14', 'MF', 5.0);
INSERT INTO ketqua VALUES ('S15', 'MG', 8.5);
INSERT INTO ketqua VALUES ('S16', 'MH', 7.5);
INSERT INTO ketqua VALUES ('S17', 'MI', 9.5);
INSERT INTO ketqua VALUES ('S18', 'MJ', 6.5);
INSERT INTO ketqua VALUES ('S19', 'MK', 8.0);
INSERT INTO ketqua VALUES ('S20', 'M1', 4.5);

COMMIT;