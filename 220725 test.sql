select * from tab;
select * from employees;
select * from departments;

--1��
select * from employees
where commission_pct is not null;

--2��
select employee_id, last_name, salary, hire_date, department_id
from employees
order by salary;

--3��
select employee_id, last_name, to_char(hire_date, 'yyyy-mm-dd'), salary
from employees;

--4��
--Oracle Join
select e.employee_id, e.last_name, d.department_id, d.department_name
from employees e, departments d
where e.department_id = d.department_id;
--Ansi Join
select e.employee_id, e.last_name, d.department_id, d.department_name
from employees e JOIN departments d
ON e.department_id = d.department_id;

--5��
select department_id, round(avg(nvl(salary, 0)),0)
from employees
group by department_id;

--6��
select employee_id, last_name, salary, job_id, department_id
from employees
where department_id = (select department_id
                    from employees where employee_id = 142);
                    
--7��
select employee_id, last_name, hire_date, add_months(hire_date, 6) 
from employees;

--8��
create table sawon
(S_NO number(4),
NAME varchar2(15) not null,
ID varchar2(15) not null,
HIREDATE date,
PAY number(4));

--�⺻Ű �߰�
alter table sawon add primary key(s_no);

--pay �÷� not null �������� �߰�
alter table sawon modify (pay not null);

desc sawon;
select *
from sawon;
commit;

--9-1��
insert into sawon values (101, 'Jason', 'ja101', to_date('17/09/01','YY-MM-DD'), 800);
insert into sawon values (104, 'Min', 'm104', to_date('14/07/02','YY-MM-DD'), 500);
--9-2��
update sawon set pay = 700
where s_no = 104;

--10��
drop table sawon purge;