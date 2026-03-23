CREATE OR REPLACE TRIGGER trg_DatPhong
BEFORE INSERT ON HoaDon
FOR EACH ROW
DECLARE
    v_dem NUMBER;
    v_TrangThai Phong.TrangThai%TYPE;
    v_SoNguoiToiDa Phong.SoNguoiToiDa%TYPE;
    v_GiaTheoNgay Phong.GiaTheoNgay%TYPE;
BEGIN
    -- Kiểm tra tồn tại
    SELECT COUNT(*) INTO v_dem FROM KhachHang WHERE MaKH = :NEW.MaKH;
    IF v_dem = 0 THEN RAISE_APPLICATION_ERROR(-20001, 'Khach hang khong ton tai'); END IF;

    SELECT COUNT(*) INTO v_dem FROM Phong WHERE MaPhong = :NEW.MaPhong;
    IF v_dem = 0 THEN RAISE_APPLICATION_ERROR(-20002, 'Phong khong ton tai'); END IF;

    -- Kiểm tra nghiệp vụ
    SELECT TrangThai, SoNguoiToiDa, GiaTheoNgay 
    INTO v_TrangThai, v_SoNguoiToiDa, v_GiaTheoNgay 
    FROM Phong WHERE MaPhong = :NEW.MaPhong;

    IF v_TrangThai != 'TRONG' THEN RAISE_APPLICATION_ERROR(-20003, 'Phong khong trong'); END IF;
    IF :NEW.SoNguoi > v_SoNguoiToiDa THEN RAISE_APPLICATION_ERROR(-20004, 'Vuot qua so nguoi toi da'); END IF;
    IF :NEW.NgayNhan >= :NEW.NgayTra OR :NEW.NgayNhan < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20005, 'Ngay nhan/tra khong hop le');
    END IF;

    -- Tính tiền (:NEW.NgayTra - :NEW.NgayNhan trả ra số ngày)
    :NEW.TongTien := (:NEW.NgayTra - :NEW.NgayNhan) * v_GiaTheoNgay;
    
    -- Đổi trạng thái phòng
    UPDATE Phong SET TrangThai = 'DA_THUE' WHERE MaPhong = :NEW.MaPhong;
END trg_DatPhong;
/

-- LỆNH TEST CÂU a:
INSERT INTO HoaDon(MaHD, MaKH, MaPhong, NgayNhan, NgayTra, SoNguoi, TrangThai) 
VALUES ('HD01', 'KH01', 'P102', SYSDATE, SYSDATE+2, 1, 'CHO_NHAN');

INSERT INTO HoaDon(MaHD, MaKH, MaPhong, NgayNhan, NgayTra, SoNguoi, TrangThai) 
VALUES ('HD02', 'KH01', 'P101', SYSDATE, SYSDATE+2, 1, 'CHO_NHAN');
SELECT * FROM HoaDon; -- Kiểm tra tổng tiền
SELECT * FROM Phong;  -- P101 đã thành DA_THUE



CREATE OR REPLACE TRIGGER trg_CapNhatTrangThaiHD
BEFORE UPDATE OF TrangThai ON HoaDon
FOR EACH ROW
BEGIN
    -- Kiểm tra chuyển trạng thái hợp lệ
    IF :OLD.TrangThai = 'CHO_NHAN' AND :NEW.TrangThai NOT IN ('DANG_O', 'HUY') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Loi: CHO_NHAN chi the chuyen sang DANG_O hoac HUY');
    ELSIF :OLD.TrangThai = 'DANG_O' AND :NEW.TrangThai != 'DA_TRA' THEN
        RAISE_APPLICATION_ERROR(-20007, 'Loi: DANG_O chi co the chuyen sang DA_TRA');
    ELSIF :OLD.TrangThai IN ('DA_TRA', 'HUY') THEN
        RAISE_APPLICATION_ERROR(-20008, 'Loi: Khong the thay doi HD da ket thuc (DA_TRA/HUY)');
    END IF;

    -- Xử lý hậu quả theo từng trạng thái
    IF :NEW.TrangThai = 'DA_TRA' THEN
        UPDATE Phong SET TrangThai = 'TRONG' WHERE MaPhong = :NEW.MaPhong;
        INSERT INTO LichSuPhong(MaPhong, MaHD, NgayNhan, NgayTra, GhiChu)
        VALUES (:NEW.MaPhong, :NEW.MaHD, :NEW.NgayNhan, :NEW.NgayTra, 'Khach da tra phong');
    ELSIF :NEW.TrangThai = 'HUY' THEN
        UPDATE Phong SET TrangThai = 'TRONG' WHERE MaPhong = :NEW.MaPhong;
    END IF;
END trg_CapNhatTrangThaiHD;
/

-- LỆNH TEST CÂU b:
-- Cập nhật Hợp lệ (CHO_NHAN -> DANG_O)
UPDATE HoaDon SET TrangThai = 'DANG_O' WHERE MaHD = 'HD02';

UPDATE HoaDon SET TrangThai = 'DA_TRA' WHERE MaHD = 'HD02';
SELECT * FROM LichSuPhong;



CREATE OR REPLACE TRIGGER trg_SuaChiPhi
FOR INSERT OR UPDATE ON ChiPhiPhuThu
COMPOUND TRIGGER
    v_count NUMBER := 0;
    -- Tạo một mảng (Collection) để lưu danh sách các MaHD bị ảnh hưởng
    TYPE t_mahd IS TABLE OF VARCHAR2(20) INDEX BY VARCHAR2(20);
    v_list_hd t_mahd;
    v_idx VARCHAR2(20);

    BEFORE STATEMENT IS
    BEGIN
        v_count := 0;
        v_list_hd.DELETE;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        v_count := v_count + 1;
        IF v_count > 5 THEN
            RAISE_APPLICATION_ERROR(-20009, 'Loi: Chi duoc thao tac toi da 5 chi phi 1 luc!');
        END IF;

        IF :NEW.SoTien <= 0 OR :NEW.SoTien >= 50000000 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Loi: So tien phai > 0 va < 50 trieu!');
        END IF;

        -- Ghi nhớ lại MaHD để cập nhật ở bước After Statement
        v_list_hd(:NEW.MaHD) := :NEW.MaHD;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        v_idx := v_list_hd.FIRST;
        WHILE v_idx IS NOT NULL LOOP
            -- Cập nhật: Tổng tiền mới = (Tiền phòng gốc) + (Tổng phụ thu hiện có)
            UPDATE HoaDon h
            SET TongTien = (
                SELECT (h.NgayTra - h.NgayNhan) * p.GiaTheoNgay
                FROM Phong p WHERE p.MaPhong = h.MaPhong
            ) + COALESCE((SELECT SUM(SoTien) FROM ChiPhiPhuThu WHERE MaHD = v_idx), 0)
            WHERE MaHD = v_idx;

            v_idx := v_list_hd.NEXT(v_idx);
        END LOOP;
    END AFTER STATEMENT;
END trg_SuaChiPhi;
/

-- LỆNH TEST CÂU c:
-- Thêm 1 phụ thu 100k cho HD02 (Tổng tiền cũ 1tr -> sẽ tự nhảy lên 1tr1)
INSERT INTO ChiPhiPhuThu(MaCP, MaHD, MoTa, SoTien, ThoiGian) 
VALUES ('CP01', 'HD02', 'Nuoc suoi', 100000, SYSDATE);
SELECT MaHD, TongTien FROM HoaDon WHERE MaHD = 'HD02';





CREATE OR REPLACE VIEW vw_PhongTrong AS
SELECT MaPhong, LoaiPhong, GiaTheoNgay, SoNguoiToiDa
FROM Phong
WHERE TrangThai = 'TRONG';

CREATE OR REPLACE TRIGGER trg_vwPhongTrong_ins
INSTEAD OF INSERT ON vw_PhongTrong
FOR EACH ROW
DECLARE
    v_MaHD VARCHAR2(20);
    v_MaKH VARCHAR2(20);
BEGIN
    v_MaHD := 'HD' || TO_CHAR(SEQ_HD.NEXTVAL, 'FM0000');

    SELECT MIN(MaKH) INTO v_MaKH FROM KhachHang;

    INSERT INTO HoaDon(MaHD, MaKH, MaPhong, NgayNhan, NgayTra, SoNguoi, TrangThai)
    VALUES (v_MaHD, v_MaKH, :NEW.MaPhong, TRUNC(SYSDATE), TRUNC(SYSDATE)+1, 1, 'CHO_NHAN');
    
    DBMS_OUTPUT.PUT_LINE('Dat phong thanh cong qua View! Ma HD: ' || v_MaHD);
END;
/

-- LỆNH TEST CÂU d:
-- P101 đang TRONG (do test xong câu B khách đã trả). Giờ ta đặt P101 trực tiếp qua View.
INSERT INTO vw_PhongTrong(MaPhong) VALUES ('P101');
SELECT * FROM HoaDon; 