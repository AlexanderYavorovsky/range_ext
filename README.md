# range_ext
Range and multirange types extension for PostgreSQL

## Getting started
After cloning repo, copy extension files to your PostgreSQL extension directory:
```
sudo cp range_ext* $(pg_config --sharedir)/extension/
```

Or if you want to specify the PostgreSQL version manually:
```
sudo cp range_ext* /usr/share/postgresql/<version>/extension/
```

In psql, proceed with the classic approach:
```
CREATE EXTENSION range_ext;
```

## Provided features
This extension provides the following functions:
- range_len(range) -- get range length;

- distance(value, range) -- get the distance between a given value and a range;

- abs(value) -- get the absolute value of a given interval;

- nearest_range_to_value(value, multirange) -- get the nearest range from the multirange to the given value;

- make_shift_template(...) -- create a work shift template;

- get_payment_for_period(...) -- calculate the employee's payment for a given period of time.

## Usage examples
There are three scripts to provide the usage examples:
- test_data.sql -- to create test tables;
- insert_data.sql -- to insert rows into these tables;
- run_tests.sql -- to test functions provided by extension.

To run them all, just type in your database:
```
\i run_tests.sql
```