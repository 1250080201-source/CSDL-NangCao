-- BÀI 1: KHỐI LỆNH PL/SQL CƠ BẢN - TRANSACTION VÀ SAVEPOINT
-- Câu 1a: Tạo bảng Cau1
CREATE TABLE Cau1 (
    ID NUMBER,
    NAME VARCHAR2(50)
);

-- Câu 1b: Tạo sequence Cau1Seq
CREATE SEQUENCE Cau1Seq
    START WITH 5
    INCREMENT BY 5;

-- Câu 1c - 1j: Transaction, Savepoint, Rollback
DECLARE
    v_name VARCHAR2(50);
    v_id NUMBER;
BEGIN
    -- [d] Them sinh vien dang ki nhieu mon nhat
    SELECT firstname || ' ' || lastname INTO v_name
    FROM student
    WHERE studentid = (
        SELECT studentid FROM enrollment
        GROUP BY studentid
        HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM enrollment GROUP BY studentid)
        FETCH FIRST 1 ROWS ONLY
    );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT sp_a; 

    -- [e] Them sinh vien dang ki it mon nhat
    SELECT firstname || ' ' || lastname INTO v_name
    FROM student
    WHERE studentid = (
        SELECT studentid FROM enrollment
        GROUP BY studentid
        HAVING COUNT(*) = (SELECT MIN(COUNT(*)) FROM enrollment GROUP BY studentid)
        FETCH FIRST 1 ROWS ONLY
    );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT sp_b; 

    -- [f] Them giao vien day nhieu lop nhat
    SELECT i.firstname || ' ' || i.lastname INTO v_name
    FROM instructor i
    WHERE i.instructorid = (
        SELECT instructorid FROM class
        GROUP BY instructorid
        HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM class GROUP BY instructorid)
        FETCH FIRST 1 ROWS ONLY
    );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT sp_c; 

    -- [g] Lay ID cua giao vien vua them
    SELECT ID INTO v_id FROM Cau1 WHERE NAME = v_name;
    DBMS_OUTPUT.PUT_LINE('ID giao vien nhieu lop: ' || v_id);

    -- [h] Rollback ve Savepoint B
    ROLLBACK TO sp_b;

    -- [i] Them giao vien it lop nhat, dung v_id da luu
    SELECT i.firstname || ' ' || i.lastname INTO v_name
    FROM instructor i
    WHERE i.instructorid = (
        SELECT instructorid FROM class
        GROUP BY instructorid
        HAVING COUNT(*) = (SELECT MIN(COUNT(*)) FROM class GROUP BY instructorid)
        FETCH FIRST 1 ROWS ONLY
    );
    INSERT INTO Cau1 (ID, NAME) VALUES (v_id, v_name); 

    -- [j] Them lai giao vien nhieu lop, dung sequence
    SELECT i.firstname || ' ' || i.lastname INTO v_name
    FROM instructor i
    WHERE i.instructorid = (
        SELECT instructorid FROM class
        GROUP BY instructorid
        HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM class GROUP BY instructorid)
        FETCH FIRST 1 ROWS ONLY
    );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name); 

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Hoan tat! Kiem tra: SELECT * FROM Cau1;');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Loi: Khong tim thay du lieu!');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Loi: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Câu 2: Nhập mã sinh viên, kiểm tra và thêm mới
DECLARE
    v_sid NUMBER := &ma_sinh_vien;
    v_fname VARCHAR2(25) := '&ho_sinh_vien';
    v_lname VARCHAR2(25) := '&ten_sinh_vien';
    v_addr VARCHAR2(50) := '&dia_chi';
    v_found VARCHAR2(50);
    v_classes NUMBER;
BEGIN
    SELECT firstname || ' ' || lastname INTO v_found
    FROM student WHERE studentid = v_sid;

    SELECT COUNT(*) INTO v_classes
    FROM enrollment WHERE studentid = v_sid;

    DBMS_OUTPUT.PUT_LINE('Ho ten: ' || v_found);
    DBMS_OUTPUT.PUT_LINE('So lop dang hoc: ' || v_classes);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Sinh vien chua ton tai. Dang them moi...');
        INSERT INTO student (studentid, firstname, lastname, address, registrationdate, createdby, createddate, modifiedby, modifieddate)
        VALUES (v_sid, v_fname, v_lname, v_addr, SYSDATE, USER, SYSDATE, USER, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Da them sinh vien moi: ' || v_fname || ' ' || v_lname);
END;
/
-- BÀI 2: CẤU TRÚC ĐIỀU KHIỂN (IF, CASE)
-- Câu 1: Kiểm tra số lớp giáo viên đang dạy
DECLARE
    v_instructor_id NUMBER := &ma_giao_vien;
    v_so_lop NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_so_lop
    FROM class WHERE instructorid = v_instructor_id;

    IF v_so_lop >= 5 THEN
        DBMS_OUTPUT.PUT_LINE('Giao vien nay nen nghi ngoi!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('So lop giao vien dang day: ' || v_so_lop);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Khong tim thay giao vien co ma: ' || v_instructor_id);
END;
/

-- Câu 2: Chuyển đổi điểm số sang điểm chữ
DECLARE
    v_sid NUMBER := &ma_sinh_vien;
    v_cid NUMBER := &ma_lop;
    v_score NUMBER;
    v_grade VARCHAR2(2);
    v_check NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check FROM student WHERE studentid = v_sid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Loi: Ma sinh vien ' || v_sid || ' khong ton tai!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM class WHERE classid = v_cid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Loi: Ma lop ' || v_cid || ' khong ton tai!');
        RETURN;
    END IF;

    SELECT finalgrade INTO v_score FROM enrollment
    WHERE studentid = v_sid AND classid = v_cid;

    CASE
        WHEN v_score >= 90 THEN v_grade := 'A';
        WHEN v_score >= 80 THEN v_grade := 'B';
        WHEN v_score >= 70 THEN v_grade := 'C';
        WHEN v_score >= 50 THEN v_grade := 'D';
        ELSE v_grade := 'F';
    END CASE;

    DBMS_OUTPUT.PUT_LINE('Diem so: ' || v_score || ' -> Diem chu: ' || v_grade);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Sinh vien chua dang ky lop nay hoac chua co diem!');
END;
/
-- BÀI 3: CURSOR - DUYỆT TẬP KẾT QUẢ
DECLARE
    CURSOR cur_course IS
        SELECT courseno, description FROM course ORDER BY courseno;
        
    CURSOR cur_class (p_courseno NUMBER) IS
        SELECT c.classno, COUNT(e.studentid) AS so_sv
        FROM class c
        LEFT JOIN enrollment e ON c.classid = e.classid
        WHERE c.courseno = p_courseno
        GROUP BY c.classno
        ORDER BY c.classno;

    v_courseno course.courseno%TYPE;
    v_desc course.description%TYPE;
    v_classno class.classno%TYPE;
    v_count NUMBER;
BEGIN
    OPEN cur_course;
    LOOP
        FETCH cur_course INTO v_courseno, v_desc;
        EXIT WHEN cur_course%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_courseno || ' ' || v_desc);

        OPEN cur_class(v_courseno);
        LOOP
            FETCH cur_class INTO v_classno, v_count;
            EXIT WHEN cur_class%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('  Lop: ' || v_classno || ' co so luong sinh vien dang ki: ' || v_count);
        END LOOP;
        CLOSE cur_class;
    END LOOP;
    CLOSE cur_course;
EXCEPTION
    WHEN OTHERS THEN
        IF cur_course%ISOPEN THEN CLOSE cur_course; END IF;
        IF cur_class%ISOPEN THEN CLOSE cur_class; END IF;
        DBMS_OUTPUT.PUT_LINE('Loi: ' || SQLERRM);
END;
/
-- BÀI 4: THỦ TỤC (PROCEDURE) VÀ HÀM (FUNCTION)
-- Câu 4.1a: Thủ tục find_sname
CREATE OR REPLACE PROCEDURE find_sname
    (i_student_id IN student.studentid%TYPE,
     o_first_name OUT student.firstname%TYPE,
     o_last_name OUT student.lastname%TYPE)
IS
BEGIN
    SELECT firstname, lastname INTO o_first_name, o_last_name
    FROM student WHERE studentid = i_student_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        o_first_name := NULL;
        o_last_name := NULL;
        DBMS_OUTPUT.PUT_LINE('Khong tim thay sinh vien ID: ' || i_student_id);
END find_sname;
/

-- Câu 4.1b: Thủ tục print_student_name
CREATE OR REPLACE PROCEDURE print_student_name
    (i_student_id IN student.studentid%TYPE)
IS
    v_first student.firstname%TYPE;
    v_last student.lastname%TYPE;
BEGIN
    find_sname(i_student_id, v_first, v_last);
    IF v_first IS NOT NULL OR v_last IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Ho ten sinh vien: ' || v_first || ' ' || v_last);
    END IF;
END print_student_name;
/

-- Câu 4.2: Thủ tục Discount (Giảm 5% học phí)
CREATE OR REPLACE PROCEDURE Discount
IS
BEGIN
    FOR rec IN (
        SELECT c.courseno, c.description, c.cost
        FROM course c
        WHERE (SELECT COUNT(*) FROM enrollment e
               JOIN class cl ON e.classid = cl.classid
               WHERE cl.courseno = c.courseno) > 15
    ) LOOP
        UPDATE course SET cost = cost * 0.95 WHERE courseno = rec.courseno;
        DBMS_OUTPUT.PUT_LINE('Da giam gia mon hoc: ' || rec.description 
                             || ' | Gia cu: ' || rec.cost 
                             || ' | Gia moi: ' || ROUND(rec.cost * 0.95, 2));
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Hoan tat giam gia.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Loi: ' || SQLERRM);
END Discount;
/

-- Câu 4.3: Hàm Total_cost_for_student
CREATE OR REPLACE FUNCTION Total_cost_for_student
    (p_student_id IN student.studentid%TYPE)
RETURN NUMBER
IS
    v_total NUMBER;
    v_check NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check FROM student WHERE studentid = p_student_id;
    IF v_check = 0 THEN
        RETURN NULL; 
    END IF;

    SELECT NVL(SUM(co.cost), 0) INTO v_total
    FROM enrollment e
    JOIN class cl ON e.classid = cl.classid
    JOIN course co ON cl.courseno = co.courseno
    WHERE e.studentid = p_student_id;

    RETURN v_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Total_cost_for_student;
/
-- BÀI 5: TRIGGER
-- Câu 5.1: 6 Trigger cập nhật Audit Data (Đã fix lỗi dấu gạch dưới)
CREATE OR REPLACE TRIGGER trg_course_audit
BEFORE INSERT OR UPDATE ON course FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_class_audit
BEFORE INSERT OR UPDATE ON class FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_student_audit
BEFORE INSERT OR UPDATE ON student FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_enrollment_audit
BEFORE INSERT OR UPDATE ON enrollment FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_instructor_audit
BEFORE INSERT OR UPDATE ON instructor FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_grade_audit
BEFORE INSERT OR UPDATE ON grade FOR EACH ROW
BEGIN
    IF INSERTING THEN 
        :NEW.createdby := USER; 
        :NEW.createddate := SYSDATE; 
    END IF;
    :NEW.modifiedby := USER; 
    :NEW.modifieddate := SYSDATE;
END;
/

-- Câu 5.2: Trigger giới hạn sinh viên đăng ký tối đa 3 lớp
CREATE OR REPLACE TRIGGER trg_max_enrollment
BEFORE INSERT ON enrollment
FOR EACH ROW
DECLARE
    v_so_lop NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_so_lop FROM enrollment WHERE studentid = :NEW.studentid;
    IF v_so_lop >= 3 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sinh vien ' || :NEW.studentid || ' da dang ky du 3 lop! Khong the dang ky them.');
    END IF;
END;
/