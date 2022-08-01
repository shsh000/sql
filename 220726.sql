set serveroutput on;

DECLARE
v_myName varchar2(20);
    BEGIN
    DBMS_OUTPUT.PUT_LINE('My name is '|| v_myName);
    v_myname := 'John';
    DBMS_OUTPUT.PUT_LINE('My name is '|| v_myName);
END;
/

DECLARE
v_myName varchar2(20) := 'John';
    BEGIN
    v_myName := 'Steven';
    DBMS_OUTPUT.PUT_LINE('My name is '|| v_myName);
END;
/

--����� ������� ���̺� �÷����� ������ X
--���� �޽����� �� ������ ����ϸ� X
DECLARE
v_employee_id number(6);
    BEGIN
    select employee_id
    into v_employee_id
    from employees
    where last_name = 'Kochhar';
    DBMS_OUTPUT.PUT_LINE(v_employee_id);
END;
/

--%TYPE => employees ���̺�/hire_date, salary �÷��� ������ Ÿ���� �״�� ������
DECLARE
v_emp_hiredate employees.hire_date%TYPE;
v_emp_salary employees.salary%TYPE;
    BEGIN
    select hire_date, salary
    into v_emp_hiredate, v_emp_salary
    from employees
    where employee_id = 100;
    DBMS_OUTPUT.PUT_LINE('Hire date is ' || v_emp_hiredate);
    DBMS_OUTPUT.PUT_LINE('Salary is ' || v_emp_salary);
END;
/

--ġȯ����
select *
from employees
where employee_id = &id;

select &&id, department_id
from employees
where &id = 100;

select &id, department_id
from employees
where &id = 100;

--���� ���� ����
undefine id;

VARIABLE g_monthly_sal NUMBER;
DECLARE
v_sal NUMBER(9,2) := 12000;
    BEGIN
    :g_monthly_sal := v_sal/12;
END;
/

set autoprint on;
print g_monthly_sal;

VARIABLE b_emp_salary NUMBER;
    BEGIN
    select salary INTO :b_emp_salary
    from employees
    where employee_id = 178;
END;
/

print b_emp_salary;
select first_name, last_name
from employees
where salary =:b_emp_salary;

--������
DECLARE
v_outer_variable varchar2(20) := 'GLOBAL VARIABLE';
BEGIN
    --������
    DECLARE
    v_inner_variable varchar2(20) := 'LOCAL VARIABLE';
    BEGIN
    DBMS_OUTPUT.PUT_LINE(v_inner_variable);
    DBMS_OUTPUT.PUT_LINE(v_outer_variable);
    END;
DBMS_OUTPUT.PUT_LINE(v_outer_variable);
/* ���������� ����� �����̱� ������ ���������� ��� �Ұ�
DBMS_OUTPUT.PUT_LINE(v_inner_variable); */
END;
/

DECLARE
v_weight number(3) := 600;
v_message varchar2(255) := 'Product 10012';
BEGIN
    DECLARE
    v_weight number(7,2) := 50000;
    v_message varchar2(255) := 'Product 11001';
    v_new_locn varchar2(50) := 'Europe';
    BEGIN
    v_weight := v_weight + 1;
    v_new_locn := 'Western ' || v_new_locn;
    DBMS_OUTPUT.PUT_LINE(v_weight);
    DBMS_OUTPUT.PUT_LINE(v_message);
    DBMS_OUTPUT.PUT_LINE(v_new_locn);
    END;
v_weight := v_weight + 1;
v_message := v_message || ' is in stock';
DBMS_OUTPUT.PUT_LINE(v_weight);
DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

DECLARE
v_fname varchar2(25);
    BEGIN
    select first_name
    INTO v_fname
    from employees
    where employee_id = 200;
    DBMS_OUTPUT.PUT_LINE('First Name is ' || v_fname);
END;
/

/*�����ȣ�� �Է�(ġȯ���� ���&)�� ���
����̸�, ����̸�, �μ��̸� ��� */
DECLARE
v_empno employees.employee_id%TYPE;
v_lname employees.last_name%TYPE;
v_dname departments.department_name%TYPE;
    BEGIN
    select e.employee_id, e.last_name, d.department_name
    INTO v_empno, v_lname, v_dname
    from employees e, departments d
    where e.department_id = d.department_id
    and e.employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '����̸� : ' || v_lname || ', ' || '�μ��̸� : ' || v_dname);
END;
/

/*�����ȣ�� �Է�(ġȯ���� ���&)�� ���
����̸�, �޿�, ���� ��� */
DECLARE
v_lname employees.last_name%TYPE;
v_sal employees.salary%TYPE;
v_ann employees.salary%TYPE;
    BEGIN
    select last_name, salary, salary*12+(nvl(salary, 0)*nvl(commission_pct, 0)*12)
    into v_lname, v_sal, v_ann
    from employees
    where employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('����̸� : ' || v_lname);
    DBMS_OUTPUT.PUT_LINE('�޿� : ' || v_sal);
    DBMS_OUTPUT.PUT_LINE('���� : ' || v_ann);
END;
/

/*�����ȣ�� �Է�(ġȯ�������&)�� ���
�Ի����� 2000�� ����(2000�� ����)�̸� 'New employee' ���
2000�� �����̸� 'Career employee' ���*/
DECLARE
v_hiredate varchar2(50);
    BEGIN
    select case when to_char(hire_date, 'YYYY') >= '2000' then 'New employee'
    else 'Career employee'
    end
    into v_hiredate
    from employees
    where employee_id = &id;
    DBMS_OUTPUT.PUT_LINE(v_hiredate);
END;
/

--�����ȣ 176�� �� ����
--SQL%ROWCOUNT : ���� �ֱ� SQL���� ����� ���� ����
DECLARE
v_rows_deleted varchar2(30);
v_empno employees.employee_id%TYPE := 176;
    BEGIN
    delete from employees
    where employee_id = v_empno;
    v_rows_deleted := (SQL%ROWCOUNT || ' row deleted.');
    DBMS_OUTPUT.PUT_LINE(v_rows_deleted);
END;
/

DECLARE
v_myage number := &no;
    BEGIN
    if v_myage < 11 then
    DBMS_OUTPUT.PUT_LINE('I am a child');
    end if;
end;
/

DECLARE
v_myage number := &no;
    BEGIN
    if v_myage < 11 then
    DBMS_OUTPUT.PUT_LINE('I am a child');
    else
    DBMS_OUTPUT.PUT_LINE('I am not a child');
    end if;
end;
/

DECLARE
v_myage number := &no;
    BEGIN
    if v_myage < 11 then
    DBMS_OUTPUT.PUT_LINE('I am a child');
    elsif v_myage < 20 then
    DBMS_OUTPUT.PUT_LINE('I am young');
    elsif v_myage < 30 then
    DBMS_OUTPUT.PUT_LINE('I am in my twenties');
    elsif v_myage < 40 then
    DBMS_OUTPUT.PUT_LINE('I am in my thirties');
    else
    DBMS_OUTPUT.PUT_LINE('I am always young');
    end if;
end;
/

DECLARE
v_myage number;
    BEGIN
    if v_myage < 11 then
    DBMS_OUTPUT.PUT_LINE('I am a child');
    else
    DBMS_OUTPUT.PUT_LINE('I am not a child');
    end if;
end;
/

create table test01(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;

create table test02(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;

/*�����ȣ�� �Է�(ġȯ�������&)�� ���
����� �� 2000�� ����(2000�� ����)�� �Ի��� ����� �����ȣ, 
����̸�, �Ի����� test01 ���̺� �Է��ϰ�,
2000�� ������ �Ի��� ����� �����ȣ,����̸�,�Ի����� test02 ���̺� �Է��Ͻÿ�.*/
DECLARE
v_empno employees.employee_id%TYPE;
v_lname employees.last_name%TYPE;
v_hiredate employees.hire_date%TYPE;
    BEGIN
    select employee_id, last_name, hire_date
    into v_empno, v_lname, v_hiredate
    from employees
    where employee_id = &id;
    if to_char(v_hiredate, 'YYYY') >= '2000' then
    insert into test01 values(v_empno, v_lname, v_hiredate);
    else
    insert into test02 values(v_empno, v_lname, v_hiredate);
    end if;
end;
/

DECLARE
v_empno employees.employee_id%TYPE;
v_sal employees.salary%TYPE;
v_salin employees.salary%TYPE;
    BEGIN
    select employee_id, salary
    into v_empno, v_sal
    from employees
    where employee_id = &id;
    if v_sal <= 5000 then
    v_salin := v_sal*1.2;
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '�޿� : ' || v_sal || ', ' || '�λ�� �޿� : ' || v_salin);
    elsif v_sal <= 10000 then
    v_salin := v_sal*1.15;
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '�޿� : ' || v_sal || ', ' || '�λ�� �޿� : ' || v_salin);
    elsif v_sal <= 15000 then
    v_salin := v_sal*1.1;
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '�޿� : ' || v_sal || ', ' || '�λ�� �޿� : ' || v_salin);
    else
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '�޿� : ' || v_sal || ', ' || '�λ�� �޿� : ' || v_salin);
    end if;
end;
/

/*�����ȣ�� �Է��� ���
�ش� ����� �����ϴ� PL/SQL�� �ۼ��Ͻÿ�.
��, �ش����� ���� ��� "�ش����� �����ϴ�." ��� */
BEGIN
    delete from employees
    where employee_id = &id;
    if SQL%NOTFOUND then
    DBMS_OUTPUT.PUT_LINE('�ش� ����� �����ϴ�.');
    else
    DBMS_OUTPUT.PUT_LINE('�����Ǿ����ϴ�.');
    END IF;
END;
/

/* �������� ���, �޿� ����ġ(%)�� �Է��ϸ� Employees���̺�
���� ����� �޿��� ������ �� �ֵ��� PL/SQL�� �ۼ��ϼ���.
���� �Է��� ����� ���� ��쿡�� ��No search employee!!����� �޽����� ����ϼ���.

�޿� = �޿�*(1+�޿�����ġ/100)
or
�޿� = �޿�+(�޿�*(�޿�����ġ/100)) */
DECLARE
v_per number(3) := &vp;
    BEGIN
    update employees
    set salary = salary*(1 + v_per/100)
    where employee_id = &id;
    if SQL%NOTFOUND then
    DBMS_OUTPUT.PUT_LINE('No search employee');
    else
    DBMS_OUTPUT.PUT_LINE('���ŵǾ����ϴ�.');
    END IF;
END;
/

rollback;

/* ��������� �Է�(ġȯ�������)�� ��� �ش�⵵�� �츦 ����Ͻÿ�
mod((����⵵-���λ���), 12) = ���� �� */
DECLARE
v_birth number(10) := &no;
v_ddi number(10);
    BEGIN
    v_ddi := mod(v_birth, 12);
    if v_ddi = 0 then
    DBMS_OUTPUT.PUT_LINE('�����̶�');
    elsif v_ddi = 1 then
    DBMS_OUTPUT.PUT_LINE('�߶�');
    elsif v_ddi = 2 then
    DBMS_OUTPUT.PUT_LINE('����');
    elsif v_ddi = 3 then
    DBMS_OUTPUT.PUT_LINE('������');
    elsif v_ddi = 4 then
    DBMS_OUTPUT.PUT_LINE('���');
    elsif v_ddi = 5 then
    DBMS_OUTPUT.PUT_LINE('�Ҷ�');
    elsif v_ddi = 6 then
    DBMS_OUTPUT.PUT_LINE('ȣ���̶�');
    elsif v_ddi = 7 then
    DBMS_OUTPUT.PUT_LINE('�䳢��');
    elsif v_ddi = 8 then
    DBMS_OUTPUT.PUT_LINE('���');
    elsif v_ddi = 9 then
    DBMS_OUTPUT.PUT_LINE('���');
    elsif v_ddi = 10 then
    DBMS_OUTPUT.PUT_LINE('����');
    elsif v_ddi = 11 then
    DBMS_OUTPUT.PUT_LINE('���');
    else
    DBMS_OUTPUT.PUT_LINE('���');
    end if;
end;
/