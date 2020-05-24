-- -------------------------
-- task condition:
-- When you add data to the Weather_Daily table, 
-- it checks to see if the date field is filled. 
-- If not - put the current date
-- ----------------------

CREATE or REPLACE TRIGGER weather_daily_date
BEFORE INSERT
ON WEATHER_DAILY
FOR EACH ROW
BEGIN
    if :new.WEATHER_DATE is null then
        :new.WEATHER_DATE := TO_DATE(TO_CHAR(sysdate, 'YYYY-MM-DD'), 'YYYY-MM-DD');
    end if;
END;


/*
-- ----------------------
-- SQL for check:
-- ----------------------
Insert into WEATHER_DAILY (LOCATION_CODE, RAINFALL, EVAPORATION, SUNSHINE, WIND_GUST_DIR, WIND_GUST_SPEED, RAINFALL_TOMORROW)
                           values ('Canberra', 12, 1.6, null, 'W', 30, 0);
Insert into WEATHER_DAILY (LOCATION_CODE, RAINFALL, EVAPORATION, SUNSHINE, WIND_GUST_DIR, WIND_GUST_SPEED, RAINFALL_TOMORROW)
                           values ('Adelaide', 12, 1.6, null, 'W', 30, 0);
Commit;

select *
from WEATHER_DAILY
where WEATHER_DATE >= TO_DATE(TO_CHAR(sysdate, 'YYYY-MM-DD'), 'YYYY-MM-DD');
*/
