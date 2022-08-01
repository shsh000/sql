--package 패키지

--패키지 명세(스펙, specification) 생성
CREATE OR REPLACE PACKAGE comm_pkg
IS
    v_std_comm NUMBER := 0.10; --공용 변수 v_std_comm
    PROCEDURE reset_comm(p_new_comm NUMBER); --공용 프로시저 reset_comm
END comm_pkg;
/
/* 공용 프로시저 사용법
comm_pkg.reset_comm(0); */

--패키지 바디 생성
CREATE OR REPLACE PACKAGE BODY comm_pkg
IS
    --전용 function
    FUNCTION validate(p_comm NUMBER)
    RETURN boolean
IS
    v_max_comm employees.commission_pct%TYPE;
BEGIN
    select MAX(commission_pct)
    into v_max_comm
    from employees;
    RETURN (p_comm BETWEEN 0.0 AND v_max_comm); --v_max_comm = 0.9
    --입력값이 0.0 ~ 0.9 사이면 true 리턴, 범위를 벗어나면 프로시저 else에 있는 오류 출력
END validate;

--공용 프로시저
PROCEDURE reset_comm (p_new_comm NUMBER)
IS
BEGIN
    if validate(p_new_comm) then
        v_std_comm := p_new_comm;
    else
        RAISE_APPLICATION_ERROR(-20210, 'Bad Commission');
    END IF;
END reset_comm;
END comm_pkg;
/

EXECUTE comm_pkg.reset_comm(0.15);
EXECUTE comm_pkg.reset_comm(1);

--패키지 바디 없이 생성 start
create or replace package global_consts
IS
    c_mile_2_kilo constant number := 1.6093;
    c_kilo_2_mile constant number := 0.6214;
    c_yard_2_meter constant number := 0.9144;
    c_meter_2_yard constant number := 1.0936;
END global_consts;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('20 miles = ' || 20 * global_consts.c_mile_2_kilo || ' km');
END;
/
create function mtr2yrd(p_m NUMBER)
    return number
IS
BEGIN
    return (p_m * global_consts.c_meter_2_yard);
END mtr2yrd;
/
EXECUTE DBMS_OUTPUT.PUT_LINE(mtr2yrd(1));
--패키지 바디 없이 생성 end

--package 정보 조회
select text
from user_source
where name = 'COMM_PKG' and type = 'PACKAGE'
order by LINE;

--package body 정보 조회
select text
from user_source
where name = 'COMM_PKG' and type = 'PACKAGE BODY'
order by LINE;