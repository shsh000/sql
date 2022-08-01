set serveroutput on;
/* ������̺��� �����ȣ, ����̸�, �λ�ȱ޿�, �μ��̸� ���
��, �Ի�� �޿��� ����(job_id)����
it_prog => 10%
st_clerk => 20%
st_man => 30%
Ÿ������ �λ� X */
DECLARE
v_empno employees.employee_id%TYPE;
v_ename employees.last_name%TYPE;
v_sal employees.salary%TYPE;
v_salin employees.salary%TYPE;
v_dname departments.department_name%TYPE;
v_jobid employees.job_id%TYPE;
    BEGIN
    select e.employee_id, e.last_name, e.salary, d.department_name, e.job_id
    into v_empno, v_ename, v_sal, v_dname, v_jobid
    from employees e, departments d
    where e.department_id = d.department_id
    and employee_id = &id;
    if v_jobid = 'IT_PROG' then
    v_salin := v_sal*1.1;
    elsif v_jobid = 'ST_CLERK' then
    v_salin := v_sal*1.2;
    elsif v_jobid = 'ST_MAN' then
    v_salin := v_sal*1.3;
    else v_salin := v_sal;
    end if;
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '����̸� : ' || v_ename || ', ' || '�λ�� �޿� : ' || v_salin || ', ' || '�ҼӺμ� : ' || v_dname);
end;
/

select * from employees;
select department_id from departments;

/* �μ���ȣ�� �Է�(ġȯ���� ���)�� ���
�Էµ� �μ����� ���� ���� �޿��� �޴� �����
�����ȣ, ����̸�, �޿�, �μ��̸� ��� */
DECLARE
v_empno employees.employee_id%TYPE;
v_ename employees.last_name%TYPE;
v_sal employees.salary%TYPE;
v_dname departments.department_name%TYPE;
    BEGIN
    select e.employee_id, e.last_name, e.salary, d.department_name
    into v_empno, v_ename, v_sal, v_dname
    from employees e, departments d
    where e.department_id = d.department_id
    and e.salary = (select max(salary)
                    from employees
                    where department_id = &id
                    group by department_id);
    DBMS_OUTPUT.PUT_LINE('�����ȣ : ' || v_empno || ', ' || '����̸� : ' || v_ename || ', ' || '�޿� : ' || v_sal || ', ' || '�ҼӺμ� : ' || v_dname);
end;
/

--�⺻ LOOP ����
DECLARE
    v_countryid locations.country_id%TYPE := 'CA';
    v_loc_id locations.location_id%TYPE;
    v_counter number(2) := 1;
    v_new_city locations.city%TYPE := 'Montreal';
BEGIN
    select max(location_id)
    INTO v_loc_id
    from locations
    where country_id = v_countryid;
    LOOP
        insert into locations(location_id, city, country_id)
        values((v_loc_id + v_counter), v_new_city, v_countryid);
        v_counter := v_counter + 1;
        EXIT when v_counter > 3;
    END LOOP;
END;
/

select * from locations;

--WHILE LOOP(������ �������� �ݺ�) ����
DECLARE
    v_countryid locations.country_id%TYPE := 'CA';
    v_loc_id locations.location_id%TYPE;
    v_counter number(2) := 1;
    v_new_city locations.city%TYPE := 'Montreal';
BEGIN
    select max(location_id)
    INTO v_loc_id
    from locations
    where country_id = v_countryid;
    --3�� �ݺ��ϴ� ����
    WHILE v_counter <= 3 LOOP
        insert into locations(location_id, city, country_id)
        values((v_loc_id + v_counter), v_new_city, v_countryid);
        v_counter := v_counter + 1;
    END LOOP;
END;
/

--FOR LOOP(Ƚ���� �������� �ݺ�) ����
DECLARE
    v_countryid locations.country_id%TYPE := 'CA';
    v_loc_id locations.location_id%TYPE;
    v_new_city locations.city%TYPE := 'Montreal';
BEGIN
    select max(location_id)
    INTO v_loc_id
    from locations
    where country_id = v_countryid;
    --i = ������ ����, 1~3���� �ݺ�
    FOR i IN 1..3 LOOP
        insert into locations(location_id, city, country_id)
        values((v_loc_id + i), v_new_city, v_countryid);
    END LOOP;
END;
/

create table aaa
(a number(3));

create table bbb
(b number(3));

/* 1. aaa ���̺� 1���� 10���� �Էµǵ��� PL/SQL ����� �ۼ��Ͻÿ�.
��, insert ���� 1���� ��� */
DECLARE
v_a aaa.a%TYPE := 0;
BEGIN
    for i IN 1..10 LOOP
        insert into aaa values(v_a + i);
    END LOOP;
END;
/

/* 2. bbb ���̺� 1���� 10���� ���� �հ� ���� PL/SQL ������� �ۼ��Ͽ� �Է��Ͻÿ�. */
DECLARE
v_b bbb.b%TYPE := 0;
BEGIN
    for i IN 1..10 LOOP
        v_b := v_b + i;
        insert into bbb values(v_b);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('1~10 �հ� : ' || v_b);
END;
/

/* 3. aaa ���̺� 1���� 10���� ¦���� �Էµǵ��� PL/SQL ����� �ۼ��Ͻÿ�.
��, insert ���� �ѹ� ���, if�� ��� */
DECLARE
i number(10);
BEGIN
    for i IN 1..10 LOOP
    if mod(i, 2) = 0 then
    insert into aaa values(i);
    end if;
    END LOOP;
END;
/

/* 4. bbb ���̺� 1���� 10���� ¦�� ���� �հ� ���� PL/SQL ������� �ۼ��Ͽ� �Է��Ͻÿ�.
��, if�� ��� */
DECLARE
v_b bbb.b%TYPE := 0;
i number(10);
BEGIN
    for i IN 1..10 LOOP
        if mod(i, 2) = 0 then
            v_b := v_b + i;
            if i = 10 then
                insert into bbb values(v_b);
            end if;
        end if;
    END LOOP;
END;
/

/* 5. 1���� 10�������� ¦���� �հ�� aaa ���̺�, Ȧ���� �հ�� bbb ���̺� 
�Էµǵ��� PL/SQL ����� �ۼ��Ͻÿ�. (��, if �� ���) */
DECLARE
v_a aaa.a%TYPE := 0;
v_b bbb.b%TYPE := 0;
i number(10);
BEGIN
    for i IN 1..10 LOOP
        if mod(i, 2) = 0 then
        v_a := v_a + i;
            if i = 10 then
                insert into aaa values(v_a);
            end if;
        end if; 
        
        v_b := v_b + i;
            if i = 10 then
                insert into bbb values(v_b);
            end if;
    END LOOP;
END;
/

rollback;
select * from aaa;
select * from bbb;

--record
DECLARE
    type t_rec is record
    (v_sal number(8),
    v_minsal number(8) default 1000,
    v_hire_date employees.hire_date%TYPE,
    v_rec1 employees%rowtype);
    v_myrec t_rec;
BEGIN
    v_myrec.v_sal := v_myrec.v_minsal + 500;
    v_myrec.v_hire_date := sysdate;
    select *
    into v_myrec.v_rec1
    from employees
    where employee_id = 100;
    --������ Ÿ�� �����ϰ� �ϴ°� ����(to_char ���� ����)
    DBMS_OUTPUT.PUT_LINE(v_myrec.v_rec1.last_name || ', ' ||
    to_char(v_myrec.v_hire_date) || ', ' || to_char(v_myrec.v_sal));
END;
/

create table retired_emps (empno, ename, job, mgr, hiredate,
                           leavedate, sal, comm, deptno)
as
  select employee_id, last_name, job_id, manager_id, hire_date,
         sysdate, salary, commission_pct, department_id
  from   employees
  where  employee_id = 0;

DECLARE
    v_employee_number number := 124;
    v_emp_rec employees%ROWTYPE;
BEGIN
    select *
    into v_emp_rec
    from employees
    where employee_id = v_employee_number;
    insert into retired_emps(empno, ename, job, mgr, hiredate, leavedate, sal, comm, deptno)
    values(v_emp_rec.employee_id, v_emp_rec.last_name,
           v_emp_rec.job_id, v_emp_rec.manager_id,
           v_emp_rec.hire_date, sysdate,
           v_emp_rec.salary, v_emp_rec.commission_pct,
           v_emp_rec.department_id);
END;
/

select * from retired_emps;

/* �����ȣ�� �Է�(ġȯ����& ���)�� ���
�μ����� �����Ͽ� ������ ���̺� �Է��ϴ� PL/SQL ����� �ۼ��Ͻÿ�.
��, �ش� �μ��� ���� ����� emp00 ���̺� �Է��Ͻÿ�. */
DECLARE
    v_emp_rec employees%ROWTYPE;
BEGIN
    select *
    into v_emp_rec
    from employees
    where employee_id = &id;
    
    if v_emp_rec.department_id = 10 then
        insert into emp10 values v_emp_rec;
    elsif v_emp_rec.department_id = 20 then
        insert into emp20 values v_emp_rec;
    elsif v_emp_rec.department_id = 30 then
        insert into emp30 values v_emp_rec;
    elsif v_emp_rec.department_id = 40 then
        insert into emp40 values v_emp_rec;
    elsif v_emp_rec.department_id = 50 then
        insert into emp50 values v_emp_rec;
    else
        insert into emp00 values v_emp_rec;
    end if;
END;
/

rollback;

DECLARE
    v_employee_number number := 124;
    v_emp_rec retired_emps%ROWTYPE;
BEGIN
    select *
    into v_emp_rec
    from retired_emps;
    v_emp_rec.leavedate := current_date;
    update retired_emps set row = v_emp_rec
    where empno = v_employee_number;
END;
/

select * from retired_emps;

DECLARE
    type dept_table_type is table of
        departments%ROWTYPE index by PLS_INTEGER;
    dept_table dept_table_type;
BEGIN
    select *
    into dept_table(1)
    from departments
    where department_id = 10;
    DBMS_OUTPUT.PUT_LINE(dept_table(1).department_id || ', ' ||
    dept_table(1).department_name || ', ' ||
    dept_table(1).manager_id);
END;
/

/* 
*
**
***
****
*****
*/
BEGIN
    for i IN 1..5 LOOP
        for j IN 1..i LOOP
        DBMS_OUTPUT.PUT('*');
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
END;
/

/* ġȯ����(&)�� ����ϸ� ���ڸ� �Է��ϸ� �ش� �������� ��µǵ��� �Ͻÿ�.
��) 2 �Է½�
2 * 1 = 2
2 * 2 = 4
2 * 3 = 6
2 * 4 = 8
2 * 5 = 10
2 * 6 = 12
2 * 7 = 14
2 * 8 = 16
2 * 9 = 18 */
DECLARE
v_no number(10) := &no;
BEGIN
    for i IN 1..9 LOOP
    DBMS_OUTPUT.PUT_LINE(v_no || ' * ' || i || ' = ' || v_no*i);
    END LOOP;
END;
/

/* ������ 2~9�ܱ��� ��µǵ��� �Ͻÿ�. */
BEGIN
    for v_no IN 2..9 LOOP
        for i IN 1..9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_no || ' * ' || i || ' = ' || v_no*i);
        END LOOP;
    END LOOP;
END;
/

/* ������ 1~9�ܱ��� ��µǵ��� �Ͻÿ�.
   (��, Ȧ���� ���) */
BEGIN
    for v_no IN 1..9 LOOP
        for i IN 1..9 LOOP
        if mod(v_no, 2) = 1 then
        DBMS_OUTPUT.PUT_LINE(v_no || ' * ' || i || ' = ' || v_no*i);
        end if;
        END LOOP;
    END LOOP;
END;
/

