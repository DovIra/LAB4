CREATE OR REPLACE package weather_package is

    PROCEDURE add_Location_Chief(employer_first_name IN varchar2, lacation_name IN varchar2);

    TYPE t_hourly is RECORD
     (
      location_code  VARCHAR2(50),
        weather_date   DATE,
        time number,
        wind_dir       VARCHAR2(3),
        wind_speed     NUMBER(5, 2),
        humidity       NUMBER(3),
        pressure       NUMBER(10, 2),
        cloud          NUMBER,
        temperature    NUMBER(5, 2)
     );
     
     TYPE t_hourly_table is TABLE OF t_hourly;
    
    function get_hourly_data(v_location in varchar, v_date in date)
        return t_hourly_table pipelined; 

    FUNCTION is_raining(
        v_date WEATHER_DAILY.WEATHER_DATE%TYPE,
        v_location_code WEATHER_DAILY.LOCATION_CODE%TYPE,
        is_today integer default 1
    ) RETURN varchar2;
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
            DBMS_OUTPUT.put_line('Unique constraint violated: or location ' || lacation_name || ' already has chief, or employee ' || employer_first_name || ' already is chief.');
        WHEN no_location THEN
            DBMS_OUTPUT.put_line('Location ' || lacation_name || ' not found.');
        WHEN no_employer THEN
            DBMS_OUTPUT.put_line('Employee ' || employer_first_name || ' not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    END add_Location_Chief;   
    
    function get_hourly_data(v_location in varchar, v_date in date)
          return t_hourly_table pipelined as
    begin
      for i in (
            select LOCATION_CODE, WEATHER_DATE, TIME, WIND_DIR, WIND_SPEED, HUMIDITY, PRESSURE, CLOUD, TEMPERATURE
            from WEATHER_HOURLY
            where WEATHER_DATE=v_date and LOCATION_CODE = v_location
        )
     loop
       pipe row(i);
      end loop;
     return;
    end get_hourly_data;

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

