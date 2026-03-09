SET SERVEROUTPUT ON;
-- Bật hiển thị thông báo
SET SERVEROUTPUT ON;

-- 1. Test nhập Hãng Sản Xuất
EXECUTE sp_NhapHangSX('H01', 'Samsung', 'Han Quoc', '0123456789', 'contact@samsung.com');

-- 2. Test nhập Sản Phẩm

EXECUTE sp_NhapSP('SP01', 'Samsung', 'Galaxy S24', 100, 'Den', 25000000, 'Chiec', 'Dien thoai xip');

-- 3. Test nhập Nhân Viên (Dùng FLAG)

EXECUTE sp_nhapNhanVien('NV01', 'Nguyen Van A', 'Nam', 'Ha Noi', '0988888888', 'nva@gmail.com', 'Kinh Doanh', 1);

-- 4. Test xóa Sản Phẩm liên bảng

EXECUTE sp_xoaHangSX('Samsung');

-- 5. Test xóa Nhân Viên liên bảng
EXECUTE sp_xoaNhanVien_P1('NV01');


-- a. Thủ tục sp_NhapHangSX 
CREATE OR REPLACE PROCEDURE sp_NhapHangSX (
    p_MaHangSX IN VARCHAR2, p_TenHang IN VARCHAR2, p_DiaChi IN VARCHAR2, p_SoDT IN VARCHAR2, p_Email IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM HangSX WHERE TenHang = p_TenHang;
    IF v_dem > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ten hang da ton tai!');
    ELSE
        INSERT INTO HangSX VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them hang san xuat thanh cong!');
    END IF;
END;
/

-- b. Thủ tục sp_NhapSP
CREATE OR REPLACE PROCEDURE sp_NhapSP (
    p_MaSP IN VARCHAR2, p_TenHang IN VARCHAR2, p_TenSP IN VARCHAR2, 
    p_SoLuong IN NUMBER, p_MauSac IN VARCHAR2, p_GiaBan IN NUMBER, 
    p_DonViTinh IN VARCHAR2, p_MoTa IN VARCHAR2
) AS
    v_MaHangSX VARCHAR2(10);
    v_dem NUMBER := 0;
BEGIN
    -- Lấy mã hãng từ tên hãng (Sử dụng chuẩn Cú pháp 2) [cite: 133, 134]
    BEGIN
        SELECT MaHangSX INTO v_MaHangSX FROM HangSX WHERE TenHang = p_TenHang;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ten hang khong co trong bang HangSX!');
            RETURN;
    END;

    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = p_MaSP;
    IF v_dem > 0 THEN
        UPDATE SanPham SET MaHangSX = v_MaHangSX, TenSP = p_TenSP, SoLuong = p_SoLuong, 
            MauSac = p_MauSac, GiaBan = p_GiaBan, DonViTinh = p_DonViTinh, MoTa = p_MoTa WHERE MaSP = p_MaSP;
        DBMS_OUTPUT.PUT_LINE('Da cap nhat san pham!');
    ELSE
        INSERT INTO SanPham VALUES (p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
        DBMS_OUTPUT.PUT_LINE('Da them san pham moi!');
    END IF;
    COMMIT;
END;
/

-- c. Thủ tục sp_xoaHangSX 
CREATE OR REPLACE PROCEDURE sp_xoaHangSX (p_TenHang IN VARCHAR2) AS
    v_MaHangSX VARCHAR2(10);
BEGIN
    BEGIN
        SELECT MaHangSX INTO v_MaHangSX FROM HangSX WHERE TenHang = p_TenHang;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ten hang chua co trong he thong!');
            RETURN;
    END;
    -- Xóa bảng con trước, bảng cha sau (Cú pháp 5) [cite: 139, 140, 141]
    DELETE FROM SanPham WHERE MaHangSX = v_MaHangSX;
    DELETE FROM HangSX WHERE MaHangSX = v_MaHangSX;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Da xoa Hang san xuat va cac san pham lien quan!');
END;
/

-- d. Thủ tục nhập dữ liệu NhanVien 
CREATE OR REPLACE PROCEDURE sp_nhapNhanVien (
    p_MaNV IN VARCHAR2, p_TenNV IN VARCHAR2, p_GioiTinh IN VARCHAR2, 
    p_DiaChi IN VARCHAR2, p_SoDT IN VARCHAR2, p_Email IN VARCHAR2, 
    p_TenPhong IN VARCHAR2, p_Flag IN NUMBER
) AS
BEGIN
    IF p_Flag = 0 THEN
        UPDATE NhanVien SET TenNV = p_TenNV, GioiTinh = p_GioiTinh, DiaChi = p_DiaChi, 
            SoDT = p_SoDT, Email = p_Email, TenPhong = p_TenPhong WHERE MaNV = p_MaNV;
        DBMS_OUTPUT.PUT_LINE('Da cap nhat nhan vien!');
    ELSE
        INSERT INTO NhanVien VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
        DBMS_OUTPUT.PUT_LINE('Da them nhan vien moi!');
    END IF;
    COMMIT;
END;
/
--e
CREATE OR REPLACE PROCEDURE sp_nhapBangNhap (
    p_SoHDN IN VARCHAR2, p_MaSP IN VARCHAR2, p_MaNV IN VARCHAR2, 
    p_NgayNhap IN DATE, p_SoLuongN IN NUMBER, p_DonGiaN IN NUMBER
) AS
    v_dem_sp NUMBER := 0;
    v_dem_nv NUMBER := 0;
    v_dem_hdn NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;
    IF v_dem_sp = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma san pham khong co trong bang SanPham!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem_nv = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma nhan vien khong co trong bang NhanVien!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdn FROM Nhap WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP;
    IF v_dem_hdn > 0 THEN
        UPDATE Nhap SET SoLuongN = p_SoLuongN, DonGiaN = p_DonGiaN WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP;
        DBMS_OUTPUT.PUT_LINE('Da cap nhat phieu nhap!');
    ELSE
        -- Đảm bảo PNhap (Bảng cha) có dữ liệu trước khi thêm Nhap (Bảng con)
        BEGIN
            INSERT INTO PNhap (SoHDN, NgayNhap, MaNV) VALUES (p_SoHDN, p_NgayNhap, p_MaNV);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL; -- Bỏ qua nếu PNhap đã có mã này
        END;
        INSERT INTO Nhap (SoHDN, MaSP, SoLuongN, DonGiaN) VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
        DBMS_OUTPUT.PUT_LINE('Da them phieu nhap moi!');
    END IF;
    COMMIT;
END;
/
SET SERVEROUTPUT ON;

EXECUTE sp_nhapBangNhap('HDN01', 'SP01', 'NV01', SYSDATE, 10, 20000000);


--f
EXECUTE sp_nhapBangXuat('HDX02', 'SP01', 'NV01', SYSDATE, 2);


CREATE OR REPLACE PROCEDURE sp_nhapBangXuat (
    p_SoHDX IN VARCHAR2, p_MaSP IN VARCHAR2, p_MaNV IN VARCHAR2, 
    p_NgayXuat IN DATE, p_SoLuongX IN NUMBER
) AS
    v_soluong_ton NUMBER := 0;
    v_dem_nv NUMBER := 0;
    v_dem_hdx NUMBER := 0;
BEGIN
    BEGIN
        SELECT SoLuong INTO v_soluong_ton FROM SanPham WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Ma san pham khong co trong bang SanPham!');
            RETURN;
    END;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem_nv = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma nhan vien khong co trong bang NhanVien!');
        RETURN;
    END IF;

    IF p_SoLuongX > v_soluong_ton THEN
        DBMS_OUTPUT.PUT_LINE('So luong xuat lon hon so luong ton!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdx FROM Xuat WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP;
    IF v_dem_hdx > 0 THEN
        UPDATE Xuat SET SoLuongX = p_SoLuongX WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP;
        DBMS_OUTPUT.PUT_LINE('Da cap nhat phieu xuat!');
    ELSE
        BEGIN
            INSERT INTO PXuat (SoHDX, NgayXuat, MaNV) VALUES (p_SoHDX, p_NgayXuat, p_MaNV);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
        INSERT INTO Xuat (SoHDX, MaSP, SoLuongX) VALUES (p_SoHDX, p_MaSP, p_SoLuongX);
        DBMS_OUTPUT.PUT_LINE('Da them phieu xuat moi!');
    END IF;
    COMMIT;
END;
/

-- g. Thủ tục xóa NhanVien 
CREATE OR REPLACE PROCEDURE sp_xoaNhanVien_P1 (p_MaNV IN VARCHAR2) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma NV chua co!');
        RETURN;
    END IF;
    DELETE FROM Nhap WHERE SoHDN IN (SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV);
    DELETE FROM PNhap WHERE MaNV = p_MaNV;
    DELETE FROM Xuat WHERE SoHDX IN (SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV);
    DELETE FROM PXuat WHERE MaNV = p_MaNV;
    DELETE FROM NhanVien WHERE MaNV = p_MaNV;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Da xoa nhan vien thanh cong!');
END;
/
--h

CREATE OR REPLACE PROCEDURE sp_xoaSanPham_P1 (p_MaSP IN VARCHAR2) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = p_MaSP;
    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma san pham chua co!');
        RETURN;
    END IF;

    -- Xóa liên kết ở bảng con trước
    DELETE FROM Nhap WHERE MaSP = p_MaSP;
    DELETE FROM Xuat WHERE MaSP = p_MaSP;
    DELETE FROM SanPham WHERE MaSP = p_MaSP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Da xoa san pham va du lieu lien quan!');
END;
/
EXECUTE sp_xoaSanPham_P1('SP01');
