DROP TABLE IF EXISTS int4ranges;
CREATE TABLE int4ranges (
    id serial PRIMARY KEY,
    i4r int4range
);

DROP TABLE IF EXISTS int8ranges;
CREATE TABLE int8ranges (
    id serial PRIMARY KEY,
    i8r int8range
);

DROP TABLE IF EXISTS numranges;
CREATE TABLE numranges (
    id serial PRIMARY KEY,
    nr numrange
);

DROP TABLE IF EXISTS tsranges;
CREATE TABLE tsranges (
    id serial PRIMARY KEY,
    tr tsrange
);

DROP TABLE IF EXISTS tstzranges;
CREATE TABLE tstzranges (
    id serial PRIMARY KEY,
    tzr tstzrange
);

DROP TABLE IF EXISTS dateranges;
CREATE TABLE dateranges (
    id serial PRIMARY KEY,
    dr daterange
);



DROP TABLE IF EXISTS int4multiranges;
CREATE TABLE int4multiranges (
    id serial PRIMARY KEY,
    i4mr int4multirange
);

DROP TABLE IF EXISTS tsmultiranges;
CREATE TABLE tsmultiranges (
    id serial PRIMARY KEY,
    tmr tsmultirange
);


DROP TABLE IF EXISTS employee_test;
CREATE TABLE employee_test (
    id serial PRIMARY KEY,
    name text,
    worktime tsmultirange
);

\i insert_values.sql
