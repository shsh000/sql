--�����ε�(Overload)
--������ �̸�(add_department) ��� ����
--��, �Ű����� ����, ����, ������ ������ �޶�� ��

--��Ű�� ���� ����
CREATE OR REPLACE PACKAGE dept_pkg
IS
PROCEDURE add_department
    (p_deptno departments.department_id%TYPE,
     p_name departments.department_name%TYPE := 'unknown',
     p_loc departments.location_id%TYPE := 1700);
     
PROCEDURE add_department
    (p_name departments.department_name%TYPE := 'unknown',
     p_loc departments.location_id%TYPE := 1700);
END dept_pkg;
/

--��Ű�� �ٵ� ����
CREATE OR REPLACE PACKAGE BODY dept_pkg
IS
PROCEDURE add_department
    (p_deptno departments.department_id%TYPE,
     p_name departments.department_name%TYPE := 'unknown',
     p_loc departments.location_id%TYPE := 1700)
IS
BEGIN
    INSERT INTO departments(department_id, department_name, location_id)
    VALUES (p_deptno, p_name, p_loc);
END add_department;
PROCEDURE add_department
    (p_name departments.department_name%TYPE := 'unknown',
     p_loc departments.location_id%TYPE := 1700)
IS
BEGIN
    INSERT INTO departments(department_id, department_name, location_id)
    VALUES (departments_seq.NEXTVAL, p_name, p_loc);
END add_department;
END dept_pkg;
/

--ù��° ���ν��� ȣ��
EXECUTE dept_pkg.add_department(980, 'Education', 2500);
--�ι�° ���ν��� ȣ��
EXECUTE dept_pkg.add_department('Training', 2500);
SELECT * FROM departments;
set serveroutput on;

--����� ���� ��Ű�� ����
CREATE OR REPLACE PACKAGE taxes_pack
IS
    FUNCTION tax
        (p_value IN NUMBER)
    RETURN NUMBER;
END taxes_pack;
/

CREATE OR REPLACE PACKAGE BODY taxes_pack
IS
    FUNCTION tax
        (p_value IN NUMBER)
    RETURN NUMBER
    IS
        v_rate NUMBER := 0.08;
    BEGIN
        RETURN (p_value * v_rate);
    END tax;
END taxes_pack;
/
SELECT taxes_pack.tax(salary), salary, last_name
FROM employees;


CREATE OR REPLACE PACKAGE emp_pkg
IS
    TYPE emp_table_type
IS
    TABLE OF employees%ROWTYPE
        INDEX BY BINARY_INTEGER;
    PROCEDURE get_employees(p_emps OUT emp_table_type);
END emp_pkg;
/

CREATE OR REPLACE PACKAGE BODY emp_pkg
IS
    PROCEDURE get_employees(p_emps OUT emp_table_type)
IS
    v_i BINARY_INTEGER := 0;
BEGIN
    FOR emp_record IN (SELECT * FROM employees)
    LOOP
        p_emps(v_i) := emp_record;
        v_i := v_i + 1;
        END LOOP;
    END get_employees;
END emp_pkg;
/

DECLARE
    v_employees emp_pkg.emp_table_type;
BEGIN
    emp_pkg.get_employees(v_employees);
    --DBMS_OUTPUT.PUT_LINE('Emp 5 : ' || v_employees(4).last_name);
    DBMS_OUTPUT.PUT_LINE('Emp 6 : ' || v_employees(6).first_name);
END;
/

/* �ֹι�ȣ(8912011676666)�� �Է��ϸ�
���̿� ������ ����ϴ� yd_pkg ��Ű���� �����Ͻÿ�. 
���� ����ϴ� �������α׷�(y_age)
���� ����ϴ� �������α׷�(y_sex) */
CREATE OR REPLACE PACKAGE yd_pkg
IS
    FUNCTION y_age
        (p_age VARCHAR2)
    RETURN VARCHAR2;
    FUNCTION y_sex
        (p_sex VARCHAR2)
    RETURN VARCHAR2;
END yd_pkg;
/

CREATE OR REPLACE PACKAGE BODY yd_pkg
IS
    FUNCTION y_age
        (p_age VARCHAR2)
    RETURN VARCHAR2
    IS
        v_age VARCHAR2(20);
    BEGIN
        IF substr(p_age, 7, 1) IN ('1', '2') THEN
            v_age := to_char(sysdate, 'yyyy')-(1900 + substr(p_age, 1, 2) + 1);
        ELSE
            v_age := to_char(sysdate, 'yyyy')-(2000 + substr(p_age, 1, 2) + 1);
        END IF;
    RETURN v_age;
    END y_age;
    
    FUNCTION y_sex
        (p_sex VARCHAR2)
    RETURN VARCHAR2
    IS
        v_sex VARCHAR2(20);
    BEGIN
         IF substr(p_sex, 7, 1) IN ('1', '3') THEN
            v_sex := '����';
        ELSE
            v_sex := '����';
        END IF;
    RETURN v_sex;
    END y_sex;
END yd_pkg;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_age('8912011676666'));
EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_age('0012013676666'));
EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_sex('8912011676666'));
EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_sex('0012014676666'));

--Ʈ����(Trigger)
--��, �Ͽ����̳� 08��~18�� ���̿� INSERT ����
CREATE OR REPLACE TRIGGER secure_emp
BEFORE INSERT ON departments
BEGIN
    IF (to_char(sysdate, 'DY') IN ('��', '��')) OR
       (to_char(sysdate, 'HH24:MI')
       NOT BETWEEN '08:00' ANd '18:00') THEN
    RAISE_APPLICATION_ERROR(-20500, '�Է� �� ��');
    END IF;
END;
/

INSERT INTO departments(department_id, department_name)
VALUES (444, 'YD');

--Ʈ���� �̺�Ʈ ����(INSERTING, UPDATING, DELETING)
CREATE OR REPLACE TRIGGER secure_emp
BEFORE
INSERT OR UPDATE OR DELETE ON departments
BEGIN
    IF (to_char(sysdate, 'DY') IN ('��', '��')) OR
       (to_char(sysdate, 'HH24:MI')
       NOT BETWEEN '08:00' ANd '18:00') THEN
       IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20502, '���� �� ��');
       ELSIF INSERTING THEN
            RAISE_APPLICATION_ERROR(-20500, '���� �� ��');
       ELSIF UPDATING('department_name') THEN
            RAISE_APPLICATION_ERROR(-20503, '���� �� ��');
       ELSE RAISE_APPLICATION_ERROR(-20504, '�۾� �� ��');
       END IF;
    END IF;
END;
/
--���� �� ��
INSERT INTO departments(department_id, department_name)
VALUES (555, 'YD');
--���� �� ��
UPDATE departments
SET department_name = 'Yedam'
WHERE department_id = 444;
--�۾� �� ��(updating�� location_id ����)
UPDATE departments
SET location_id = '1700'
WHERE department_id = 444;
--���� �� ��
DELETE departments
WHERE department_id = 444;

DROP TRIGGER secure_emp;

--�� Ʈ����
CREATE OR REPLACE TRIGGER restrict_salary
BEFORE
INSERT OR UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.job_id IN ('AD_PRES', 'AD_VP')
        AND :NEW.salary > 15000 THEN
        RAISE_APPLICATION_ERROR(-20202, 'Employee cannot earn more than $15,000.');
    END IF;
END;
/
select * from employees;
UPDATE employees
SET salary = 15500
WHERE employee_id = 102;

DROP TRIGGER restrict_salary;

CREATE TABLE audit_emp
    (user_name VARCHAR2(30),
     time_stamp date,
     id NUMBER(6),
     old_last_name VARCHAR2(25),
     new_last_name VARCHAR2(25),
     old_title VARCHAR2(10),
     new_title VARCHAR2(10),
     old_salary NUMBER(8,2),
     new_salary NUMBER(8,2));
/

CREATE OR REPLACE TRIGGER audit_emp_values
AFTER
DELETE OR INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_emp
    VALUES (USER, SYSDATE, :OLD.employee_id,
    :OLD.last_name, :NEW.last_name, :OLD.job_id,
    :NEW.job_id, :OLD.salary, :NEW.salary);
END;
/

DROP TRIGGER audit_emp_values;

INSERT INTO employees (employee_id, last_name, job_id, salary, email, hire_date)
VALUES (999, 'Temp emp', 'SA_REP', 6000, 'TEMPEMP', TRUNC(SYSDATE));

UPDATE employees
SET salary = 7000, last_name = 'Smith'
WHERE employee_id = 999;

SELECT * FROM employees;
SELECT * FROM audit_emp;

--Ʈ���� �ڵ� ǥ��
SELECT trigger_name, trigger_type, triggering_event,
       table_name, referencing_names, when_clause, status,
       trigger_body
FROM user_triggers;