SET SERVEROUTPUT ON;

CREATE TABLE KHOA(
    Makhoa VARCHAR2(10) PRIMARY KEY, 
    Tenkhoa VARCHAR2(50), 
    Dienthoai VARCHAR2(20)
);

CREATE TABLE LOP(
    Malop VARCHAR2(10) PRIMARY KEY, 
    Tenlop VARCHAR2(50), 
    Khoa VARCHAR2(50), 
    Hedt VARCHAR2(50), 
    Namnhaphoc NUMBER, 
    Makhoa VARCHAR2(10) REFERENCES KHOA(Makhoa)
);

--1

CREATE OR REPLACE PROCEDURE sp_nhapkhoa_Cach1 (
    p_makhoa IN VARCHAR2,
    p_tenkhoa IN VARCHAR2,
    p_dienthoai IN VARCHAR2
) AS
    v_ton_tai NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_ton_tai 
    FROM dual 
    WHERE EXISTS (SELECT 1 FROM KHOA WHERE Tenkhoa = p_tenkhoa);
    IF v_ton_tai = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Ten khoa ' || p_tenkhoa || ' da ton tai!');
    ELSE
        INSERT INTO KHOA VALUES (p_makhoa, p_tenkhoa, p_dienthoai);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them khoa thanh cong!');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE sp_nhapkhoa_Cach2 (
    p_makhoa IN VARCHAR2,
    p_tenkhoa IN VARCHAR2,
    p_dienthoai IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem 
    FROM KHOA 
    WHERE Tenkhoa = p_tenkhoa;
    IF v_dem > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ten khoa ' || p_tenkhoa || ' da ton tai!');
    ELSE
        INSERT INTO KHOA VALUES (p_makhoa, p_tenkhoa, p_dienthoai);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them khoa thanh cong!');
    END IF;
END;
/
--goi thu tuc
-- TH1: Thêm khoa mới (Sẽ báo thêm thành công)
EXECUTE sp_nhapkhoa_Cach1('K01', 'Cong Nghe Thong Tin', '0123456'); 

-- TH2: Thêm khoa bị trùng tên (Sẽ báo tên khoa đã tồn tại)
EXECUTE sp_nhapkhoa_Cach1('K02', 'Cong Nghe Thong Tin', '0987654');

--2

CREATE OR REPLACE PROCEDURE sp_ThemLop(
    p_malop VARCHAR2, 
    p_tenlop VARCHAR2, 
    p_khoa VARCHAR2, 
    p_hedt VARCHAR2, 
    p_namnhaphoc NUMBER, 
    p_makhoa VARCHAR2
) AS
    v_dem_lop NUMBER := 0;
    v_dem_khoa NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_lop FROM LOP WHERE Tenlop = p_tenlop;
    IF v_dem_lop > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ten lop da co truoc do!');
        RETURN; -- Dừng thủ tục
    END IF;

    SELECT COUNT(*) INTO v_dem_khoa FROM KHOA WHERE Makhoa = p_makhoa;
    IF v_dem_khoa = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma khoa khong ton tai trong bang KHOA!');
        RETURN;
    END IF;

    INSERT INTO LOP VALUES (p_malop, p_tenlop, p_khoa, p_hedt, p_namnhaphoc, p_makhoa);
    DBMS_OUTPUT.PUT_LINE('Them lop thanh cong!');
    COMMIT;
END;
/
--goi thu tuc

-- TH1: Thêm lớp thành công (Mã khoa K01 phải tồn tại)
EXECUTE sp_ThemLop('L01', 'Lop CNTT 1', 'Cong Nghe Thong Tin', 'Dai hoc', 2023, 'K01');

-- TH2: Mã khoa không tồn tại (Báo lỗi)
EXECUTE sp_ThemLop('L02', 'Lop CNTT 2', 'Cong Nghe Thong Tin', 'Dai hoc', 2023, 'K99');

--3

CREATE OR REPLACE PROCEDURE sp_ThemKhoa_Bai3_Cach1 (
    p_makhoa IN VARCHAR2,
    p_tenkhoa IN VARCHAR2,
    p_dienthoai IN VARCHAR2,
    p_kq OUT NUMBER -- Tham số OUT để trả về giá trị
) AS
    v_ton_tai NUMBER := 0;
BEGIN
    -- Kiểm tra tồn tại bằng EXISTS bọc qua dual
    SELECT COUNT(*) INTO v_ton_tai 
    FROM dual 
    WHERE EXISTS (SELECT 1 FROM KHOA WHERE Tenkhoa = p_tenkhoa);

    IF v_ton_tai = 1 THEN
        p_kq := 0; -- Nếu đã tồn tại, trả về 0
    ELSE
        INSERT INTO KHOA VALUES (p_makhoa, p_tenkhoa, p_dienthoai);
        COMMIT;
        p_kq := 1; -- Nếu chưa tồn tại thì thêm mới và trả về 1 (Quy ước thành công)
    END IF;
END;
/


CREATE OR REPLACE PROCEDURE sp_ThemKhoa_Bai3_Cach2 (
    p_makhoa IN VARCHAR2,
    p_tenkhoa IN VARCHAR2,
    p_dienthoai IN VARCHAR2,
    p_kq OUT NUMBER -- Tham số OUT để trả về giá trị
) AS
    v_dem NUMBER := 0;
BEGIN
    -- Đếm số lượng bản ghi trùng tên khoa
    SELECT COUNT(*) INTO v_dem 
    FROM KHOA 
    WHERE Tenkhoa = p_tenkhoa;

    IF v_dem > 0 THEN
        p_kq := 0; -- Nếu lớn hơn 0 (đã tồn tại), trả về 0
    ELSE
        INSERT INTO KHOA VALUES (p_makhoa, p_tenkhoa, p_dienthoai);
        COMMIT;
        p_kq := 1; -- Trả về 1 khi thêm thành công
    END IF;
END;
/

--goi thu tuc
--c1
DECLARE
    v_kq_cach1 NUMBER;
BEGIN
    -- Thử thêm Khoa Xây Dựng (Chưa có trong bảng)
    sp_ThemKhoa_Bai3_Cach1('K03', 'Khoa Xay Dung', '0123456789', v_kq_cach1);
    DBMS_OUTPUT.PUT_LINE('Test Cach 1 - Them khoa moi: ' || v_kq_cach1); 
    -- Sẽ in ra số 1
END;
--c2
DECLARE
    v_kq_cach2 NUMBER;
BEGIN
    -- Thử thêm lại Khoa Xây Dựng (Lúc này đã bị trùng vì Cách 1 vừa thêm xong)
    sp_ThemKhoa_Bai3_Cach2('K04', 'Khoa Xay Dung', '0987654321', v_kq_cach2);
    DBMS_OUTPUT.PUT_LINE('Test Cach 2 - Bi trung ten: ' || v_kq_cach2); 
    -- Sẽ in ra số 0
END;
--4


CREATE OR REPLACE PROCEDURE sp_ThemLop_Out(
    p_malop VARCHAR2, p_tenlop VARCHAR2, p_khoa VARCHAR2, 
    p_hedt VARCHAR2, p_namnhaphoc NUMBER, p_makhoa VARCHAR2, 
    p_kq OUT NUMBER
) AS
    v_dem_lop NUMBER := 0;
    v_dem_khoa NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_lop FROM LOP WHERE Tenlop = p_tenlop;
    IF v_dem_lop > 0 THEN
        p_kq := 0; -- Tên lớp đã có [cite: 90]
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_khoa FROM KHOA WHERE Makhoa = p_makhoa;
    IF v_dem_khoa = 0 THEN
        p_kq := 1; -- Mã khoa không có [cite: 91]
        RETURN;
    END IF;

    INSERT INTO LOP VALUES (p_malop, p_tenlop, p_khoa, p_hedt, p_namnhaphoc, p_makhoa);
    p_kq := 2; -- Đầy đủ thông tin, cho phép nhập [cite: 92]
    COMMIT;
END;
/
--goi thu tuc

DECLARE
    v_kq NUMBER;
BEGIN
    -- Gọi thủ tục
    sp_ThemLop_Out('L03', 'Lop Kinh Te 1', 'Kinh Te', 'Dai hoc', 2023, 'K03', v_kq);
    
    IF v_kq = 0 THEN DBMS_OUTPUT.PUT_LINE('Ten lop da co!');
    ELSIF v_kq = 1 THEN DBMS_OUTPUT.PUT_LINE('Ma khoa khong ton tai!');
    ELSE DBMS_OUTPUT.PUT_LINE('Them lop thanh cong (Ket qua = 2)');
    END IF;
END;
/

--bt2
CREATE TABLE tblChucVu(
    MaCV VARCHAR2(10) PRIMARY KEY, 
    TenCV VARCHAR2(50)
);

CREATE TABLE tblNhanVien(
    MaNV VARCHAR2(10) PRIMARY KEY, 
    MaCV VARCHAR2(10) REFERENCES tblChucVu(MaCV), 
    TenNV VARCHAR2(50), 
    NgaySinh DATE, 
    LuongCanBan NUMBER, 
    NgayCong NUMBER, 
    PhuCap NUMBER
);

-- Nhập dữ liệu mẫu
INSERT INTO tblChucVu VALUES ('CV01', 'Giam Doc');
INSERT INTO tblChucVu VALUES ('CV02', 'Truong Phong');
INSERT INTO tblChucVu VALUES ('CV03', 'Nhan Vien');
INSERT INTO tblChucVu VALUES ('CV04', 'Bao Ve');

INSERT INTO tblNhanVien VALUES ('NV01', 'CV01', 'Hoang Cong Toan', TO_DATE('15/06/1990', 'DD/MM/YYYY'), 1000, 26, 500);
INSERT INTO tblNhanVien VALUES ('NV02', 'CV03', 'Tran Thi B', TO_DATE('20/10/1995', 'DD/MM/YYYY'), 500, 24, 100);
INSERT INTO tblNhanVien VALUES ('NV03', 'CV03', 'Le Van C', TO_DATE('01/01/1998', 'DD/MM/YYYY'), 500, 20, 100);
COMMIT;


--a

CREATE OR REPLACE PROCEDURE SP_Them_Nhan_Vien(
    p_manv VARCHAR2, p_macv VARCHAR2, p_tennv VARCHAR2, 
    p_ngaysinh DATE, p_luongcb NUMBER, p_ngaycong NUMBER, p_phucap NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM tblChucVu WHERE MaCV = p_macv;
    IF v_dem > 0 THEN
        INSERT INTO tblNhanVien VALUES (p_manv, p_macv, p_tennv, p_ngaysinh, p_luongcb, p_ngaycong, p_phucap);
        DBMS_OUTPUT.PUT_LINE('Them nhan vien thanh cong!');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ma chuc vu khong ton tai!');
    END IF;
END;
/
--GOI THU TUC

-- TH1: Thêm nhân viên thành công (Mã chức vụ CV01 có sẵn)
EXECUTE SP_Them_Nhan_Vien('NV99', 'CV01', 'Le Thi D', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 2000, 25, 500);

-- TH2: Mã chức vụ không tồn tại (Lỗi)
EXECUTE SP_Them_Nhan_Vien('NV98', 'CV99', 'Tran Van E', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 2000, 25, 500);

--b

CREATE OR REPLACE PROCEDURE SP_CapNhat_Nhan_Vien(
    p_manv VARCHAR2, p_macv VARCHAR2, p_tennv VARCHAR2, 
    p_ngaysinh DATE, p_luongcb NUMBER, p_ngaycong NUMBER, p_phucap NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM tblChucVu WHERE MaCV = p_macv;
    IF v_dem > 0 THEN
        UPDATE tblNhanVien 
        SET MaCV = p_macv, TenNV = p_tennv, NgaySinh = p_ngaysinh, 
            LuongCanBan = p_luongcb, NgayCong = p_ngaycong, PhuCap = p_phucap 
        WHERE MaNV = p_manv;
        DBMS_OUTPUT.PUT_LINE('Cap nhat thanh cong!');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ma chuc vu khong ton tai!');
    END IF;
END;
/
--goi thu tuc

-- Cập nhật lương và chức vụ cho nhân viên NV99 vừa thêm ở trên
EXECUTE SP_CapNhat_Nhan_Vien('NV99', 'CV02', 'Le Thi D (Da sua)', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 3000, 26, 1000);

--c

CREATE OR REPLACE PROCEDURE SP_LuongLN AS
BEGIN
    FOR r IN (
        SELECT TenNV, (LuongCanBan * NgayCong + PhuCap) AS Luong 
        FROM tblNhanVien
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Nhan vien: ' || r.TenNV || ' - Luong: ' || r.Luong);
    END LOOP;
END;
/
--goi thu tuc
-- Gọi thẳng tên thủ tục, nó sẽ tự động in ra danh sách lương
EXECUTE SP_LuongLN;

--bt3
--1

CREATE OR REPLACE PROCEDURE sp_them_nhan_vien1(
    p_manv VARCHAR2, p_macv VARCHAR2, p_tennv VARCHAR2, 
    p_ngaysinh DATE, p_luongcb NUMBER, p_ngaycong NUMBER, p_phucap NUMBER,
    p_kq OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM tblChucVu WHERE MaCV = p_macv;
    IF v_dem = 0 THEN
        p_kq := 0; -- Mã CV chưa tồn tại [cite: 120]
    ELSE
        INSERT INTO tblNhanVien VALUES (p_manv, p_macv, p_tennv, p_ngaysinh, p_luongcb, p_ngaycong, p_phucap);
        p_kq := 1; -- Thêm thành công
        COMMIT;
    END IF;
END;
/
--goi thu tuc

DECLARE
    v_kq NUMBER;
BEGIN
    sp_them_nhan_vien1('NV97', 'CV03', 'Hoang Van F', TO_DATE('12/12/1999', 'DD/MM/YYYY'), 1500, 24, 200, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua cau 1: ' || v_kq);
END;
/

--2

CREATE OR REPLACE PROCEDURE sp_them_nhan_vien1_v2(
    p_manv VARCHAR2, p_macv VARCHAR2, p_tennv VARCHAR2, 
    p_ngaysinh DATE, p_luongcb NUMBER, p_ngaycong NUMBER, p_phucap NUMBER,
    p_kq OUT NUMBER
) AS
    v_dem_nv NUMBER := 0;
    v_dem_cv NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_nv FROM tblNhanVien WHERE MaNV = p_manv;
    IF v_dem_nv > 0 THEN
        p_kq := 0; -- MaNV đã tồn tại [cite: 122]
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_cv FROM tblChucVu WHERE MaCV = p_macv;
    IF v_dem_cv = 0 THEN
        p_kq := 1; -- MaCV chưa tồn tại [cite: 122]
        RETURN;
    END IF;

    INSERT INTO tblNhanVien VALUES (p_manv, p_macv, p_tennv, p_ngaysinh, p_luongcb, p_ngaycong, p_phucap);
    p_kq := 2; -- Cho phép chèn bản ghi [cite: 122]
    COMMIT;
END;
/
--goi thu tuc

DECLARE
    v_kq NUMBER;
BEGIN
    -- Cố tình thêm lại NV97 để test báo lỗi trùng mã
    sp_them_nhan_vien1_v2('NV97', 'CV03', 'Hoang Van F', TO_DATE('12/12/1999', 'DD/MM/YYYY'), 1500, 24, 200, v_kq);
    
    IF v_kq = 0 THEN DBMS_OUTPUT.PUT_LINE('MaNV da ton tai!');
    ELSIF v_kq = 1 THEN DBMS_OUTPUT.PUT_LINE('MaCV chua ton tai!');
    ELSE DBMS_OUTPUT.PUT_LINE('Them thanh cong!');
    END IF;
END;
/

--3

CREATE OR REPLACE PROCEDURE sp_capnhat_ngaysinh(
    p_manv VARCHAR2, 
    p_ngaysinh DATE,
    p_kq OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM tblNhanVien WHERE MaNV = p_manv;
    IF v_dem = 0 THEN
        p_kq := 0; -- Không tìm thấy bản ghi [cite: 124]
    ELSE
        UPDATE tblNhanVien SET NgaySinh = p_ngaysinh WHERE MaNV = p_manv;
        p_kq := 1; -- Cập nhật thành công
        COMMIT;
    END IF;
END;
/
--goi thu tuc

DECLARE
    v_kq NUMBER;
BEGIN
    -- Sửa ngày sinh cho nhân viên NV97
    sp_capnhat_ngaysinh('NV97', TO_DATE('20/10/2000', 'DD/MM/YYYY'), v_kq);
    
    IF v_kq = 0 THEN 
        DBMS_OUTPUT.PUT_LINE('Khong tim thay nhan vien de cap nhat!');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Cap nhat ngay sinh thanh cong!');
    END IF;
END;
/
