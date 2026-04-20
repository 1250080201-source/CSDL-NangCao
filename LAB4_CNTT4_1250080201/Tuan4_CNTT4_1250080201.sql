CREATE OR REPLACE VIEW vw_class_availability AS
SELECT cl.classid, cl.courseno, co.description,
       i.firstname || ' ' || i.lastname AS ten_giao_vien,
       cl.capacity,
       COUNT(e.studentid) AS so_da_dk,
       cl.capacity - COUNT(e.studentid) AS cho_trong,
       CASE
           WHEN cl.capacity - COUNT(e.studentid) > 0 THEN 'Con cho'
           ELSE 'Het cho'
       END AS trang_thai
FROM class cl
JOIN course co ON cl.courseno = co.courseno
JOIN instructor i ON cl.instructorid = i.instructorid
LEFT JOIN enrollment e ON cl.classid = e.classid
GROUP BY cl.classid, cl.courseno, co.description, i.firstname, i.lastname, cl.capacity
HAVING cl.capacity - COUNT(e.studentid) > 0
ORDER BY cl.classid;

CREATE OR REPLACE VIEW vw_top5_courses AS
SELECT courseno, description, cost, tong_dk, hang
FROM (
    SELECT co.courseno, co.description, co.cost,
           COUNT(e.studentid) AS tong_dk,
           RANK() OVER (ORDER BY COUNT(e.studentid) DESC) AS hang
    FROM course co
    LEFT JOIN class cl ON co.courseno = cl.courseno
    LEFT JOIN enrollment e ON cl.classid = e.classid
    GROUP BY co.courseno, co.description, co.cost
)
WHERE hang <= 5
WITH READ ONLY;

CREATE OR REPLACE VIEW vw_pending_enrollment AS
SELECT studentid, classid, enrolldate, finalgrade,
       createdby, createddate, modifiedby, modifieddate
FROM enrollment
WHERE finalgrade IS NULL
WITH CHECK OPTION;


CREATE OR REPLACE PROCEDURE enroll_student
(
    p_studentid IN NUMBER,
    p_classid IN NUMBER
)
IS
    v_check NUMBER;
    v_capacity NUMBER;
    v_enrolled NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check FROM student WHERE studentid = p_studentid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien ' || p_studentid || ' khong ton tai!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM class WHERE classid = p_classid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Lop hoc ' || p_classid || ' khong ton tai!');
        RETURN;
    END IF;

    SELECT capacity INTO v_capacity FROM class WHERE classid = p_classid;
    SELECT COUNT(*) INTO v_enrolled FROM enrollment WHERE classid = p_classid;
    IF v_enrolled >= v_capacity THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Lop ' || p_classid || ' da day! (' || v_enrolled || '/' || v_capacity || ')');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM enrollment
    WHERE studentid = p_studentid AND classid = p_classid;
    IF v_check > 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da dang ky lop nay roi!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM enrollment WHERE studentid = p_studentid;
    IF v_check >= 3 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da dang ky du 3 lop!');
        RETURN;
    END IF;

    INSERT INTO enrollment (studentid, classid, enrolldate, createdby, createddate, modifiedby, modifieddate)
    VALUES (p_studentid, p_classid, SYSDATE, USER, SYSDATE, USER, SYSDATE);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Dang ky thanh cong! SV ' || p_studentid || ' -> Lop ' || p_classid);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[LOI HE THONG] ' || SQLERRM);
END enroll_student;
/

CREATE OR REPLACE PROCEDURE update_final_grade
(
    p_studentid IN NUMBER,
    p_classid IN NUMBER,
    p_grade IN NUMBER
)
IS
    v_check NUMBER;
    v_old_grade NUMBER;
BEGIN
    IF p_grade < 0 OR p_grade > 100 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Diem khong hop le! Phai tu 0 den 100.');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM enrollment
    WHERE studentid = p_studentid AND classid = p_classid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien chua dang ky lop nay!');
        RETURN;
    END IF;

    SELECT finalgrade INTO v_old_grade FROM enrollment
    WHERE studentid = p_studentid AND classid = p_classid;

    UPDATE enrollment
    SET finalgrade = p_grade,
        modifiedby = USER, modifieddate = SYSDATE
    WHERE studentid = p_studentid AND classid = p_classid;

    MERGE INTO grade g
    USING (SELECT p_studentid AS sid, p_classid AS cid FROM DUAL) src
    ON (g.studentid = src.sid AND g.classid = src.cid)
    WHEN MATCHED THEN
        UPDATE SET g.grade = p_grade,
                   g.modifiedby = USER, g.modifieddate = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (studentid, classid, grade, createdby, createddate, modifiedby, modifieddate)
        VALUES (p_studentid, p_classid, p_grade, USER, SYSDATE, USER, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Da cap nhat diem SV ' || p_studentid || ' lop ' || p_classid || ': Cu=' || NVL(TO_CHAR(v_old_grade),'NULL') || ' -> Moi=' || p_grade);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[LOI] ' || SQLERRM);
END update_final_grade;
/

CREATE OR REPLACE PROCEDURE transfer_student
(
    p_studentid IN NUMBER,
    p_old_classid IN NUMBER,
    p_new_classid IN NUMBER
)
IS
    v_check NUMBER;
    v_capacity NUMBER;
    v_enrolled NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check FROM enrollment
    WHERE studentid = p_studentid AND classid = p_old_classid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien khong dang hoc lop ' || p_old_classid);
        RETURN;
    END IF;

    SELECT capacity INTO v_capacity FROM class WHERE classid = p_new_classid;
    SELECT COUNT(*) INTO v_enrolled FROM enrollment WHERE classid = p_new_classid;
    IF v_enrolled >= v_capacity THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Lop moi ' || p_new_classid || ' da day!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_check FROM enrollment
    WHERE studentid = p_studentid AND classid = p_new_classid;
    IF v_check > 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da o trong lop moi roi!');
        RETURN;
    END IF;

    SAVEPOINT sp_truoc_chuyen;

    DELETE FROM grade WHERE studentid = p_studentid AND classid = p_old_classid;

    DELETE FROM enrollment WHERE studentid = p_studentid AND classid = p_old_classid;

    INSERT INTO enrollment (studentid, classid, enrolldate, createdby, createddate, modifiedby, modifieddate)
    VALUES (p_studentid, p_new_classid, SYSDATE, USER, SYSDATE, USER, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Da chuyen SV ' || p_studentid || ' tu lop ' || p_old_classid || ' sang lop ' || p_new_classid);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_truoc_chuyen;
        DBMS_OUTPUT.PUT_LINE('[LOI] Chuyen lop that bai: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Da rollback ve trang thai ban dau.');
END transfer_student;
/

CREATE OR REPLACE PROCEDURE report_class_detail
(p_classid IN NUMBER)
IS
    v_check NUMBER;
    v_course VARCHAR2(50);
    v_courseno NUMBER;
    v_gv VARCHAR2(50);
    v_loc VARCHAR2(50);
    v_cap NUMBER;
    v_stt NUMBER := 0;
    v_tong NUMBER := 0;
    v_sum_d NUMBER := 0;
    v_co_d NUMBER := 0;
    v_grade_txt VARCHAR2(15);
BEGIN
    SELECT COUNT(*) INTO v_check FROM class WHERE classid = p_classid;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Lop hoc ' || p_classid || ' khong ton tai!');
        RETURN;
    END IF;

    SELECT co.description, co.courseno,
           i.firstname || ' ' || i.lastname,
           cl.location, cl.capacity
    INTO v_course, v_courseno, v_gv, v_loc, v_cap
    FROM class cl
    JOIN course co ON cl.courseno = co.courseno
    LEFT JOIN instructor i ON cl.instructorid = i.instructorid
    WHERE cl.classid = p_classid;

    DBMS_OUTPUT.PUT_LINE('=== BAO CAO LOP HOC: ' || p_classid || ' ===');
    DBMS_OUTPUT.PUT_LINE('Mon hoc  : ' || v_courseno || ' - ' || v_course);
    DBMS_OUTPUT.PUT_LINE('Giao vien: ' || NVL(v_gv, 'Chua phan cong'));
    DBMS_OUTPUT.PUT_LINE('Phong hoc: ' || NVL(v_loc, 'Chua xep phong'));
    DBMS_OUTPUT.PUT_LINE('Suc chua : ' || NVL(TO_CHAR(v_cap), 'Chua xac dinh') || ' cho');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));
    DBMS_OUTPUT.PUT_LINE('DANH SACH SINH VIEN:');
    DBMS_OUTPUT.PUT_LINE(RPAD('STT', 4) || ' | ' || RPAD('Ho Ten', 20) || ' | ' || LPAD('Diem TK', 8) || ' | Xep loai');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));

    FOR rec IN (
        SELECT s.firstname || ' ' || s.lastname AS ho_ten, e.finalgrade
        FROM enrollment e
        JOIN student s ON e.studentid = s.studentid
        WHERE e.classid = p_classid
        ORDER BY s.lastname, s.firstname
    ) LOOP
        v_stt := v_stt + 1;
        v_tong := v_tong + 1;

        IF rec.finalgrade IS NULL THEN
            v_grade_txt := 'Chua co diem';
        ELSIF rec.finalgrade >= 90 THEN
            v_grade_txt := 'A'; v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d + 1;
        ELSIF rec.finalgrade >= 80 THEN
            v_grade_txt := 'B'; v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d + 1;
        ELSIF rec.finalgrade >= 70 THEN
            v_grade_txt := 'C'; v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d + 1;
        ELSIF rec.finalgrade >= 50 THEN
            v_grade_txt := 'D'; v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d + 1;
        ELSE
            v_grade_txt := 'F'; v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            LPAD(v_stt, 3) || '  | '
            || RPAD(rec.ho_ten, 20) || ' | '
            || LPAD(NVL(TO_CHAR(rec.finalgrade), 'NULL'), 7) || '  | '
            || v_grade_txt
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));
    DBMS_OUTPUT.PUT_LINE('Tong so sinh vien : ' || v_tong);
    IF v_co_d > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Diem trung binh lop: ' || ROUND(v_sum_d / v_co_d, 2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Diem trung binh lop: Chua co diem');
    END IF;
END report_class_detail;
/


CREATE OR REPLACE TRIGGER trg_check_capacity
BEFORE INSERT ON enrollment
FOR EACH ROW
DECLARE
    v_capacity NUMBER;
    v_enrolled NUMBER;
BEGIN
    SELECT capacity INTO v_capacity
    FROM class WHERE classid = :NEW.classid;

    SELECT COUNT(*) INTO v_enrolled
    FROM enrollment WHERE classid = :NEW.classid;

    IF v_enrolled >= v_capacity THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'LOI: Lop ' || :NEW.classid || ' da day! ('
            || v_enrolled || '/' || v_capacity || ' cho)'
        );
    END IF;
END trg_check_capacity;
/

CREATE OR REPLACE TRIGGER trg_grade_audit_log
AFTER UPDATE OF finalgrade ON enrollment
FOR EACH ROW
BEGIN
    IF (:OLD.finalgrade IS NULL AND :NEW.finalgrade IS NOT NULL)
       OR (:OLD.finalgrade IS NOT NULL AND :NEW.finalgrade IS NULL)
       OR (:OLD.finalgrade != :NEW.finalgrade)
    THEN
        INSERT INTO grade_audit_log
        (studentid, classid, grade_cu, grade_moi, nguoi_sua, thoi_gian)
        VALUES
        (:OLD.studentid, :OLD.classid, :OLD.finalgrade,
         :NEW.finalgrade, USER, SYSDATE);
    END IF;
END trg_grade_audit_log;
/

CREATE OR REPLACE TRIGGER trg_prevent_course_delete
BEFORE DELETE ON course
FOR EACH ROW
DECLARE
    v_so_lop NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_so_lop
    FROM class WHERE courseno = :OLD.courseno;

    IF v_so_lop > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20020,
            'Khong the xoa mon hoc ' || :OLD.courseno ||
            ' (' || :OLD.description || ') ' ||
            'vi con ' || v_so_lop || ' lop hoc dang ton tai!'
        );
    END IF;
END trg_prevent_course_delete;
/

CREATE OR REPLACE TRIGGER trg_update_grade_summary
AFTER INSERT OR UPDATE OR DELETE ON enrollment
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION; 
    
    v_classid NUMBER;
    v_so_sv NUMBER;
    v_diem_tb NUMBER;
    v_max_d NUMBER;
    v_min_d NUMBER;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_classid := :NEW.classid;
    ELSE 
        v_classid := :OLD.classid;
    END IF;

    SELECT COUNT(finalgrade),
           ROUND(AVG(finalgrade), 2),
           MAX(finalgrade),
           MIN(finalgrade)
    INTO v_so_sv, v_diem_tb, v_max_d, v_min_d
    FROM enrollment
    WHERE classid = v_classid AND finalgrade IS NOT NULL;

    MERGE INTO class_grade_summary cgs
    USING (SELECT v_classid AS cid FROM DUAL) src
    ON (cgs.classid = src.cid)
    WHEN MATCHED THEN
        UPDATE SET
            so_sv = v_so_sv,
            diem_tb = v_diem_tb,
            diem_cao_nhat = v_max_d,
            diem_thap_nhat = v_min_d,
            cap_nhat_luc = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (classid, so_sv, diem_tb, diem_cao_nhat, diem_thap_nhat, cap_nhat_luc)
        VALUES (v_classid, v_so_sv, v_diem_tb, v_max_d, v_min_d, SYSDATE);
        
    COMMIT; 
END trg_update_grade_summary;
/