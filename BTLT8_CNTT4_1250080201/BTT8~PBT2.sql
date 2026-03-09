-- a. Thủ tục sp_ThemNhanVien 
CREATE OR REPLACE PROCEDURE sp_ThemNhanVien_OUT (
    p_MaNV IN VARCHAR2, p_TenNV IN VARCHAR2, p_GioiTinh IN VARCHAR2, 
    p_DiaChi IN VARCHAR2, p_SoDT IN VARCHAR2, p_Email IN VARCHAR2, 
    p_TenPhong IN VARCHAR2, p_Flag IN NUMBER, 
    p_kq OUT NUMBER
) AS
BEGIN
    -- Nếu GioiTinh không phải 'Nam' hoặc 'Nữ' → trả về mã lỗi 1 [cite: 64]
    IF p_GioiTinh <> 'Nam' AND p_GioiTinh <> 'Nu' THEN
        p_kq := 1;
        RETURN;
    END IF;

    -- Flag = 0 → INSERT nhân viên mới, trả về 0 [cite: 65]
    IF p_Flag = 0 THEN
        INSERT INTO NhanVien VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
        p_kq := 0;
    -- Flag ≠ 0 → UPDATE nhân viên theo MaNV, trả về 0 [cite: 66]
    ELSE
        UPDATE NhanVien SET TenNV = p_TenNV, GioiTinh = p_GioiTinh, DiaChi = p_DiaChi, 
            SoDT = p_SoDT, Email = p_Email, TenPhong = p_TenPhong WHERE MaNV = p_MaNV;
        p_kq := 0;
    END IF;
    COMMIT;
END;
/

-- b. Thủ tục sp_ThemMoiSP 
CREATE OR REPLACE PROCEDURE sp_ThemMoiSP_OUT (
    p_MaSP IN VARCHAR2, p_TenHang IN VARCHAR2, p_TenSP IN VARCHAR2, 
    p_SoLuong IN NUMBER, p_MauSac IN VARCHAR2, p_GiaBan IN NUMBER, 
    p_DonViTinh IN VARCHAR2, p_MoTa IN VARCHAR2, p_Flag IN NUMBER, 
    p_kq OUT NUMBER
) AS
    v_MaHangSX VARCHAR2(10);
BEGIN
    BEGIN
        SELECT MaHangSX INTO v_MaHangSX FROM HangSX WHERE TenHang = p_TenHang;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; -- TenHang không có trong HangSX → trả về 1 [cite: 69]
            RETURN;
    END;

    IF p_SoLuong < 0 THEN
        p_kq := 2; -- SoLuong < 0 → trả về 2 [cite: 70]
        RETURN;
    END IF;

    -- Flag = 0 → INSERT sản phẩm. Flag ≠ 0 → UPDATE sản phẩm. Trả về 0 [cite: 71]
    IF p_Flag = 0 THEN
        INSERT INTO SanPham VALUES (p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
    ELSE
        UPDATE SanPham SET MaHangSX = v_MaHangSX, TenSP = p_TenSP, SoLuong = p_SoLuong, 
            MauSac = p_MauSac, GiaBan = p_GiaBan, DonViTinh = p_DonViTinh, MoTa = p_MoTa WHERE MaSP = p_MaSP;
    END IF;
    
    p_kq := 0;
    COMMIT;
END;
/

-- c. Thủ tục xóa NhanVien 
CREATE OR REPLACE PROCEDURE sp_xoaNhanVien_OUT (p_MaNV IN VARCHAR2, p_kq OUT NUMBER) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem = 0 THEN
        p_kq := 1; -- Nếu MaNV chưa có → trả về 1 [cite: 73]
        RETURN;
    END IF;
    
    -- Nếu có → xóa liên bảng, trả về 0 [cite: 73]
    DELETE FROM Nhap WHERE SoHDN IN (SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV);
    DELETE FROM PNhap WHERE MaNV = p_MaNV;
    DELETE FROM Xuat WHERE SoHDX IN (SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV);
    DELETE FROM PXuat WHERE MaNV = p_MaNV;
    DELETE FROM NhanVien WHERE MaNV = p_MaNV;
    p_kq := 0;
    COMMIT;
END;
/
=
-- d. Thủ tục xóa SanPham 
CREATE OR REPLACE PROCEDURE sp_xoaSanPham_OUT (p_MaSP IN VARCHAR2, p_kq OUT NUMBER) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = p_MaSP;
    IF v_dem = 0 THEN
        p_kq := 1; -- Nếu MaSP chưa có → trả về 1 [cite: 75]
        RETURN;
    END IF;

    -- Nếu có → xóa liên bảng, trả về 0 [cite: 75]
    DELETE FROM Nhap WHERE MaSP = p_MaSP;
    DELETE FROM Xuat WHERE MaSP = p_MaSP;
    DELETE FROM SanPham WHERE MaSP = p_MaSP;
    p_kq := 0;
    COMMIT;
END;
/

-- e. Thủ tục sp_NhapHangSX 
CREATE OR REPLACE PROCEDURE sp_NhapHangSX_OUT (
    p_MaHangSX IN VARCHAR2, p_TenHang IN VARCHAR2, p_DiaChi IN VARCHAR2, 
    p_SoDT IN VARCHAR2, p_Email IN VARCHAR2, p_kq OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM HangSX WHERE TenHang = p_TenHang;
    IF v_dem > 0 THEN
        p_kq := 1; -- TenHang đã tồn tại → trả về 1 [cite: 77]
    ELSE
        INSERT INTO HangSX VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
        p_kq := 0; -- Chưa tồn tại → INSERT, trả về 0 [cite: 77]
    END IF;
    COMMIT;
END;
/

-- f. Thủ tục nhập bảng Nhap 
CREATE OR REPLACE PROCEDURE sp_nhapBangNhap_OUT (
    p_SoHDN IN VARCHAR2, p_MaSP IN VARCHAR2, p_MaNV IN VARCHAR2, 
    p_NgayNhap IN DATE, p_SoLuongN IN NUMBER, p_DonGiaN IN NUMBER, 
    p_kq OUT NUMBER
) AS
    v_dem_sp NUMBER := 0;
    v_dem_nv NUMBER := 0;
    v_dem_hdn NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;
    IF v_dem_sp = 0 THEN
        p_kq := 1; -- MaSP không có trong SanPham → trả về 1 [cite: 79]
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem_nv = 0 THEN
        p_kq := 2; -- MaNV không có trong NhanVien → trả về 2 [cite: 80]
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdn FROM Nhap WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP;
    IF v_dem_hdn > 0 THEN
        UPDATE Nhap SET SoLuongN = p_SoLuongN, DonGiaN = p_DonGiaN WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP; -- SoHDN tồn tại → UPDATE Nhap [cite: 81]
    ELSE
        BEGIN
            INSERT INTO PNhap (SoHDN, NgayNhap, MaNV) VALUES (p_SoHDN, p_NgayNhap, p_MaNV);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
        INSERT INTO Nhap (SoHDN, MaSP, SoLuongN, DonGiaN) VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN); -- Chưa tồn tại → INSERT [cite: 81]
    END IF;
    
    p_kq := 0; -- Trả về 0 [cite: 81]
    COMMIT;
END;
/

-- g. Thủ tục nhập bảng Xuat 
CREATE OR REPLACE PROCEDURE sp_nhapBangXuat_OUT (
    p_SoHDX IN VARCHAR2, p_MaSP IN VARCHAR2, p_MaNV IN VARCHAR2, 
    p_NgayXuat IN DATE, p_SoLuongX IN NUMBER, p_kq OUT NUMBER
) AS
    v_soluong_ton NUMBER := 0;
    v_dem_nv NUMBER := 0;
    v_dem_hdx NUMBER := 0;
BEGIN
    BEGIN
        SELECT SoLuong INTO v_soluong_ton FROM SanPham WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; -- MaSP không có trong SanPham → trả về 1 [cite: 84]
            RETURN;
    END;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;
    IF v_dem_nv = 0 THEN
        p_kq := 2; -- MaNV không có trong NhanVien → trả về 2 [cite: 85]
        RETURN;
    END IF;

    IF p_SoLuongX > v_soluong_ton THEN
        p_kq := 3; -- SoLuongX > SoLuong trong SanPham → trả về 3 [cite: 86]
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdx FROM Xuat WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP;
    IF v_dem_hdx > 0 THEN
        UPDATE Xuat SET SoLuongX = p_SoLuongX WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP; -- SoHDX tồn tại → UPDATE Xuat [cite: 87]
    ELSE
        BEGIN
            INSERT INTO PXuat (SoHDX, NgayXuat, MaNV) VALUES (p_SoHDX, p_NgayXuat, p_MaNV);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
        INSERT INTO Xuat (SoHDX, MaSP, SoLuongX) VALUES (p_SoHDX, p_MaSP, p_SoLuongX); -- Chưa tồn tại → INSERT [cite: 87]
    END IF;
    
    p_kq := 0; -- Trả về 0 [cite: 87]
    COMMIT;
END;
/


SET SERVEROUTPUT ON;

-- 5. THÊM HÃNG VÀ NHÂN VIÊN TRƯỚC (Bắt buộc)
DECLARE v_kq NUMBER; BEGIN
    sp_NhapHangSX_OUT('H01', 'Apple', 'My', '0123', 'apple@.com', v_kq);
END;

SELECT * FROM HangSX;
SELECT * FROM NhanVien;
-- 1. TEST CÂU A: THÊM NHÂN VIÊN
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemNhanVien_OUT('NV02', 'Tran Thi B', 'Nu', 'HCM', '0999', 'ttb@gmail.com', 'Ke Toan', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua them NV (0 la thanh cong): ' || v_kq);
END;
/
SELECT * FROM NhanVien;

-- 2. THÊM SẢN PHẨM (Phải có hãng Apple ở bước 1 rồi mới thêm được)
DECLARE 
    v_kq NUMBER; 
BEGIN
    sp_ThemMoiSP_OUT('SP01', 'Apple', 'iPhone 15', 100, 'Den', 25000, 'Cai', 'Tot', 0, v_kq);
END;
/ 
SELECT * FROM SanPham;

-- 7. TEST NHẬP KHO (Phải có NV01 và SP01 ở trên rồi)
DECLARE v_kq NUMBER; BEGIN
    sp_nhapBangNhap_OUT('HDN01', 'SP01', 'NV01', SYSDATE, 50, 20000, v_kq);
END;
/
SELECT * FROM Nhap;

-- 6. TEST XUẤT KHO
DECLARE v_kq NUMBER; BEGIN
    sp_nhapBangXuat_OUT('HDX01', 'SP01', 'NV01', SYSDATE, 10, v_kq);
END;
/
SELECT * FROM Xuat

-- 4. TEST CÂU D: XÓA SẢN PHẨM 
DECLARE
    v_kq NUMBER;
BEGIN
    sp_xoaSanPham_OUT('SP01', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua Xoa SP (0 la thanh cong): ' || v_kq);
END;
/
SELECT * FROM SanPham;
SELECT * FROM Nhap;
SELECT * FROM Xuat;


-- 3. TEST CÂU C: XÓA NHÂN VIÊN 
DECLARE
    v_kq NUMBER;
BEGIN
    sp_xoaNhanVien_OUT('NV01', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua Xoa NV (0 la thanh cong): ' || v_kq);
END;
/
SELECT * FROM NhanVien;
SELECT * FROM PNhap;
SELECT * FROM PXuat;;