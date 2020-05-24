CREATE OR REPLACE package weather_package is
    PROCEDURE add_Location_Chief(employer_first_name IN varchar2, lacation_name IN varchar2);

    FUNCTION is_raining(
    v_date WEATHER_DAILY.WEATHER_DATE%TYPE,
    v_location_code WEATHER_DAILY.LOCATION_CODE%TYPE,
    is_today integer default 1
    ) RETURN varchar2;
    -- pipelined;
END weather_package;
/
CREATE OR REPLACE package body weather_package is
    Procedure add_Location_Chief(employer_first_name IN varchar2, lacation_name IN varchar2)
    IS
        cnt number;
        staff_ID number;
        location_code varchar(50);
        no_employer EXCEPTION;
        no_location EXCEPTION;
    
    BEGIN
        SELECT COALESCE(count(*), 0)  INTO cnt
        FROM STAFF
        WHERE STAFF.FIRST_NAME = employer_first_name;
    
        if cnt = 0 then
            RAISE no_employer;
        end if;
    
        SELECT ID INTO staff_ID
        FROM STAFF
        WHERE STAFF.FIRST_NAME = employer_first_name;
    
        SELECT COALESCE(count(*), 0)  INTO cnt
        FROM LOCATIONS
        WHERE LOCATIONS.LOCATION_NAME = lacation_name;
    
        if cnt = 0 then
            RAISE no_location;
        end if;
    
        SELECT LOCATION_NAME INTO location_code
        FROM LOCATIONS
        WHERE LOCATIONS.LOCATION_NAME = lacation_name;
    
        insert into LOCATION_CHIEF(staff_id, location_code) values (staff_ID, location_code);
        commit;
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- raise_application_error(-20001,'Unique constraint violated: or location ' || lacation_name || ' already has chief, or employee ' || employer_first_name || ' already is chief.');
            DBMS_OUTPUT.put_line('Unique constraint violated: or location ' || lacation_name || ' already has chief, or employee ' || employer_first_name || ' already is chief.');
        WHEN no_location THEN
            -- raise_application_error(-20001,'Location ' || lacation_name || ' not found.');
            DBMS_OUTPUT.put_line('Location ' || lacation_name || ' not found.');
        WHEN no_employer THEN
            -- raise_application_error(-20001,'Employee ' || employer_first_name || ' not found.');
            DBMS_OUTPUT.put_line('Employee ' || employer_first_name || ' not found.');
        WHEN OTHERS THEN
            -- raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
            DBMS_OUTPUT.put_line('An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    END add_Location_Chief;   
    
    FUNCTION is_raining(
    v_date WEATHER_DAILY.WEATHER_DATE%TYPE,
    v_location_code WEATHER_DAILY.LOCATION_CODE%TYPE,
    is_today integer default 1
    ) RETURN varchar2
    IS
        v_rainfall number(5, 2);
    BEGIN
        if is_today = 1 then
            SELECT RAINFALL
            INTO v_rainfall
            FROM WEATHER_DAILY
            WHERE WEATHER_DATE = v_date AND LOCATION_CODE = v_location_code;
        else
            SELECT RAINFALL_TOMORROW
            INTO v_rainfall
            FROM WEATHER_DAILY
            WHERE WEATHER_DATE = v_date AND LOCATION_CODE = v_location_code;
        end if;

        if v_rainfall > 1 then
            RETURN 'Yes';
        else
            RETURN 'No';
        end if;
    END is_raining;
END weather_package;

