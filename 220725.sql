select last_name, to_char(hire_date, 'YYYY-MM-DD')
from employees
where hire_date = '97/09/17';

select *
from employees
where hire_date = to_date('1997�� 9�� 17��', 'YYYY"��" MM"��" DD"��"');

select * from employees;
select * from locations;
select * from departments;

select e.employee_id, e.last_name, d.department_id, d.department_name, e.salary
from employees e, departments d
where e.department_id = d.department_id
and e.salary >= 4000
order by salary;

select e.employee_id, e.last_name, d.department_id, d.department_name, e.salary
from employees e JOIN departments d
ON e.department_id = d.department_id
where e.salary >= 4000
order by salary;

select e.last_name, d.department_name, l.city
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id;

select e.last_name, d.department_name, l.city
from employees e JOIN departments d
ON (e.department_id = d.department_id)
JOIN locations l
ON (d.location_id = l.location_id);

--�μ��� ��� �޿� �ּҰ�
select min(avg(nvl(salary, 0)))
from employees
group by department_id;

--���ν���
declare
v_fname varchar2(20);
begin
select first_name INTO v_fname FROM employees
where employee_id=100;
end;
/

--DBMS_OUTPUT.put_LINE() => ����ϱ� ���ؼ� ����
set serveroutput on;

declare
v_fname varchar2(20);
begin
select first_name
INTO v_fname
FROM employees
where employee_id=100;
DBMS_OUTPUT.put_LINE(' The First Name of the Employee is ' || v_fname); --DBMS_OUTPUT.put_LINE() = println, DBMS_OUTPUT.put() = print
END;
/

