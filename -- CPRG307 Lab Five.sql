-- CPRG307 Lab Five Prelab
-- Brent Martin

--1
Set SERVEROUTPUT ON
DECLARE
c_ata_contractNum CONSTANT number := 8;
v_ata_clientId VARCHAR2(20);


BEGIN
    SELECT client_id
    INTO v_ata_clientId
    FROM ata_contract
    WHERE contract_number = c_ata_contractNum;

    EXCEPTION
        WHEN no_data_found THEN
            DBMS_OUTPUT.PUT_LINE('Contract not found');

END;
/


--2
Set SERVEROUTPUT ON
DECLARE
c_ata_clientnum CONSTANT VARCHAR2(20) := '0000020';
v_ata_clientFee number;


BEGIN
    SELECT fee
    INTO v_ata_clientFee
    FROM ata_contract
    WHERE client_id = c_ata_clientNum;

    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('TOO MANY ROWS');

END;
/

--3
Set SERVEROUTPUT ON
DECLARE
c_ata_priceIncrease CONSTANT number := 500.00;
c_ata_retirementType CONSTANT VARCHAR2(20) := 'Retirement Party';
ex_no_update EXCEPTION;

BEGIN
    Update ata_contract
        SET fee = (fee + c_ata_priceIncrease)
        WHERE event_type = c_ata_retirementType;

    IF SQL%NOTFOUND THEN
        RAISE ex_no_update;
    END IF;

EXCEPTION
    WHEN ex_no_update THEN
            DBMS_OUTPUT.PUT_LINE('No update made');
   

END;
/

--4
Set SERVEROUTPUT ON
DECLARE
c_ata_priceIncrease CONSTANT number := 500.00;
c_ata_retirementType CONSTANT VARCHAR2(20) := 'Retirement Party';

BEGIN
    Update ata_contract
        SET fee = (fee + c_ata_priceIncrease)
        WHERE event_type = c_ata_retirementType;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR (-20001, 'No update made');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Change made');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);

END;
/

-- CPRG307 Lab Four
-- Brent Martin

Set SERVEROUTPUT ON
--1
DECLARE
    --Constant Vars
    c_emp_smallCut CONSTANT NUMBER := 0.25;
    c_emp_largeCut CONSTANT NUMBER := 0.50;
    c_emp_salMin CONSTANT NUMBER := 100.00;
    c_emp_salIncrease CONSTANT NUMBER :=   0.10;
    c_emp_commissionChecker CONSTANT NUMBER := 0.22;
    v_emp_presidentTitle CONSTANT VARCHAR2(9) := 'PRESIDENT';
    v_emp_managerTitle CONSTANT VARCHAR2(9) := 'MANAGER';

    -- Vars before loop
    v_emp_salAverage NUMBER;
    v_emp_presidentSal NUMBER;
   
    -- Vars in loop
    v_emp_empSal NUMBER;
    v_emp_empComm NUMBER;
    v_emp_empDept NUMBER;
    v_emp_smallPayCut NUMBER;
    v_emp_bigPayCut NUMBER;
    v_emp_reducedPay NUMBER;
    v_emp_increasedPay NUMBER;
    v_emp_commissionCheckVal NUMBER;
    v_emp_newComission NUMBER;
    v_emp_updaterSal NUMBER;
    v_emp_updaterComm NUMBER;
    v_emp_managerCheck NUMBER;  
 
    --cursor for emp table
    Cursor cur_empTable_Info IS
        select *
        from emp;

BEGIN
    --getting average of comapanies salaries
    SELECT avg(sal)
        INTO v_emp_salAverage
        FROM emp;

    --query to grab presidents salary amount
    SELECT sal
        INTO v_emp_presidentSal
        FROM emp
        WHERE job = v_emp_presidentTitle;


    --looping through employees to check wages
    FOR empLoop IN cur_empTable_Info LOOP
        v_emp_empSal := empLoop.sal;
        v_emp_empComm := empLoop.comm;
        v_emp_empDept := empLoop.deptno;

        CASE
            WHEN --checking for wage greater than presidents
                v_emp_empSal > v_emp_presidentSal
            THEN
                v_emp_smallPayCut := v_emp_presidentSal - (v_emp_presidentSal * c_emp_smallCut);--calculations to figure out salary cuts
                v_emp_bigPayCut := v_emp_empSal * c_emp_largeCut;
               
                IF --checking which pay cut to apply
                    v_emp_bigPayCut < v_emp_smallPayCut
                THEN
                    v_emp_reducedPay := v_emp_bigPayCut; --applying large cut
                ELSE
                    v_emp_reducedPay := v_emp_smallPayCut; --applying small cut
                END IF;

                v_emp_updaterSal := v_emp_reducedPay; -- assigning cut value to updater var

            WHEN --checking if wage is below min
                v_emp_empSal < c_emp_salMin
            THEN
                v_emp_increasedPay := v_emp_empSal + (v_emp_empSal * c_emp_salIncrease); --calculation of increase

                IF --checking if increased wage is above original average
                    v_emp_increasedPay < v_emp_salAverage
                THEN
                    v_emp_updaterSal := v_emp_increasedPay; --assigning updater var to increased wage if its below average wage
                END IF;

            ELSE -- if no checks are met then values remain the same
                v_emp_updaterSal := empLoop.sal;
           
            END CASE;  
           
            IF --checking if commission is greater than wage
                v_emp_empComm > v_emp_empSal
            THEN
                v_emp_commissionCheckVal := v_emp_empSal + (v_emp_empSal * c_emp_commissionChecker); --calculation to find 22% of wage
               
                IF --checking if commisssion is over 22% greater
                    v_emp_empComm > v_emp_commissionCheckVal
                THEN
                    SELECT min(comm) into v_emp_newComission from emp where deptno = v_emp_empDept; --finding smallest commission val based on department
                    v_emp_updaterComm := v_emp_newComission;  --setting updater to be min commission
                END IF;
            ELSE
                v_emp_updaterComm := empLoop.comm;

            END IF;                

                BEGIN    

                    UPDATE EMP --updating table with new values
                        SET SAL = v_emp_updaterSal, COMM = v_emp_updaterComm
                        WHERE empno = empLoop.empno;          

                    Select empno into v_emp_managerCheck from emp where deptno = v_emp_empDept AND job = v_emp_managerTitle; --finding departments manager                      

                    EXCEPTION --when a manager is not found it reverts the change
                        WHEN no_data_found THEN                
                        ROLLBACK;

                END;

                COMMIT;
                           
        END Loop;  


END;
/

-- test statements
-- UPDATE emp
--     SET sal = 6000
--     WHERE empno = 7934;

-- UPDATE emp
--     SET sal = 90
--     WHERE empno = 7900;

-- UPDATE emp
--     SET comm = 30000
--     WHERE empno = 7876;

-- UPDATE emp
--     SET comm = 3
--     WHERE empno = 7788;

-- UPDATE emp
--     SET sal = 7000
--     WHERE empno = 8888;


--Added my own column to allow test for an employee without a manger
-- INSERT INTO EMP VALUES (8888,'Brent','CLERK',NULL,TO_DATE('23-JAN-2012','DD-MON-YYYY'),1300,NULL,40);