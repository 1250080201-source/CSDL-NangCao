CREATE TABLE Hang (
    Mahang VARCHAR2(10) PRIMARY KEY, 
    Tenhang VARCHAR2(50), 
    Soluong NUMBER, 
    Giaban NUMBER
);
CREATE TABLE Hoadon (
    Mahd VARCHAR2(10) PRIMARY KEY, 
    Mahang VARCHAR2(10) REFERENCES Hang(Mahang), 
    Soluongban NUMBER, 
    Ngayban DATE
);
INSERT INTO Hang VALUES ('H01', 'Banh trung thu', 100, 50000);
COMMIT;

-- Bài 1: Trigger BEFORE INSERT trên HOADON
CREATE OR REPLACE TRIGGER trg_hd_insert
BEFORE INSERT ON Hoadon
FOR EACH ROW
DECLARE
    v_dem NUMBER := 0;
    v_tonkho NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM Hang WHERE Mahang = :NEW.Mahang;
    IF v_dem = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ma hang khong ton tai trong bang Hang');
    END IF;
    SELECT Soluong INTO v_tonkho FROM Hang WHERE Mahang = :NEW.Mahang;
    IF :NEW.Soluongban > v_tonkho THEN
        RAISE_APPLICATION_ERROR(-20002, 'So luong ban vuot qua so luong ton kho');
    END IF;
    UPDATE Hang SET Soluong = Soluong - :NEW.Soluongban WHERE Mahang = :NEW.Mahang;
END;


-- TEST BÀI 1:
INSERT INTO Hoadon VALUES ('HD01', 'H01', 10, SYSDATE);
SELECT * FROM Hang; 


-- Bài 2: Trigger AFTER DELETE trên HOADON
CREATE OR REPLACE TRIGGER trg_hd_delete
AFTER DELETE ON Hoadon
FOR EACH ROW
BEGIN
    UPDATE Hang SET Soluong = Soluong + :OLD.Soluongban WHERE Mahang = :OLD.Mahang;
END;


-- TEST BÀI 2:
DELETE FROM Hoadon WHERE Mahd = 'HD01';
SELECT * FROM Hang;


-- Bài 3: Trigger AFTER UPDATE trên HOADON
CREATE OR REPLACE TRIGGER trg_hd_update
AFTER UPDATE OF Soluongban ON Hoadon
FOR EACH ROW
BEGIN
    UPDATE Hang SET Soluong = Soluong - (:NEW.Soluongban - :OLD.Soluongban) WHERE Mahang = :NEW.Mahang;
END;


-- TEST BÀI 3:
INSERT INTO Hoadon VALUES ('HD01', 'H01', 10, SYSDATE);
UPDATE Hoadon SET Soluongban = 30 WHERE Mahd = 'HD01';
SELECT * FROM Hang;
