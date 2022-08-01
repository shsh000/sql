set serveroutput on;

--내장 함수(사용자 정의 함수)
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
--사원번호 100번의 급여
EXECUTE DBMS_OUTPUT.PUT_LINE(get_sal(100));

--위에서 만들어놓은 함수 사용 가능
DECLARE
    sal employees.salary%TYPE;
BEGIN
    sal := get_sal(100);
    DBMS_OUTPUT.PUT_LINE('The salary is : ' || sal);
END;
/

select job_id, get_sal(employee_id) as "SALARY"
from employees;

--tax 함수 생성
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

/* 1.숫자를 입력할 경우 입력된 숫자까지의 정수의 합계를 출력하는 함수를 작성하시오.
실행 예) EXECUTE DBMS_OUTPUT.PUT_LINE(ydsum(10)) */
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

/* 2.사원번호를 입력할 경우 다음 조건을 만족하는 결과가 출력되는 ydinc 함수를 생성하시오.
- 급여가 5000 이하이면 20% 인상된 급여 출력
- 급여가 10000 이하이면 15% 인상된 급여 출력
- 급여가 20000 이하이면 10% 인상된 급여 출력
- 급여가 20000 이상이면 급여 그대로 출력
실행) SELECT last_name, salary, YDINC(employee_id)
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

/* 3.사원번호를 입력하면 해당 사원의 연봉이 출력되는 yd_func 함수를 생성하시오.
->연봉계산 : (급여+(급여*인센티브퍼센트))*12
실행) SELECT last_name, salary, YD_FUNC(employee_id)
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

SELECT last_name, salary, YD_FUNC(employee_id) as "연봉"
FROM   employees;

/* 4.SELECT last_name, subname(last_name)
FROM   employees;
LAST_NAME     SUBNAME(LA
------------ ------------
King         K***
Smith        S****
예제와 같이 출력되는 subname 함수를 작성하시오. */
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

/* 5.사원번호를 입력하면 인상된 급여가 출력되도록 inc_sal 함수 생성하시오. */
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

/* 1.사원번호를 입력하면
last_name + first_name 이 출력되는 
y_yedam 함수를 생성하시오.
실행) EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174))
출력 예)  Abel Ellen */
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

/* 2-1.사원번호를 입력하면 소속 부서명를 출력하는 y_dept 함수를 생성하시오.
(단, 다음과 같은 경우 예외처리(exception)
 입력된 사원이 없거나 소속 부서가 없는 경우 -> 사원이 아니거나 소속 부서가 없습니다.) */
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
        return '사원이 아니거나 소속 부서가 없습니다.';
END y_dept;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(200));
/

/* 3.부서번호를 입력할 경우
부서에 속한 사원의 사원이름, 부서이름을 출력하는 y_test 함수를 생성하시오.
단, 소속된 부서에 사원이 없을 경우 예외처리(소속된 사원이 없습니다.) */
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
        v_name := v_name || '사원이름 : ' || emp_rec.last_name ||
        ', 부서명 : ' || emp_rec.department_name || chr(13); --chr(13) = 줄 바꿈
        v_count := v_count + 1;
    END LOOP;
    
    if v_count = 0 then
        raise no_data;
    END IF;
    return v_name;
EXCEPTION
    when no_data then
        return '소속된 사원이 없습니다.';
END y_test;
/
execute dbms_output.put_line(y_test(50));