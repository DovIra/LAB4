declare
    emploee_name varchar(10);
    emploee_name_check varchar(10);
    location_name varchar(50);
    location_name_check varchar(50);

    cursor curr1 is
    select
        to_char(WEATHER_DATE, 'dd.mm.yyyy') as weather_date,
        LOCATION_CODE,
        is_raining(WEATHER_DATE, LOCATION_CODE) as rainToday,
        is_raining(WEATHER_DATE, LOCATION_CODE, 0) as rainTomorrow
    from WEATHER_DAILY
    order by LOCATION_CODE, weather_date;

    cursor curr2 is
    select t.time as time, t.temperature as temperature
    from table(get_hourly_data('Canberra', to_date('2017-01-07', 'yyyy-mm-dd'))) t
    order by time;
BEGIN
    emploee_name := 'Bob';
    location_name := 'Darwin';

    DBMS_OUTPUT.enable;

    DBMS_OUTPUT.put_line('Example with exception due to absent of employee in the staff table:');
    ADD_LOCATION_CHIEF(emploee_name || '_Absent', location_name);
    DBMS_OUTPUT.put_line('     ~~~');
    DBMS_OUTPUT.put_line('Example with exception due to absent of location in the corresponding table:');
    ADD_LOCATION_CHIEF(emploee_name, location_name || '_Absent');
    DBMS_OUTPUT.put_line('     ~~~');
    DBMS_OUTPUT.put_line('Adding exists employee as chief to the exists location:');
    DBMS_OUTPUT.put_line('Employee: ' || emploee_name);
    DBMS_OUTPUT.put_line('Location: ' || location_name);
    ADD_LOCATION_CHIEF(emploee_name, location_name);

    select location, LOCATION_CHIEF
    into location_name_check, emploee_name_check
    from WEATHER_DETAILS
    where location = location_name and LOCATION_CHIEF = emploee_name;

    DBMS_OUTPUT.put_line('Result: employee ' || emploee_name_check || ' is chief of the ' || location_name_check || ' location.');
    DBMS_OUTPUT.put_line('--------------');
    DBMS_OUTPUT.put_line('');

    DBMS_OUTPUT.put_line('Example for demonstrate work of pipelined function get_hourly_data().');
    DBMS_OUTPUT.put_line('temperature dynamics for 07/01/2017 for Canberra location:');
    FOR i IN curr2
    LOOP
        DBMS_OUTPUT.put_line('        at: ' || i.time || ' hour temperature is ' || i.temperature);
    END LOOP;
    DBMS_OUTPUT.put_line('--------------');
    DBMS_OUTPUT.put_line('');
    DBMS_OUTPUT.put_line('Example for demonstrate work of function IS_RAINING():');
    FOR weather_iteration IN curr1
    LOOP
        DBMS_OUTPUT.put_line('Location: ' || weather_iteration.LOCATION_CODE || ', date: ' || weather_iteration.weather_date || ' rain today: ' || weather_iteration.rainToday || ', rain tomorrow: ' || weather_iteration.rainTomorrow);
    END LOOP;

END;
