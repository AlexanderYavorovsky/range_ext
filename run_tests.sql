\i test_data.sql;

SELECT *, range_len(i4r) FROM int4ranges;
SELECT *, range_len(i8r) FROM int8ranges;
SELECT *, range_len(nr) FROM numranges;
SELECT *, range_len(tr) FROM tsranges;
SELECT *, range_len(tzr) FROM tstzranges;


SELECT i4r, 4, distance(4, i4r) FROM int4ranges;
SELECT i4mr, 3, nearest_range_to_value(3, i4mr) FROM int4multiranges;


SELECT abs('-1 day'::interval), abs('-10 seconds'::interval);


SELECT tr,
    '2024-01-01 09:01'::timestamp,
    distance('2024-01-01 09:01'::timestamp, tr) 
FROM tsranges;

SELECT tmr,
    '2024-01-01 09:01'::timestamp,
    nearest_range_to_value('2024-01-01 09:01'::timestamp, tmr)
FROM tsmultiranges;


SELECT make_shift_template('2024-01-01'::date, '2024-01-02'::date, '09:00'::time, '18:00'::time, false);
SELECT make_shift_template('2024-01-01'::date, '2024-01-02'::date, '18:00'::time, '09:00'::time, true);


DROP TABLE IF EXISTS shift_templates;
CREATE TABLE shift_templates (
    id SERIAL PRIMARY KEY,
    shift_template tsmultirange
);

INSERT INTO shift_templates (shift_template)
    (SELECT make_shift_template('2024-01-01'::date, '2024-01-02'::date,
    '09:00'::time, '21:00'::time, false));
INSERT INTO shift_templates (shift_template)
    (SELECT make_shift_template('2024-01-01'::date, '2024-01-02'::date,
    '21:00'::time, '09:00'::time, true));

SELECT * FROM shift_templates;


SELECT *,
    get_payment_for_period(
        '2024-01-01'::date,
        '2024-01-02'::date,
        '09:00'::time,
        '21:00'::time,
        '21:00'::time,
        '09:00'::time,
        10,
        20,
        worktime)
FROM employee_test;