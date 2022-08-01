set serveroutput on;

--���� �Լ�(����� ���� �Լ�)
create or replace function get_sal
    (p_id employees.employee_id%TYPE)
    return number
IS
    v_sal employees.salary%TYPE := 0;
BEGIN
    select salary
    into v_sal
    from employees
    where employee_id = p_id;
    return v_sal;
END get_sal;
/
--�����ȣ 100���� �޿�
EXECUTE DBMS_OUTPUT.PUT_LINE(get_sal(100));

--������ �������� �Լ� ��� ����
DECLARE
    sal employees.salary%TYPE;
BEGIN
    sal := get_sal(100);
    DBMS_OUTPUT.PUT_LINE('The salary is : ' || sal);
END;
/

select job_id, get_sal(employee_id) as "SALARY"
from employees;

--tax �Լ� ����
CREATE OR REPLACE FUNCTION tax
    (p_value IN NUMBER)
    RETURN NUMBER
IS
BEGIN
    RETURN(p_value * 0.08);
END tax;
/

SELECT employee_id, last_name, salary, tax(salary)
FROM employees
where department_id = 100;

/* 1.���ڸ� �Է��� ��� �Էµ� ���ڱ����� ������ �հ踦 ����ϴ� �Լ��� �ۼ��Ͻÿ�.
���� ��) EXECUTE DBMS_OUTPUT.PUT_LINE(ydsum(10)) */
CREATE OR REPLACE FUNCTION ydsum
    (p_nu IN NUMBER)
    RETURN NUMBER
IS
    v_sum number := 0;
BEGIN
    for i IN 1..p_nu LOOP
        v_sum := v_sum + i;
    END LOOP;
    RETURN v_sum;
END ydsum;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(ydsum(10));

/* 2.�����ȣ�� �Է��� ��� ���� ������ �����ϴ� ����� ��µǴ� ydinc �Լ��� �����Ͻÿ�.
- �޿��� 5000 �����̸� 20% �λ�� �޿� ���
- �޿��� 10000 �����̸� 15% �λ�� �޿� ���
- �޿��� 20000 �����̸� 10% �λ�� �޿� ���
- �޿��� 20000 �̻��̸� �޿� �״�� ���
����) SELECT last_name, salary, YDINC(employee_id)
     FROM   employees; */
create or replace function ydinc
    (p_id employees.employee_id%TYPE)
    return number
IS
    v_sal employees.salary%TYPE;
BEGIN
    select salary
    into v_sal
    from employees
    where employee_id = p_id;
    
    if v_sal <= 5000 then
        v_sal := v_sal * 1.20;
    elsif v_sal <= 10000 then
        v_sal := v_sal * 1.15;
    elsif v_sal <= 20000 then
        v_sal := v_sal * 1.10;
    else v_sal := v_sal;
    end if;
    RETURN v_sal;
END ydinc;
/

SELECT last_name, salary, YDINC(employee_id)
FROM   employees;

/* 3.�����ȣ�� �Է��ϸ� �ش� ����� ������ ��µǴ� yd_func �Լ��� �����Ͻÿ�.
->������� : (�޿�+(�޿�*�μ�Ƽ���ۼ�Ʈ))*12
����) SELECT last_name, salary, YD_FUNC(employee_id)
     FROM   employees; */
create or replace function yd_func
    (p_id employees.employee_id%TYPE)
    return number
IS
    v_ann employees.salary%TYPE;
BEGIN
    select salary+(salary+nvl(commission_pct,0))*12
    into v_ann
    from employees
    where employee_id = p_id;
    return v_ann;
END yd_func;
/

SELECT last_name, salary, YD_FUNC(employee_id) as "����"
FROM   employees;

/* 4.SELECT last_name, subname(last_name)
FROM   employees;
LAST_NAME     SUBNAME(LA
------------ ------------
King         K***
Smith        S****
������ ���� ��µǴ� subname �Լ��� �ۼ��Ͻÿ�. */
create or replace function subname
    (p_name employees.last_name%TYPE)
    return varchar2
IS
BEGIN
    return RPAD(substr(p_name, 1, 1), length(p_name), '*');
END subname;
/ 
    
SELECT last_name, subname(last_name)
FROM   employees;

/* 5.�����ȣ�� �Է��ϸ� �λ�� �޿��� ��µǵ��� inc_sal �Լ� �����Ͻÿ�. */
create or replace function inc_sal
    (p_id employees.employee_id%TYPE,
    p_pct number)
    return number
IS
    v_sal employees.salary%TYPE;
BEGIN
    select salary
    into v_sal
    from employees
    where employee_id = p_id;
    return v_sal * (1 + p_pct/100);
END inc_sal;
/

SELECT last_name, salary, inc_sal(employee_id, 10)
FROM   employees;
EXECUTE DBMS_OUTPUT.PUT_LINE(inc_sal(100, 10));

/* 1.�����ȣ�� �Է��ϸ�
last_name + first_name �� ��µǴ� 
y_yedam �Լ��� �����Ͻÿ�.
����) EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174))
��� ��)  Abel Ellen */
create or replace function y_yedam
    (p_id employees.employee_id%TYPE)
    return varchar2
IS
    v_lname employees.last_name%TYPE;
    v_fname employees.first_name%TYPE;
BEGIN
    select last_name, first_name
    into v_lname, v_fname
    from employees
    where employee_id = p_id;
    return v_lname || ' ' || v_fname;
end y_yedam;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174));
SELECT employee_id, y_yedam(employee_id)
FROM   employees;

/* 2-1.�����ȣ�� �Է��ϸ� �Ҽ� �μ��� ����ϴ� y_dept �Լ��� �����Ͻÿ�.
(��, ������ ���� ��� ����ó��(exception)
 �Էµ� ����� ���ų� �Ҽ� �μ��� ���� ��� -> ����� �ƴϰų� �Ҽ� �μ��� �����ϴ�.) */
create or replace function y_dept
    (p_id employees.employee_id%TYPE)
    return varchar2
IS
    no_data EXCEPTION;
    v_dname departments.department_name%TYPE;
    v_eid employees.employee_id%TYPE;
BEGIN
    select d.department_name, e.employee_id
    into v_dname, v_eid
    from departments d, employees e
    where d.department_id = e.department_id
    and e.employee_id = p_id;
    return v_dname;
EXCEPTION
    when no_data_found then
        return '����� �ƴϰų� �Ҽ� �μ��� �����ϴ�.';
END y_dept;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(200));
/

/* 3.�μ���ȣ�� �Է��� ���
�μ��� ���� ����� ����̸�, �μ��̸��� ����ϴ� y_test �Լ��� �����Ͻÿ�.
��, �Ҽӵ� �μ��� ����� ���� ��� ����ó��(�Ҽӵ� ����� �����ϴ�.) */
create or replace function y_test
    (p_deptno employees.department_id%TYPE)
    return varchar2
IS
    cursor emp_cursor is
        select e.last_name, d.department_name
        from departments d, employees e
        where e.department_id = d.department_id
        and e.department_id = p_deptno;
        no_data exception;
    v_name varchar2(4000);
    v_count number(10) := 0;
BEGIN
    for emp_rec in emp_cursor
    LOOP
        v_name := v_name || '����̸� : ' || emp_rec.last_name ||
        ', �μ��� : ' || emp_rec.department_name || chr(13); --chr(13) = �� �ٲ�
        v_count := v_count + 1;
    END LOOP;
    
    if v_count = 0 then
        raise no_data;
    END IF;
    return v_name;
EXCEPTION
    when no_data then
        return '�Ҽӵ� ����� �����ϴ�.';
END y_test;
/
execute dbms_output.put_line(y_test(50));