set serveroutput on;
--2��
DECLARE
    v_dname departments.department_name%TYPE;
    v_jobid employees.job_id%TYPE;
    v_sal employees.salary%TYPE;
    v_annsal employees.salary%TYPE;
BEGIN
    SELECT d.department_name, e.job_id, e.salary, e.salary*12+(salary*nvl(commission_pct, 0)*12) annsal
    INTO v_dname, v_jobid, v_sal, v_annsal
    FROM departments d, employees e
    WHERE d.department_id = e.department_id
    AND e.employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('�μ��̸� : ' || v_dname || ', ' || 'job_id : ' || v_jobid || ', ' ||
    '�޿� : ' || v_sal || ', ' || '���� �� ���� : ' || v_annsal);
END;
/

--3��
DECLARE
    v_hiredate employees.hire_date%TYPE;
BEGIN
    SELECT hire_date
    INTO v_hiredate
    FROM employees
    WHERE employee_id = 202;
    
    IF to_char(v_hiredate, 'YYYY') >= '1998' THEN
        DBMS_OUTPUT.PUT_LINE('New employee');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Career employee');
    END IF;
END;
/

DECLARE
    v_hiredate employees.hire_date%TYPE;
BEGIN
    SELECT hire_date
    INTO v_hiredate
    FROM employees
    WHERE employee_id = &id;
    
    IF to_char(v_hiredate, 'YYYY') >= '1998' THEN
        DBMS_OUTPUT.PUT_LINE('New employee');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Career employee');
    END IF;
END;
/

--4��
BEGIN
    FOR v_no IN 1..9 LOOP
        FOR i IN 1..9 LOOP
            IF mod(v_no, 2) = 1 THEN
                DBMS_OUTPUT.PUT_LINE(v_no || ' * ' || i || ' = ' || v_no * i);
            END IF;
        END LOOP;
    END LOOP;
END;
/

--5��
DECLARE
    CURSOR emp_cursor IS
    SELECT employee_id, last_name, salary
    FROM employees
    WHERE department_id = &id;
BEGIN
    FOR emp_rec IN emp_cursor
    LOOP
        DBMS_OUTPUT.PUT_LINE('��� : ' || emp_rec.employee_id || ', ' || '�̸� : ' || emp_rec.last_name || ', ' || '�޿� : ' || emp_rec.salary);
    END LOOP;
END;
/

--6��
CREATE OR REPLACE PROCEDURE raise_salary
    (v_id employees.employee_id%TYPE,
     v_pct NUMBER)
IS
    no_data EXCEPTION;
BEGIN
    UPDATE employees
    SET salary = salary * (1+ v_pct/100)
    WHERE employee_id = v_id;
    IF SQL%NOTFOUND THEN
        RAISE no_data;
    END IF;
EXCEPTION
    WHEN no_data THEN
        DBMS_OUTPUT.PUT_LINE('No search employee!!');
END raise_salary;
/
EXECUTE raise_salary(203, 10);

--7��
CREATE OR REPLACE PACKAGE p_jumin
IS
    FUNCTION age
        (p_age VARCHAR2)
    RETURN VARCHAR2;
    
    FUNCTION sex
        (p_sex VARCHAR2)
    RETURN VARCHAR2;
END p_jumin;
/

CREATE OR REPLACE PACKAGE BODY p_jumin
IS
    FUNCTION age
        (p_age VARCHAR2)
    RETURN VARCHAR2
    IS
        v_age VARCHAR2(20);
    BEGIN
        IF substr(p_age, 7, 1) IN (1, 2) THEN
            v_age := to_char(sysdate, 'yyyy')-(1900 + substr(p_age, 1, 2) + 1);
        ELSE
            v_age := to_char(sysdate, 'yyyy')-(2000 + substr(p_age, 1, 2) + 1);
        END IF;
    RETURN v_age;
    END age;
    
    FUNCTION sex
        (p_sex VARCHAR2)
    RETURN VARCHAR2
    IS
        v_sex VARCHAR2(20);
    BEGIN
        IF substr(p_sex, 7, 1) IN (1, 3) THEN
            v_sex := '����';
        ELSE
            v_sex := '����';
        END IF;
    RETURN v_sex;
    END sex;
END p_jumin;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_age('9911021234567'));
EXECUTE DBMS_OUTPUT.PUT_LINE(yd_pkg.y_sex('9911021234567'));

--8��
CREATE OR REPLACE FUNCTION f_work
    (p_id employees.employee_id%TYPE)
    RETURN NUMBER
IS
    v_hiredate VARCHAR2(20);
BEGIN
    SELECT hire_date
    INTO v_hiredate
    FROM employees
    WHERE employee_id = p_id;
    
    RETURN TRUNC(months_between(sysdate, v_hiredate)/12,0);
END f_work;
/
EXECUTE DBMS_OUTPUT.PUT_LINE('�ٹ��� ��� : ' || f_work(100));

--9��
CREATE OR REPLACE FUNCTION f_manager
    (p_name departments.department_name%TYPE)
    RETURN VARCHAR2
IS
    v_name VARCHAR2(20);
BEGIN
    SELECT e.last_name
    INTO v_name
    FROM departments d, employees e
    WHERE d.department_name = p_name
    AND e.employee_id = d.manager_id;
    RETURN v_name;
END f_manager;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(f_manager('Marketing'));

--10��
--PROCEDURE
SELECT DISTINCT(name)
FROM user_source
WHERE TYPE = 'PROCEDURE';

SELECT text
FROM user_source
WHERE name='Y_PROC'; 

--FUNCTION
SELECT DISTINCT(name)
FROM user_source
WHERE TYPE = 'FUNCTION';

SELECT text
FROM user_source
WHERE name='Y_TEST'; 

--PACKAGE
SELECT DISTINCT(name)
FROM user_source
WHERE TYPE = 'PACKAGE';

SELECT text
FROM user_source
WHERE name='EMP_PKG'; 

--PACKAGE BODY
SELECT DISTINCT(name)
FROM user_source
WHERE TYPE = 'PACKAGE BODY';

SELECT text
FROM user_source
WHERE name='EMP_PKG';

--11��
DECLARE
    v_num NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(LPAD('-', 10 - v_num, '-'), 10, '*'));  
        v_num := v_num + 1;
        EXIT WHEN v_num > 10;
    END LOOP;
END;
/