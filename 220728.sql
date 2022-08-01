set serveroutput on;

DECLARE
    type emp_table_type is table of
       employees%ROWTYPE index by pls_integer;
    my_emp_table emp_table_type;
    max_count number(3) := 104;
BEGIN
    for i IN 100..max_count
    LOOP
        select *
        into my_emp_table(i)
        from employees
        where employee_id = i;
    END LOOP;
    
    for i IN my_emp_table.FIRST..my_emp_table.LAST
    LOOP
        DBMS_OUTPUT.PUT_LINE(my_emp_table(i).last_name);
    END LOOP;
END;
/

/* �μ���ȣ(ġȯ���� ���)�� �Է��� ���
����̸�, �Ҽӵ� �μ��̸��� ����ϴ� PL/SQL ��� */

DECLARE
    v_ename employees.last_name%TYPE;
    v_dname departments.department_name%TYPE;
BEGIN
    select e.last_name, d.department_name
    into v_ename, v_dname
    from employees e, departments d
    where e.department_id = d.department_id
    and e.department_id = &id;
    --�����ȣ�� �Է��� ���
    --and e.employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('����̸� : ' || v_ename || ', ' || '�ҼӺμ� : ' || v_dname);
END;
/

select * from departments;
select * from employees;

--����� Ŀ��
DECLARE
    cursor c_emp_cursor IS
        --����
        select employee_id, last_name
        from employees
        where department_id = 20;
    v_empno employees.employee_id%TYPE;
    v_lname employees.last_name%TYPE;
BEGIN
    --����
    open c_emp_cursor;
    LOOP
        --����
        fetch c_emp_cursor
        into v_empno, v_lname;
        EXIT when c_emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('20�� �μ��� �����ȣ : ' || v_empno || ', ' || '����̸� : ' || v_lname);
    END LOOP;
    --�ݱ�
    CLOSE c_emp_cursor;
END;
/

/* �μ���ȣ(ġȯ���� ���)�� �Է��� ���
����̸�, �Ҽӵ� �μ��̸��� ����ϴ� PL/SQL ��� */
DECLARE
    cursor c_emp_cursor IS
        select e.last_name, d.department_name
        from employees e, departments d
        where d.department_id = e.department_id
        and e.department_id = &id;
    v_ename employees.last_name%TYPE;
    v_dname departments.department_name%TYPE;
BEGIN
    OPEN c_emp_cursor;
    LOOP
        fetch c_emp_cursor
        into v_ename, v_dname;
        EXIT when c_emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(&id || '�� �μ� ����̸� : ' || v_ename || ', ' || '�ҼӺμ� : ' || v_dname);
    END LOOP;
    CLOSE c_emp_cursor;
END;
/

create table temp_list(empid, empname)
as
select employee_id, last_name
from employees
where employee_id = 0;

/* Ŀ�� �� ���ڵ�
�μ���ȣ 20���� ������� ������ temp_list�� �־��� */
DECLARE
    cursor emp_cursor IS
        select employee_id, last_name
        from employees
        where department_id = 20;
    emp_record emp_cursor%ROWTYPE;
BEGIN
    open emp_cursor;
    LOOP
        fetch emp_cursor
        into emp_record;
        EXIT when emp_cursor%NOTFOUND;
        insert into temp_list(empid, empname)
        values(emp_record.employee_id, emp_record.last_name);
    END LOOP;
    commit;
    CLOSE emp_cursor;
END;
/

select * from temp_list;

--Ŀ�� for loop
DECLARE
    cursor c_emp_cursor IS
        select employee_id, last_name
        from employees
        where department_id = 20;
BEGIN
    for emp_record IN c_emp_cursor
        LOOP
        DBMS_OUTPUT.PUT_LINE(emp_record.employee_id || ', ' || emp_record.last_name);
        END LOOP;
END;
/

--50�� �μ��� �ִ� ����� �޿� 10% �λ�
DECLARE
    cursor sal_cursor IS
        select salary
        from employees
        where department_id = 50
        for update of salary nowait;
BEGIN
    for emp_record IN sal_cursor
    LOOP
        update employees
        set salary = emp_record.salary * 1.10
        where current of sal_cursor;
    END LOOP;
END;
/

rollback;
select department_id, salary from employees where department_id = 50;
commit;

/* 1.���(employees) ���̺���
����� �����ȣ, ����̸�, �Ի�⵵��
���� ���ؿ� �°� ���� test01, test02�� �Է��Ͻÿ�.

�Ի�⵵�� 2000��(����) ������ �Ի��� ����� test01 ���̺� �Է�
�Ի�⵵�� 2000�� ���Ŀ� �Ի��� ����� test02 ���̺� �Է�
�ݵ�� cursor ���
for loop �⺻ ��� */
DECLARE
    cursor c_emp_cursor IS
        select employee_id, last_name, hire_date
        from employees;
BEGIN
    FOR emp_rec IN c_emp_cursor
    LOOP
        if to_char(emp_rec.hire_date, 'YYYY') <= '2000' then
            insert into test01 values emp_rec;
        else
            insert into test02 values emp_rec;
        end if;
    END LOOP;
END;
/

/* 2.���(employees) ���̺���
����� �����ȣ, ����̸�, �Ի�⵵��
���� ���ؿ� �°� ���� test01, test02�� �Է��Ͻÿ�.

�Ի�⵵�� 2000��(����) ������ �Ի��� ����� test01 ���̺� �Է�
�Ի�⵵�� 2000�� ���Ŀ� �Ի��� ����� test02 ���̺� �Է�
�ݵ�� cursor ���
�⺻ loop ���(declare -> open -> fetch -> close) */
DECLARE
    cursor c_emp_cursor IS
        select employee_id, last_name, hire_date
        from employees;
        emp_rec c_emp_cursor%ROWTYPE;
BEGIN
    OPEN c_emp_cursor;
    LOOP
        fetch c_emp_cursor into emp_rec;
        exit when c_emp_cursor%NOTFOUND;
        if to_char(emp_rec.hire_date, 'YYYY') <= '2000' then
            insert into test01 values emp_rec;
        else
            insert into test02 values emp_rec;
        end if;
    END LOOP;
    CLOSE c_emp_cursor;
END;
/

/* 3.�μ���ȣ�� �Է��� ���(&ġȯ���� ���)
�ش��ϴ� �μ��� ����̸�, �Ի�����, �μ����� ����Ͻÿ�.(��, cursor ���) */
DECLARE
    cursor c_emp_cursor is
    select e.last_name, e.hire_date, d.department_name
    from employees e, departments d
    where e.department_id = d.department_id
    and e.department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('����̸� : ' || emp_rec.last_name || ', ' ||
    '�Ի����� : ' || emp_rec.hire_date || ', ' || '�μ��� : ' || emp_rec.department_name);    
    END LOOP;
END;
/

/* 4.�μ���ȣ�� �Է�(&���)�ϸ� 
�Ҽӵ� ����� �����ȣ, ����̸�, �μ���ȣ�� ����ϴ� PL/SQL�� �ۼ��Ͻÿ�.(��, CURSOR ���) */
DECLARE
    cursor c_emp_cursor is
    select employee_id, last_name, department_id
    from employees
    where department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || emp_rec.employee_id || ', ' ||
    '����̸� : ' || emp_rec.last_name || ', ' || '�μ���ȣ : ' || emp_rec.department_id);  
    END LOOP;
END;
/

/* 5.�μ���ȣ�� �Է�(&���)�� ��� 
����̸�, �޿�, ����->(�޿�*12+(�޿�*nvl(Ŀ�̼��ۼ�Ʈ,0)*12))
�� ����ϴ�  PL/SQL�� �ۼ��Ͻÿ�.(��, cursor ���)*/
DECLARE
    cursor c_emp_cursor is
    select last_name, salary, salary*12+(salary*nvl(commission_pct, 0)*12) annsal
    from employees
    where department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('����̸� : ' || emp_rec.last_name || ', ' || 
    '�޿� : ' || emp_rec.salary || ', ' || 
    '���� : ' || emp_rec.annsal); 
    END LOOP;
END;
/

/* 6.�μ���ȣ�� �Է�(&���)�� ��� 
�ش� �μ��� ����(job_id)�� ��� �޿��� ����ϴ� PL/SQL�� �ۼ��Ͻÿ�. */
DECLARE
    cursor c_emp_cursor is
    select job_id, round(avg(nvl(salary, 0)),0) salary
    from employees
    where department_id = &id
    group by job_id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('�μ����� : ' || emp_rec.job_id || ', ' || '��� �޿� : ' || emp_rec.salary);
    END LOOP;
END;
/

/* 7.���(employees) ���̺���
����� �����ȣ, ����̸�, �Ի翬���� 
���� ���ؿ� �°� ���� test01, test02�� �Է��Ͻÿ�.

�޿��� 5000(����) �̻��̸� test01 ���̺� �Է�
�޿��� 5000 �̸��̸� test02 ���̺� �Է�
** �ݵ�� cursor ��� */
DECLARE
    cursor c_emp_cursor is
    select employee_id, last_name, hire_date, salary
    from employees;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
        if emp_rec.salary <= 5000 then
            insert into test01 values(emp_rec.employee_id, emp_rec.last_name, emp_rec.hire_date);
        else
            insert into test02 values(emp_rec.employee_id, emp_rec.last_name, emp_rec.hire_date);
        end if;
    END LOOP;
END;
/

select * from test01;
select * from test02;
rollback;

--�̸� ������ ���� Ʈ��(no_data_found)
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    select last_name
    into v_name
    from employees
    where employee_id = &id;
EXCEPTION
    when no_data_found then
        DBMS_OUTPUT.PUT_LINE('�ش����� �����ϴ�.');
END;
/

--�̸� ������ ���� Ʈ��(too_many_rows)
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    select last_name
    into v_name
    from employees
    where department_id = &id;
EXCEPTION
    when too_many_rows then
        DBMS_OUTPUT.PUT_LINE('�� �� �̻��� ���� ���ǵǾ����ϴ�.');
END;
/

DECLARE
    e_insert_excep EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insert_excep, -01400);
BEGIN
    insert into departments (department_id, department_name)
    values (280, NULL);
EXCEPTION
    when e_insert_excep then
        DBMS_OUTPUT.PUT_LINE('Insert Operation Failed');
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ', ' ||SQLERRM);
END;
/

--����ڰ� ������ ���� Ʈ��
DECLARE
    v_deptno number := 500;
    v_name varchar2(20) := 'Testing';
    e_invalid_department EXCEPTION;
BEGIN
    update departments
    set department_name = v_name
    where department_id = v_deptno;
    if sql%notfound then
        raise e_invalid_department;
    end if;
    commit;
EXCEPTION
    when e_invalid_department then
        DBMS_OUTPUT.PUT_LINE('No such department id.');
END;
/

--RAISE_APPLICATION_ERROR ���ν���
DECLARE
    e_name EXCEPTION;
BEGIN
    delete from employees
    where last_name = '&id';
    if SQL%NOTFOUND then
        raise e_name;
    end if;
EXCEPTION
    when e_name then
    RAISE_APPLICATION_ERROR (-20999, '�ش� ����� �����ϴ�.');
    --DBMS_OUTPUT.PUT_LINE('�ش� ����� �����ϴ�.');
END;
/

--���� �� ������� ���� ���
BEGIN
    delete from employees
    where last_name = '&id';
    if SQL%NOTFOUND then
        RAISE_APPLICATION_ERROR (-20999, '�ش� ����� �����ϴ�.');
    end if;
END;
/