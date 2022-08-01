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

/* 부서번호(치환변수 사용)를 입력할 경우
사원이름, 소속된 부서이름을 출력하는 PL/SQL 출력 */

DECLARE
    v_ename employees.last_name%TYPE;
    v_dname departments.department_name%TYPE;
BEGIN
    select e.last_name, d.department_name
    into v_ename, v_dname
    from employees e, departments d
    where e.department_id = d.department_id
    and e.department_id = &id;
    --사원번호를 입력할 경우
    --and e.employee_id = &id;
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_ename || ', ' || '소속부서 : ' || v_dname);
END;
/

select * from departments;
select * from employees;

--명시적 커서
DECLARE
    cursor c_emp_cursor IS
        --선언
        select employee_id, last_name
        from employees
        where department_id = 20;
    v_empno employees.employee_id%TYPE;
    v_lname employees.last_name%TYPE;
BEGIN
    --오픈
    open c_emp_cursor;
    LOOP
        --인출
        fetch c_emp_cursor
        into v_empno, v_lname;
        EXIT when c_emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('20번 부서의 사원번호 : ' || v_empno || ', ' || '사원이름 : ' || v_lname);
    END LOOP;
    --닫기
    CLOSE c_emp_cursor;
END;
/

/* 부서번호(치환변수 사용)를 입력할 경우
사원이름, 소속된 부서이름을 출력하는 PL/SQL 출력 */
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
        DBMS_OUTPUT.PUT_LINE(&id || '번 부서 사원이름 : ' || v_ename || ', ' || '소속부서 : ' || v_dname);
    END LOOP;
    CLOSE c_emp_cursor;
END;
/

create table temp_list(empid, empname)
as
select employee_id, last_name
from employees
where employee_id = 0;

/* 커서 및 레코드
부서번호 20번인 사원들의 데이터 temp_list에 넣어줌 */
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

--커서 for loop
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

--50번 부서에 있는 사원의 급여 10% 인상
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

/* 1.사원(employees) 테이블에서
사원의 사원번호, 사원이름, 입사년도를
다음 기준에 맞게 각각 test01, test02에 입력하시오.

입사년도가 2000년(포함) 이전에 입사한 사원은 test01 테이블에 입력
입사년도가 2000년 이후에 입사한 사원은 test02 테이블에 입력
반드시 cursor 사용
for loop 기본 사용 */
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

/* 2.사원(employees) 테이블에서
사원의 사원번호, 사원이름, 입사년도를
다음 기준에 맞게 각각 test01, test02에 입력하시오.

입사년도가 2000년(포함) 이전에 입사한 사원은 test01 테이블에 입력
입사년도가 2000년 이후에 입사한 사원은 test02 테이블에 입력
반드시 cursor 사용
기본 loop 사용(declare -> open -> fetch -> close) */
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

/* 3.부서번호를 입력할 경우(&치환변수 사용)
해당하는 부서의 사원이름, 입사일자, 부서명을 출력하시오.(단, cursor 사용) */
DECLARE
    cursor c_emp_cursor is
    select e.last_name, e.hire_date, d.department_name
    from employees e, departments d
    where e.department_id = d.department_id
    and e.department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || emp_rec.last_name || ', ' ||
    '입사일자 : ' || emp_rec.hire_date || ', ' || '부서명 : ' || emp_rec.department_name);    
    END LOOP;
END;
/

/* 4.부서번호를 입력(&사용)하면 
소속된 사원의 사원번호, 사원이름, 부서번호를 출력하는 PL/SQL을 작성하시오.(단, CURSOR 사용) */
DECLARE
    cursor c_emp_cursor is
    select employee_id, last_name, department_id
    from employees
    where department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || emp_rec.employee_id || ', ' ||
    '사원이름 : ' || emp_rec.last_name || ', ' || '부서번호 : ' || emp_rec.department_id);  
    END LOOP;
END;
/

/* 5.부서번호를 입력(&사용)할 경우 
사원이름, 급여, 연봉->(급여*12+(급여*nvl(커미션퍼센트,0)*12))
을 출력하는  PL/SQL을 작성하시오.(단, cursor 사용)*/
DECLARE
    cursor c_emp_cursor is
    select last_name, salary, salary*12+(salary*nvl(commission_pct, 0)*12) annsal
    from employees
    where department_id = &id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || emp_rec.last_name || ', ' || 
    '급여 : ' || emp_rec.salary || ', ' || 
    '연봉 : ' || emp_rec.annsal); 
    END LOOP;
END;
/

/* 6.부서번호를 입력(&사용)할 경우 
해당 부서의 업무(job_id)별 평균 급여를 출력하는 PL/SQL을 작성하시오. */
DECLARE
    cursor c_emp_cursor is
    select job_id, round(avg(nvl(salary, 0)),0) salary
    from employees
    where department_id = &id
    group by job_id;
BEGIN
    for emp_rec IN c_emp_cursor
    LOOP
    DBMS_OUTPUT.PUT_LINE('부서업무 : ' || emp_rec.job_id || ', ' || '평균 급여 : ' || emp_rec.salary);
    END LOOP;
END;
/

/* 7.사원(employees) 테이블에서
사원의 사원번호, 사원이름, 입사연도를 
다음 기준에 맞게 각각 test01, test02에 입력하시오.

급여가 5000(포함) 이상이면 test01 테이블에 입력
급여가 5000 미만이면 test02 테이블에 입력
** 반드시 cursor 사용 */
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

--미리 정의한 예외 트랩(no_data_found)
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    select last_name
    into v_name
    from employees
    where employee_id = &id;
EXCEPTION
    when no_data_found then
        DBMS_OUTPUT.PUT_LINE('해당사원이 없습니다.');
END;
/

--미리 정의한 예외 트랩(too_many_rows)
DECLARE
    v_name employees.last_name%TYPE;
BEGIN
    select last_name
    into v_name
    from employees
    where department_id = &id;
EXCEPTION
    when too_many_rows then
        DBMS_OUTPUT.PUT_LINE('한 개 이상의 행이 질의되었습니다.');
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

--RAISE_APPLICATION_ERROR 프로시저
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
    RAISE_APPLICATION_ERROR (-20999, '해당 사원이 없습니다.');
    --DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
END;
/

--보통 이 방식으로 많이 사용
BEGIN
    delete from employees
    where last_name = '&id';
    if SQL%NOTFOUND then
        RAISE_APPLICATION_ERROR (-20999, '해당 사원이 없습니다.');
    end if;
END;
/