set serveroutput on;

drop table emp_test;

create table emp_test
as
  select employee_id, last_name
  from   employees
  where  employee_id < 200;

select *
from emp_test;

--사용자가 정의한 예외 트랩
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
 
/* 1.emp_test 테이블에서 사원번호를 사용(&치환변수 사용)하여 사원을 삭제하는 PL/SQL을 작성하시오.
(단, 사용자 정의 예외사항 사용)
(단, 사원이 없으면 "해당사원이 없습니다.'라는 오류메시지 발생) */
DECLARE
    e_invalid_employee EXCEPTION;
BEGIN
    delete from emp_test
    where employee_id = &id;
    if SQL%NOTFOUND then
        raise e_invalid_employee;
    end if;
EXCEPTION
    when e_invalid_employee then
        DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
END;
/

/* 2.사원(employees) 테이블에서
사원번호를 입력(&사용)받아
10% 인상된 급여로 수정하는 PL/SQL을 작성하시오.
단, 2000년(포함) 이후 입사한 사원은 갱신하지 않고
"2000년 이후 입사한 사원입니다." <-exception 절 사용
라고 출력되도록 하시오. */
DECLARE
    e_invalid_employee EXCEPTION;
    v_hiredate employees.hire_date%TYPE;
    v_id employees.employee_id%TYPE := &id;
BEGIN
    select hire_date
    into v_hiredate
    from employees
    where employee_id = v_id;
    if to_char(v_hiredate, 'YYYY') <= 2000 then
        update employees
        set salary = salary * 1.1
        where employee_id = v_id;
    else
        raise e_invalid_employee;
    end if;
EXCEPTION
    when e_invalid_employee then
        DBMS_OUTPUT.PUT_LINE('2000년 이후에 입사한 사원입니다.');
END;
/
select employee_id, hire_date, salary from employees where department_id = 10;
rollback;

/* 3.사원(employees) 테이블에서
부서번호를 입력(&사용)받아   <- cursor 사용
10% 인상된 급여로 수정하는 PL/SQL을 작성하시오.
단, 단 해당 부서에 사원이 없으면
"해당 부서에는 사원이 없습니다." <-exception 절 사용
라고 출력되도록 하시오. */
DECLARE
    e_invalid_employee EXCEPTION;
    cursor c_emp_cursor is
    select salary
    from employees
    where department_id = &id
    for update of salary nowait;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
        update employees
        set salary = emp_rec.salary * 1.10
        where current of c_emp_cursor;
    END LOOP;
    if SQL%NOTFOUND then
        raise e_invalid_employee;
    end if;
EXCEPTION
    when e_invalid_employee then
        DBMS_OUTPUT.PUT_LINE('해당 부서에는 사원이 없습니다.');
END;
/

select department_id, salary from employees order by department_id;
rollback;

--IN 매개변수
create or replace procedure raise_salary
    (p_id IN employees.employee_id%TYPE,
     p_percent IN number)
IS
BEGIN
    update employees
    set salary = salary * (1+ p_percent/100)
    where employee_id = p_id;
END raise_salary;
/
--사원번호 100번의 급여 10% 인상
EXECUTE raise_salary(100, 10);
--사원번호 100번의 급여 10% 인상
BEGIN
    raise_salary (100,10);
END;
/

rollback;
select employee_id, salary from employees;

--OUT 매개변수(값 호출, 프로시저는 리턴값이 X)
create or replace procedure query_emp
    (p_id employees.employee_id%TYPE,
     p_name OUT employees.last_name%TYPE,
     p_salary OUT employees.salary%TYPE) IS
BEGIN
    select last_name, salary
    into p_name, p_salary
    from employees
    where employee_id = p_id;
END query_emp;
/

DECLARE
    v_emp_name employees.last_name%TYPE;
    v_emp_sal employees.salary%TYPE;
BEGIN
    query_emp(100, v_emp_name, v_emp_sal);
    DBMS_OUTPUT.PUT_LINE(v_emp_name || ' earns ' ||
    to_char(v_emp_sal, '$999,999,00'));
END;
/

--IN OUT 매개변수
create or replace procedure format_phone
    (p_phone_no IN OUT varchar2) IS
BEGIN
    p_phone_no := '(' || substr(p_phone_no, 1, 3) ||
                  ') ' || substr(p_phone_no, 4, 3) ||
                  '-' || substr(p_phone_no, 7);
END format_phone;
/

--add_dept 프로시저 생성
create or replace procedure add_dept
    (p_name IN departments.department_name%TYPE,
     p_loc IN departments.location_id%TYPE) IS
BEGIN
    insert into departments (department_id, department_name, location_id)
    values (departments_seq.NEXTVAL, p_name, p_loc);
END add_dept;
/

EXECUTE add_dept ('TRAINING', 2500);
EXECUTE add_dept (p_loc => 2500, p_name => 'EDUCATION');

create or replace procedure add_dept
    (p_name IN departments.department_name%TYPE := 'Unknown',
     p_loc IN departments.location_id%TYPE DEFAULT 1700) IS
BEGIN
    insert into departments (department_id, department_name, location_id)
    values (departments_seq.NEXTVAL, p_name, p_loc);
END add_dept;
/

EXECUTE add_dept;
EXECUTE add_dept('ADVERTISING', p_loc => 1700);
EXECUTE add_dept(p_loc => 1700);

select * from departments;
rollback;

drop procedure raise_salary;

--프로시저 생성(exception 포함)
create procedure add_department
    (p_name varchar2, p_mgr number, p_loc number) IS
BEGIN
    insert into departments (department_id, department_name, manager_id, location_id)
    values (departments_seq.nextval, p_name, p_mgr, p_loc);
    DBMS_OUTPUT.PUT_LINE('Added Dept : ' || p_name);
EXCEPTION
    when others then
        DBMS_OUTPUT.PUT_LINE('Err : adding dept : ' || p_name);
END;
/

create procedure create_departments IS
BEGIN
    add_department('Media', 100, 1800);
    add_department('Editing', 99, 1800);
    add_department('Advertising', 101, 1800);
END;
/
EXECUTE create_departments;

drop procedure add_department;
drop procedure create_departments;
select * from departments order by department_id desc;

select text
from user_source
where name = 'ADD_DEPT'
and type = 'PROCEDURE'
order by line;

/* 1.주민등록번호를 입력하면 
다음과 같이 출력되도록 yedam_ju 프로시저를 작성하시오.
EXECUTE yedam_ju(9501011667777)
  -> 950101-1****** */
create or replace procedure yedam_ju
    (p_jumin_no number) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(substr(p_jumin_no, 1, 6) ||
                 '-' || substr(p_jumin_no, 7, 1) || '******');
END yedam_ju;
/
EXECUTE yedam_ju(9501011667777);

/* 2.사원번호를 입력할 경우
삭제하는 TEST_PRO 프로시저를 생성하시오.
단, 해당사원이 없는 경우 "해당사원이 없습니다." 출력
예) EXECUTE TEST_PRO(176) */
create or replace procedure TEST_PRO
    (p_emp_no employees.employee_id%TYPE) IS
BEGIN
    delete from employees
    where employee_id = p_emp_no;
    if SQL%NOTFOUND then
        DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
    end if;
END TEST_PRO;
/
EXECUTE TEST_PRO(203);
select * from employees order by employee_id;

--2번 다른 방식(exception)
create or replace procedure TEST_PRO
    (p_emp_no employees.employee_id%TYPE)
IS
    v_ename employees.last_name%TYPE;
    no_delete exception;
BEGIN
    delete from employees
    where employee_id = p_emp_no;
    if SQL%NOTFOUND then
        raise no_delete;
    end if;
EXCEPTION
    when no_delete then
       DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
END TEST_PRO;
/
EXECUTE TEST_PRO(203);
/* 3.다음과 같이 PL/SQL 블록을 실행할 경우 
사원번호를 입력할 경우 사원의 이름(last_name)의 첫번째 글자를 제외하고는
'*'가 출력되도록 yedam_emp 프로시저를 생성하시오.
실행) EXECUTE yedam_emp(176)
실행결과) TAYLOR -> T*****  <- 이름 크기만큼 별표(*) 출력 */
create or replace procedure yedam_emp
    (p_emp_no employees.employee_id%TYPE)
IS
    v_ename employees.last_name%TYPE;
BEGIN
    select last_name
    into v_ename
    from employees
    where employee_id = p_emp_no;
    DBMS_OUTPUT.PUT_LINE(RPAD(substr(v_ename, 1, 1), length(v_ename), '*'));
END yedam_emp;
/
EXECUTE yedam_emp(100);

/* 1.부서번호를 입력할 경우 
해당부서에 근무하는 사원의 사원번호, 사원이름(last_name)을 출력하는 get_emp 프로시저를 생성하시오. 
(cursor 사용해야 함)
단, 사원이 없을 경우 "해당 부서에는 사원이 없습니다."라고 출력(exception 사용)
실행) EXECUTE get_emp(30) */

--기본 loop 방식
create or replace procedure get_emp
    (p_dept_no employees.department_id%TYPE)
IS
    cursor emp_cursor is
    select *
    from employees
    where department_id = p_dept_no;
    emp_rec emp_cursor%ROWTYPE;
    e_invalid_employee EXCEPTION;
BEGIN
    OPEN emp_cursor;
    LOOP
        fetch emp_cursor
        into emp_rec;
        if emp_cursor%ROWCOUNT = 0 then
            raise e_invalid_employee;
        end if;
        exit when emp_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('사원번호 : ' || emp_rec.employee_id || ', ' || '사원이름 : ' || emp_rec.last_name);
    end loop;
    close emp_cursor;
EXCEPTION
    when e_invalid_employee then
        DBMS_OUTPUT.PUT_LINE('해당 부서에는 사원이 없습니다.'); 
END get_emp;
/

EXECUTE get_emp(30);
select department_id from employees order by department_id;

--for loop 방식
create procedure get_emp 
    (p_did in employees.department_id%type) is
    cursor c_emp is
        select employee_id, last_name 
        from employees
        where department_id = p_did;
    v_count number := 0;
begin
    for emp_record in c_emp loop
        v_count := nvl(v_count,0) + 1;
        dbms_output.put_line('['|| emp_record.employee_id ||', '|| emp_record.last_name ||']');       
    end loop;
    if v_count = 0 then
        raise no_data_found;
    end if; 
exception
    when NO_DATA_FOUND then
    dbms_output.put_line('[해당 부서에는 사원이 없습니다.]'); 
end get_emp;
/


/* 2.직원들의 사번, 급여 증가치만 입력하면
Employees 테이블에 쉽게 사원의 급여를 갱신할 수 있는 y_update 프로시저를 작성하세요. 
만약 입력한 사원이 없는 경우에는 ‘No search employee!!’라는 메시지를 출력하세요.(예외처리)
실행) EXECUTE y_update(200, 10) */
create or replace procedure y_update
    (p_id employees.employee_id%TYPE,
     p_percent number)
IS
    e_invalid_employee EXCEPTION;
BEGIN
    update employees
    set salary = salary * (1+ p_percent/100)
    where employee_id = p_id;
    if SQL%NOTFOUND then
        raise e_invalid_employee;
    end if;
EXCEPTION
    when e_invalid_employee then
        DBMS_OUTPUT.PUT_LINE('No search employee.');
END y_update;
/
EXECUTE y_update(203, 10);
rollback;

select employee_id, salary from employees order by employee_id desc;

create table yedam01
(y_id number(10),
 y_name varchar2(20));
create table yedam02
(y_id number(10),
 y_name varchar2(20));
 
/* 3-1.부서번호를 입력하면 사원들 중에서
입사년도가 2000년 이전 입사한 사원은 yedam01 테이블에 입력하고,
입사년도가 2000년(포함) 이후 입사한 사원은 yedam02 테이블에 입력하는
y_proc 프로시저를 생성하시오. */
create or replace procedure y_proc
    (p_dept_no employees.department_id%TYPE)
IS
    cursor emp_cursor is
        select employee_id, last_name, hire_date
        from employees
        where department_id = p_dept_no;
        emp_rec emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        fetch emp_cursor
        into emp_rec;
        exit when emp_cursor%NOTFOUND;
            if to_char(emp_rec.hire_date, 'YYYY') < 2000 then
                insert into yedam01 values (emp_rec.employee_id, emp_rec.last_name);
            else
                insert into yedam02 values (emp_rec.employee_id, emp_rec.last_name);
            end if;
    END LOOP;
    close emp_cursor;
END y_proc;
/
EXECUTE y_proc(10);

rollback;
select department_id, hire_date, last_name from employees order by department_id;
select * from yedam01;
select * from yedam02;

/* 3-2.
1. 단, 부서번호가 없을 경우 "해당부서가 없습니다" 예외처리
2. 단, 해당하는 부서에 사원이 없을 경우 "해당부서에 사원이 없습니다" 예외처리
실행) EXECUTE y_proc(10);
     EXECUTE y_proc(30);
     EXECUTE y_proc(190); */
create or replace procedure y_proc
    (p_dept_no employees.department_id%TYPE)
IS
    cursor emp_cursor is
        select employee_id, last_name, hire_date
        from employees
        where department_id = p_dept_no;
        emp_rec emp_cursor%ROWTYPE;
        no_data exception;
        dname departments.department_id%TYPE;
BEGIN
    select department_id
    into dname
    from departments
    where department_id = p_dept_no;
    
    OPEN emp_cursor;
    LOOP
        fetch emp_cursor
        into emp_rec;
            if emp_cursor%ROWCOUNT = 0 then
                raise no_data;
            end if;
        exit when emp_cursor%NOTFOUND;
            if to_char(emp_rec.hire_date, 'YYYY') < 2000 then
                insert into yedam01 values (emp_rec.employee_id, emp_rec.last_name);
            else
                insert into yedam02 values (emp_rec.employee_id, emp_rec.last_name);
            end if;
    END LOOP;
    close emp_cursor;
EXCEPTION
    when no_data_found then
        DBMS_OUTPUT.PUT_LINE('해당 부서가 없습니다.');
    when no_data then
        DBMS_OUTPUT.PUT_LINE('해당 부서에 사원이 없습니다.');
END y_proc;
/

select * from departments;
EXECUTE y_proc(10);
EXECUTE y_proc(30);
EXECUTE y_proc(190);
rollback;