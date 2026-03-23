CREATE OR REPLACE PACKAGE pkg_state AS
    g_row_count NUMBER := 0;
END pkg_state;
/


CREATE OR REPLACE TRIGGER trg_CapNhatXuat
FOR UPDATE ON Xuat
COMPOUND TRIGGER
    v_sl_ton NUMBER;

    BEFORE STATEMENT IS
    BEGIN
        pkg_state.g_row_count := 0;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        pkg_state.g_row_count := pkg_state.g_row_count + 1;
        IF pkg_state.g_row_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Loi: Chi duoc cap nhat 1 ban ghi!');
        END IF;

        IF :NEW.SoLuongX != :OLD.SoLuongX THEN
            SELECT SoLuong INTO v_sl_ton FROM SanPham WHERE MaSP = :NEW.MaSP;
            IF :NEW.SoLuongX > (v_sl_ton + :OLD.SoLuongX) THEN
                RAISE_APPLICATION_ERROR(-20005, 'Loi: Kho khong du hang de xuat them!');
            END IF;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF :NEW.SoLuongX != :OLD.SoLuongX THEN
            UPDATE SanPham 
            SET SoLuong = SoLuong - (:NEW.SoLuongX - :OLD.SoLuongX) 
            WHERE MaSP = :NEW.MaSP;
        END IF;
    END AFTER EACH ROW;
END trg_CapNhatXuat;
/

-- Lệnh Test câu a:
INSERT INTO Xuat(SoHDX, MaSP, SoLuongX) VALUES ('HX02', 'SP01', 20);
INSERT INTO Xuat(SoHDX, MaSP, SoLuongX) VALUES ('HX03', 'SP01', 10);
UPDATE Xuat SET SoLuongX = 50;
UPDATE Xuat SET SoLuongX = 30 WHERE SoHDX = 'HX02';
SELECT * FROM SanPham;



CREATE OR REPLACE TRIGGER trg_CapNhatNhap
FOR UPDATE ON Nhap
COMPOUND TRIGGER
    BEFORE STATEMENT IS
    BEGIN
        pkg_state.g_row_count := 0;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        pkg_state.g_row_count := pkg_state.g_row_count + 1;
        IF pkg_state.g_row_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Loi: Chi duoc cap nhat 1 ban ghi!');
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        IF :NEW.SoLuongN != :OLD.SoLuongN THEN
            UPDATE SanPham 
            SET SoLuong = SoLuong + (:NEW.SoLuongN - :OLD.SoLuongN) 
            WHERE MaSP = :NEW.MaSP;
        END IF;
    END AFTER EACH ROW;
END trg_CapNhatNhap;
/

-- Lệnh Test câu b:
UPDATE Nhap SET SoLuongN = 20 WHERE SoHDN = 'HN01' AND MaSP = 'SP01';
SELECT * FROM SanPham;



CREATE OR REPLACE TRIGGER trg_XoaNhap
AFTER DELETE ON Nhap
FOR EACH ROW
BEGIN
    UPDATE SanPham SET SoLuong = SoLuong - :OLD.SoLuongN WHERE MaSP = :OLD.MaSP;
END trg_XoaNhap;
/

-- Lệnh Test câu c:
DELETE FROM Nhap WHERE SoHDN = 'HN01' AND MaSP = 'SP01';
SELECT * FROM SanPham;