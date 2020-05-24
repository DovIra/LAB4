-- --------------------------------------------
-- pipelined function to determine all weather measurements 
-- for a specific date for a specific location
-- 
-- parameters:
-- v_date - specify date - date type
-- v_location_code - specify location - varchar
-- 
-- SQL for test:
-- select * from table(get_hourly_data('Canberra', to_date('2017-01-07', 'yyyy-mm-dd')))
-- --------------------------------------------
create type t_hourly is object
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

CREATE TYPE t_hourly_table as TABLE OF t_hourly;

create or replace function get_hourly_data(v_location in varchar, v_date in date)
          return t_hourly_table pipelined as
begin
  for i in (
        select LOCATION_CODE, WEATHER_DATE, TIME, WIND_DIR, WIND_SPEED, HUMIDITY, PRESSURE, CLOUD, TEMPERATURE
        from WEATHER_HOURLY
        where WEATHER_DATE=v_date and LOCATION_CODE = v_location
    )
 loop
   pipe row (t_hourly(i.LOCATION_CODE, i.WEATHER_DATE, i.TIME, i.WIND_DIR, i.WIND_SPEED, i.HUMIDITY, i.PRESSURE, i.CLOUD, i.TEMPERATURE));
  end loop;
 return;
end;
-- --------------------------------------------
-- simple function for determining:
-- on a specified date in a specified location
-- precipitation will occur or not.
-- 
-- parameters:
-- v_date - date type
-- v_location_code - varchar
-- --------------------------------------------

CREATE OR REPLACE FUNCTION is_raining(
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
    END;


