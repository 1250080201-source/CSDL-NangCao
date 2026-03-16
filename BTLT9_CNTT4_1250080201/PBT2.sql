CREATE TABLE Mathang (
    Mahang VARCHAR2(5) CONSTRAINT pk_mathang PRIMARY KEY,
    Tenhang VARCHAR2(50) NOT NULL,
    Soluong NUMBER(10)
);

CREATE TABLE Nhatkybanhang (
    Stt NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Ngay DATE,
    Nguoimua VARCHAR2(50),
    Mahang VARCHAR2(5) REFERENCES Mathang(Mahang),
    Soluong NUMBER(10),
    Giaban NUMBER(15,2)
);

INSERT INTO Mathang VALUES ('1', 'Hang A', 100);
INSERT INTO Mathang VALUES ('2', 'Hang B', 200);
INSERT INTO Mathang VALUES ('3', 'Hang C', 150);
COMMIT;


-- a. Trigger trg_nhatkybanhang_insert
CREATE OR REPLACE TRIGGER trg_nhatkybanhang_insert
AFTER INSERT ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang SET Soluong = Soluong - :NEW.Soluong WHERE Mahang = :NEW.Mahang;
END;
--test
INSERT INTO Nhatkybanhang(Ngay, Nguoimua, Mahang, Soluong, Giaban) VALUES (SYSDATE, 'Khach A', '1', 10, 50000);
SELECT * FROM Mathang;
-- b. Trigger trg_nhatkybanhang_update_soluong
CREATE OR REPLACE TRIGGER trg_nhatkybanhang_update_soluong
AFTER UPDATE OF Soluong ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong) WHERE Mahang = :NEW.Mahang;
END;
--test
UPDATE Nhatkybanhang SET Soluong = 30 WHERE Nguoimua = 'Khach A';
SELECT * FROM Mathang;
-- c. Trigger kiểm tra số lượng hợp lệ (Dùng BEFORE)
CREATE OR REPLACE TRIGGER trg_nkb_check_soluong
BEFORE INSERT ON Nhatkybanhang
FOR EACH ROW
DECLARE
    v_tonkho NUMBER := 0;
BEGIN
    SELECT Soluong INTO v_tonkho FROM Mathang WHERE Mahang = :NEW.Mahang;
    IF :NEW.Soluong > v_tonkho THEN
        RAISE_APPLICATION_ERROR(-20001, 'So luong ban vuot qua ton kho');
    ELSE
        UPDATE Mathang SET Soluong = Soluong - :NEW.Soluong WHERE Mahang = :NEW.Mahang;
    END IF;
END;
--test
INSERT INTO Nhatkybanhang(Ngay, Nguoimua, Mahang, Soluong, Giaban) VALUES (SYSDATE, 'Khach B', '2', 500, 50000);
-- d. Trigger UPDATE kiểm soát số dòng (Compound Trigger)
CREATE OR REPLACE TRIGGER trg_nkb_compound_update
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER
    BEFORE STATEMENT IS
    BEGIN
        pkg_state.g_row_count := 0;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        pkg_state.g_row_count := pkg_state.g_row_count + 1;
        IF pkg_state.g_row_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Chi duoc cap nhat 1 dong');
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        UPDATE Mathang SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong) WHERE Mahang = :NEW.Mahang;
    END AFTER EACH ROW;
END trg_nkb_compound_update;
--test
UPDATE Nhatkybanhang SET Soluong = 50;

-- e. Trigger DELETE kiểm soát số dòng
CREATE OR REPLACE TRIGGER trg_nkb_delete_compound
FOR DELETE ON Nhatkybanhang
COMPOUND TRIGGER
    BEFORE STATEMENT IS
    BEGIN
        pkg_state.g_row_count := 0;
    END BEFORE STATEMENT;
    BEFORE EACH ROW IS
    BEGIN
        pkg_state.g_row_count := pkg_state.g_row_count + 1;
        IF pkg_state.g_row_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Loi: Chi duoc xoa toi da 1 dong!');
        END IF;
    END BEFORE EACH ROW;
    AFTER EACH ROW IS
    BEGIN
        UPDATE Mathang SET Soluong = Soluong + :OLD.Soluong WHERE Mahang = :OLD.Mahang;
    END AFTER EACH ROW;
END trg_nkb_delete_compound;
--test
DELETE FROM Nhatkybanhang WHERE Nguoimua = 'Khach A';
SELECT * FROM Mathang;
-- f. Trigger UPDATE nâng cao – Kiểm tra nhiều điều kiện
CREATE OR REPLACE TRIGGER trg_nkb_update_nangcao
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER
    v_tonkho NUMBER;
    BEFORE STATEMENT IS
    BEGIN
        pkg_state.g_row_count := 0;
    END BEFORE STATEMENT;
    BEFORE EACH ROW IS
    BEGIN
        pkg_state.g_row_count := pkg_state.g_row_count + 1;
        IF pkg_state.g_row_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Loi: Chi duoc cap nhat 1 dong!');
        END IF;
        SELECT Soluong INTO v_tonkho FROM Mathang WHERE Mahang = :NEW.Mahang;
        IF :NEW.Soluong = :OLD.Soluong THEN
            RAISE_APPLICATION_ERROR(-20005, 'So luong khong doi, khong can cap nhat!');
        END IF;
        IF :NEW.Soluong > (v_tonkho + :OLD.Soluong) THEN
            RAISE_APPLICATION_ERROR(-20006, 'Loi: So luong cap nhat vuot qua kha nang cua kho!');
        END IF;
    END BEFORE EACH ROW;
    AFTER EACH ROW IS
    BEGIN
        UPDATE Mathang SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong) WHERE Mahang = :NEW.Mahang;
    END AFTER EACH ROW;
END trg_nkb_update_nangcao;
--test
INSERT INTO Nhatkybanhang(Ngay, Nguoimua, Mahang, Soluong, Giaban) VALUES (SYSDATE, 'Khach C', '3', 20, 10000);
UPDATE Nhatkybanhang SET Soluong = 20 WHERE Nguoimua = 'Khach C';
-- g. Thủ tục xóa MATHANG
CREATE OR REPLACE PROCEDURE sp_xoaMathang(p_mahang IN VARCHAR2) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM Mathang WHERE Mahang = p_mahang;
    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ma hang khong ton tai');
    ELSE
        DELETE FROM Nhatkybanhang WHERE Mahang = p_mahang;
        DELETE FROM Mathang WHERE Mahang = p_mahang;
        DBMS_OUTPUT.PUT_LINE('Da xoa thanh cong');
    END IF;
    COMMIT;
END;
--test
SELECT * FROM Mathang;
EXECUTE sp_xoaMathang('3');
SELECT * FROM Mathang;
SELECT * FROM Nhatkybanhang;
-- h. Hàm tính tổng tiền theo tên hàng
CREATE OR REPLACE FUNCTION fn_TongTien (p_tenhang IN VARCHAR2) RETURN NUMBER AS
    v_tong NUMBER := 0;
BEGIN
    SELECT SUM(nk.Soluong * nk.Giaban) INTO v_tong
    FROM Nhatkybanhang nk
    JOIN Mathang mh ON nk.Mahang = mh.Mahang
    WHERE mh.Tenhang = p_tenhang;
    
    RETURN NVL(v_tong, 0);
END fn_TongTien;
--test
SELECT fn_TongTien('Hang C') AS Tong_Tien FROM DUAL;

