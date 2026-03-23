CREATE OR REPLACE TRIGGER trg_Nhap
BEFORE INSERT ON Nhap
FOR EACH ROW
DECLARE
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = :NEW.MaSP;
    IF v_dem = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Loi: Ma San Pham khong ton tai!');
    END IF;

    IF :NEW.SoLuongN <= 0 OR :NEW.DonGiaN <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Loi: So luong va don gia nhap phai > 0!');
    END IF;

    UPDATE SanPham SET SoLuong = SoLuong + :NEW.SoLuongN WHERE MaSP = :NEW.MaSP;
END trg_Nhap;
/

-- Lệnh Test câu a:
INSERT INTO Nhap(SoHDN, MaSP, SoLuongN, DonGiaN) VALUES ('HN01', 'SP99', 10, 5000);
INSERT INTO Nhap(SoHDN, MaSP, SoLuongN, DonGiaN) VALUES ('HN01', 'SP01', -5, 5000);
INSERT INTO Nhap(SoHDN, MaSP, SoLuongN, DonGiaN) VALUES ('HN01', 'SP01', 50, 5000);
SELECT * FROM SanPham;


CREATE OR REPLACE TRIGGER trg_xuat
BEFORE INSERT ON Xuat
FOR EACH ROW
DECLARE
    v_dem NUMBER := 0;
    v_sl_ton NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = :NEW.MaSP;
    IF v_dem = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Loi: Ma San Pham khong ton tai!');
    END IF;

    SELECT SoLuong INTO v_sl_ton FROM SanPham WHERE MaSP = :NEW.MaSP;
    IF :NEW.SoLuongX > v_sl_ton THEN
        RAISE_APPLICATION_ERROR(-20003, 'Loi: Khong du hang trong kho de xuat!');
    END IF;

    UPDATE SanPham SET SoLuong = SoLuong - :NEW.SoLuongX WHERE MaSP = :NEW.MaSP;
END trg_xuat;
/

-- Lệnh Test câu b:
INSERT INTO Xuat(SoHDX, MaSP, SoLuongX) VALUES ('HX01', 'SP01', 200);
INSERT INTO Xuat(SoHDX, MaSP, SoLuongX) VALUES ('HX01', 'SP01', 30);
SELECT * FROM SanPham;


CREATE OR REPLACE TRIGGER trg_XoaXuat
AFTER DELETE ON Xuat
FOR EACH ROW
BEGIN
    UPDATE SanPham SET SoLuong = SoLuong + :OLD.SoLuongX WHERE MaSP = :OLD.MaSP;
END trg_XoaXuat;
/

-- Lệnh Test câu c:
DELETE FROM Xuat WHERE SoHDX = 'HX01' AND MaSP = 'SP01';
SELECT * FROM SanPham;


