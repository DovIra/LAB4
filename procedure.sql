-- -------------------------------------------------
-- task condition:
-- Adds a new chief to the weather station.
-- Exception: Weather station or employer not found
-- -------------------------------------------------

CREATE OR REPLACE Procedure add_Location_Chief(employer_first_name IN varchar2, lacation_name IN varchar2)
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
END;
