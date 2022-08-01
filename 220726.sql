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

--선언된 변수명과 테이블 컬럼명은 같으면 X
--오류 메시지는 안 뜨지만 사용하면 X
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

--%TYPE => employees 테이블/hire_date, salary 컬럼의 데이터 타입을 그대로 가져옴
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

--치환변수
select *
from employees
where employee_id = &id;

select &&id, department_id
from employees
where &id = 100;

select &id, department_id
from employees
where &id = 100;

--변수 선언 해제
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

--상위블럭
DECLARE
v_outer_variable varchar2(20) := 'GLOBAL VARIABLE';
BEGIN
    --하위블럭
    DECLARE
    v_inner_variable varchar2(20) := 'LOCAL VARIABLE';
    BEGIN
    DBMS_OUTPUT.PUT_LINE(v_inner_variable);
    DBMS_OUTPUT.PUT_LINE(v_outer_variable);
    END;
DBMS_OUTPUT.PUT_LINE(v_outer_variable);
/* 하위블럭에서 선언된 변수이기 때문에 상위블럭에서 사용 불가
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

/*사원번호를 입력(치환변수 사용&)할 경우
사원이름, 사원이름, 부서이름 출력 */
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
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empno || ', ' || '사원이름 : ' || v_lname || ', ' || '부서이름 : ' || v_dname);
END;
/

/*사원번호를 입력(치환변수 사용&)할 경우
사원이름, 급여, 연봉 출력 */
DECLARE
v_lname employees.last_name%TYPE;
v_sal employees.salary%TYPE;
v_ann employees.salary%TYPE;
    BEGIN
    select last_name, salary, salary*12+(nvl(salary, 0)*nvl(commission_pct, 0)*12)
    into v_lname, v_sal, v_ann
    from employees
    where employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_lname);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || v_sal);
    DBMS_OUTPUT.PUT_LINE('연봉 : ' || v_ann);
END;
/

/*사원번호를 입력(치환변수사용&)할 경우
입사일이 2000년 이후(2000년 포함)이면 'New employee' 출력
2000년 이전이면 'Career employee' 출력*/
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

--사원번호 176번 행 삭제
--SQL%ROWCOUNT : 가장 최근 SQL문에 적용된 행의 갯수
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

/*사원번호를 입력(치환변수사용&)할 경우
사원들 중 2000년 이후(2000년 포함)에 입사한 사원의 사원번호, 
사원이름, 입사일을 test01 테이블에 입력하고,
2000년 이전에 입사한 사원의 사원번호,사원이름,입사일을 test02 테이블에 입력하시오.*/
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
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empno || ', ' || '급여 : ' || v_sal || ', ' || '인상된 급여 : ' || v_salin);
    elsif v_sal <= 10000 then
    v_salin := v_sal*1.15;
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empno || ', ' || '급여 : ' || v_sal || ', ' || '인상된 급여 : ' || v_salin);
    elsif v_sal <= 15000 then
    v_salin := v_sal*1.1;
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empno || ', ' || '급여 : ' || v_sal || ', ' || '인상된 급여 : ' || v_salin);
    else
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empno || ', ' || '급여 : ' || v_sal || ', ' || '인상된 급여 : ' || v_salin);
    end if;
end;
/

/*사원번호를 입력할 경우
해당 사원을 삭제하는 PL/SQL을 작성하시오.
단, 해당사원이 없는 경우 "해당사원이 없습니다." 출력 */
BEGIN
    delete from employees
    where employee_id = &id;
    if SQL%NOTFOUND then
    DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
    else
    DBMS_OUTPUT.PUT_LINE('삭제되었습니다.');
    END IF;
END;
/

/* 직원들이 사번, 급여 증가치(%)만 입력하면 Employees테이블에
쉽게 사원의 급여를 갱신할 수 있도록 PL/SQL을 작성하세요.
만약 입력한 사원이 없는 경우에는 ‘No search employee!!’라는 메시지를 출력하세요.

급여 = 급여*(1+급여증가치/100)
or
급여 = 급여+(급여*(급여증가치/100)) */
DECLARE
v_per number(3) := &vp;
    BEGIN
    update employees
    set salary = salary*(1 + v_per/100)
    where employee_id = &id;
    if SQL%NOTFOUND then
    DBMS_OUTPUT.PUT_LINE('No search employee');
    else
    DBMS_OUTPUT.PUT_LINE('갱신되었습니다.');
    END IF;
END;
/

rollback;

/* 생년월일을 입력(치환변수사용)할 경우 해당년도의 띠를 출력하시오
mod((현재년도-본인생년), 12) = 본인 띠 */
DECLARE
v_birth number(10) := &no;
v_ddi number(10);
    BEGIN
    v_ddi := mod(v_birth, 12);
    if v_ddi = 0 then
    DBMS_OUTPUT.PUT_LINE('원숭이띠');
    elsif v_ddi = 1 then
    DBMS_OUTPUT.PUT_LINE('닭띠');
    elsif v_ddi = 2 then
    DBMS_OUTPUT.PUT_LINE('개띠');
    elsif v_ddi = 3 then
    DBMS_OUTPUT.PUT_LINE('돼지띠');
    elsif v_ddi = 4 then
    DBMS_OUTPUT.PUT_LINE('쥐띠');
    elsif v_ddi = 5 then
    DBMS_OUTPUT.PUT_LINE('소띠');
    elsif v_ddi = 6 then
    DBMS_OUTPUT.PUT_LINE('호랑이띠');
    elsif v_ddi = 7 then
    DBMS_OUTPUT.PUT_LINE('토끼띠');
    elsif v_ddi = 8 then
    DBMS_OUTPUT.PUT_LINE('용띠');
    elsif v_ddi = 9 then
    DBMS_OUTPUT.PUT_LINE('뱀띠');
    elsif v_ddi = 10 then
    DBMS_OUTPUT.PUT_LINE('말띠');
    elsif v_ddi = 11 then
    DBMS_OUTPUT.PUT_LINE('양띠');
    else
    DBMS_OUTPUT.PUT_LINE('양띠');
    end if;
end;
/