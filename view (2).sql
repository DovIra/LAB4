-- ----------------------------
-- previously created views of WEATHER_HOURLY_3PM and WEATHER_HOURLY_9AM were replaced by the pipelined function get_hourly_data()
-- 
-- the function IS_RAINING() was added to VIEW weather_details 
-- to determine whether precipitation will occur on a specified date ('Yes') or not ('No'). 
-- The same function is used to determine precipitation for tomorrow (relative to the current).
-- 
-- to this view was added field with  chief's name of the location - LOCATION_CHIEF.
-- ----------------------------
CREATE VIEW weather_details AS
SELECT
       to_date(TO_CHAR(WEATHER_DAILY.WEATHER_DATE, 'YYYY-mm-dd'), 'YYYY-mm-dd') as WeatherDate,
       LOCATIONS.LOCATION_NAME as Location,
       S.FIRST_NAME AS LOCATION_CHIEF,
       UU.MINTEMP as MinTemp,
       UU.MAXTEMP as MaxTemp,
       WEATHER_DAILY.RAINFALL as Rainfall,
       WEATHER_DAILY.EVAPORATION as Evaporation,
       WEATHER_DAILY.SUNSHINE as Sunshine,
       WEATHER_DAILY.WIND_GUST_DIR as WindGustDir,
       WEATHER_DAILY.WIND_GUST_SPEED as WindGustSpeed,
       WH9AM.WIND_DIR AS WindDir9am,
       WH3PM.WIND_DIR AS WindDir3pm,
       WH9AM.WIND_SPEED AS WindSpeed9am,
       WH3PM.WIND_SPEED AS WindSpeed3pm,
       WH9AM.HUMIDITY AS Humidity9am,
       WH3PM.HUMIDITY AS Humidity3pm,
       WH9AM.PRESSURE AS Pressure9am,
       WH3PM.PRESSURE AS Pressure3pm,
       WH9AM.CLOUD AS Cloud9am,
       WH3PM.CLOUD AS Cloud3pm,
       WH9AM.TEMPERATURE AS Temp9am,
       WH3PM.TEMPERATURE AS Temp3pm,
       CASE WHEN WEATHER_DAILY.RAINFALL > 1 THEN 'Yes' ELSE 'No' END AS RainToday,
       IS_RAINING(WEATHER_DAILY.WEATHER_DATE, WEATHER_DAILY.LOCATION_CODE, 1) as RainToday_CHECK,
       WEATHER_DAILY.RAINFALL_TOMORROW as RISK_MM,
       CASE WHEN WEATHER_DAILY.RAINFALL_TOMORROW > 1 THEN 'Yes' ELSE 'No' END as RainTomorrow,
       IS_RAINING(WEATHER_DAILY.WEATHER_DATE, WEATHER_DAILY.LOCATION_CODE, 0) as RainTomorrow_CHECK
FROM WEATHER_DAILY
JOIN LOCATIONS ON LOCATIONS.LOCATION_NAME = WEATHER_DAILY.location_code
LEFT JOIN (
    SELECT
           WEATHER_DAILY.LOCATION_CODE,
           WEATHER_DAILY.WEATHER_DATE,
           MIN(WEATHER_HOURLY.TEMPERATURE) AS MINTEMP,
           MAX(WEATHER_HOURLY.TEMPERATURE) AS MAXTEMP
    FROM WEATHER_DAILY
    JOIN WEATHER_HOURLY ON
            WEATHER_DAILY.LOCATION_CODE = WEATHER_HOURLY.LOCATION_CODE AND
            WEATHER_DAILY.WEATHER_DATE = WEATHER_HOURLY.WEATHER_DATE
    GROUP BY WEATHER_DAILY.LOCATION_CODE, WEATHER_DAILY.WEATHER_DATE
    ) uu ON uu.LOCATION_CODE = WEATHER_DAILY.LOCATION_CODE AND uu.WEATHER_DATE = WEATHER_DAILY.WEATHER_DATE
left join table(get_hourly_data(WEATHER_DAILY.LOCATION_CODE , WEATHER_DAILY.WEATHER_DATE)) WH9AM on WH9AM.time = 9
left join table(get_hourly_data(WEATHER_DAILY.LOCATION_CODE , WEATHER_DAILY.WEATHER_DATE)) WH3PM on WH3PM.time = 15
LEFT JOIN LOCATION_CHIEF LC on LOCATIONS.LOCATION_NAME = LC.LOCATION_CODE
LEFT JOIN STAFF S on LC.STAFF_ID = S.ID
;