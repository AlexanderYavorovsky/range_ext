\echo Use "CREATE EXTENSION range_ext" to load this file. \quit


-- For int4range and int8range, "length" is the amount of integers within the range.
-- For instance: range_len([0, 1]) == 2
DROP FUNCTION IF EXISTS range_len(x anyrange);
CREATE FUNCTION range_len(x anyrange)
RETURNS anyelement AS $$
BEGIN
    IF isempty(x) THEN
        RETURN 0;
    END IF;
    RETURN upper(x) - lower(x);
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS range_len(x tsrange);
CREATE FUNCTION range_len(x tsrange)
RETURNS interval AS $$
BEGIN
    IF isempty(x) THEN
        RETURN '0 seconds';
    END IF;
    RETURN upper(x) - lower(x);
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS range_len(x tstzrange);
CREATE FUNCTION range_len(x tstzrange)
RETURNS interval AS $$
BEGIN
    IF isempty(x) THEN
        RETURN '0 seconds';
    END IF;
    RETURN upper(x) - lower(x);
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS range_len(x tsmultirange);
CREATE FUNCTION range_len(x tsmultirange)
RETURNS interval AS $$
DECLARE
    len interval := '0 seconds';
    rng tsrange;
BEGIN
    FOR rng IN SELECT unnest(x) LOOP
        len := len + range_len(rng);
    END LOOP;
    RETURN len;
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS distance(val integer, rng int4range);
CREATE FUNCTION distance(val integer, rng int4range)
RETURNS integer AS $$
BEGIN
    IF isempty(rng) THEN
        RETURN -1;
    ELSIF rng @> val THEN
        RETURN 0;
    END IF;
    RETURN least(abs(lower(rng) - val), abs(upper(rng) - val));
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS abs(x interval);
CREATE FUNCTION abs(x interval)
RETURNS interval AS $$
BEGIN
    IF x < '0'::interval THEN
        RETURN -x;
    END IF;
    RETURN x;
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS distance(val timestamp, rng tsrange);
CREATE FUNCTION distance(val timestamp, rng tsrange)
RETURNS interval AS $$
BEGIN
    IF isempty(rng) THEN
        RETURN -1;
    ELSIF rng @> val THEN
        RETURN 0;
    END IF;
    RETURN least(abs(lower(rng) - val), abs(upper(rng) - val));
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS nearest_range_to_value(val integer, mrange int4multirange);
CREATE FUNCTION nearest_range_to_value(val integer, mrange int4multirange)
RETURNS int4range AS $$
DECLARE
    min_dist integer = 2147483647; -- max integer value
    cur_dist integer;
    min_rng int4range;
    rng int4range;
BEGIN
    FOR rng IN SELECT unnest(mrange) LOOP
        cur_dist = distance(val, rng);
        IF cur_dist >= 0 AND cur_dist <= min_dist THEN
            min_dist = cur_dist;
            min_rng = rng;
        END IF;
    END LOOP;
    RETURN min_rng;
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS nearest_range_to_value(val timestamp, mrange tsmultirange);
CREATE FUNCTION nearest_range_to_value(val timestamp, mrange tsmultirange)
RETURNS tsrange AS $$
DECLARE
    min_dist interval = '178000000 years'; -- max interval value
    cur_dist interval;
    min_rng tsrange;
    rng tsrange;
BEGIN
    FOR rng IN SELECT unnest(mrange) LOOP
        cur_dist = distance(val, rng);
        IF cur_dist >= '0'::interval AND cur_dist <= min_dist THEN
            min_dist = cur_dist;
            min_rng = rng;
        END IF;
    END LOOP;
    RETURN min_rng;
END; $$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS make_shift_template;
CREATE FUNCTION make_shift_template(
    date_from date,
    date_to date,
    shift_start time,
    shift_end time,
    is_night_shift boolean)
RETURNS tsmultirange AS $$
DECLARE
    dt date;
    shift_template tsmultirange := '{}';
BEGIN
    FOR dt IN SELECT generate_series(date_from, date_to, '1 day'::interval) LOOP
        IF is_night_shift THEN
            shift_template = shift_template + tsmultirange(tsrange(dt + shift_start, dt + '1 day'::interval + shift_end));
        ELSE
            shift_template = shift_template + tsmultirange(tsrange(dt + shift_start, dt + shift_end));
        END IF;
    END LOOP;
    RETURN shift_template;
END; $$
LANGUAGE plpgsql;



DROP FUNCTION IF EXISTS get_payment_for_period;
CREATE FUNCTION get_payment_for_period(
    date_from date,
    date_to date,
    dayshift_start time,
    dayshift_end time,
    nightshift_start time,
    nightshift_end time,
    day_payment_per_hour numeric,
    night_payment_per_hour numeric,
    worktime tsmultirange)
RETURNS numeric AS $$
DECLARE
    dayshift_template tsmultirange = make_shift_template(date_from, date_to, dayshift_start, dayshift_end, false);
    nightshift_template tsmultirange = make_shift_template(date_from, date_to, nightshift_start, nightshift_end, true);
BEGIN
    RETURN (
        EXTRACT(epoch FROM range_len(worktime * dayshift_template))
            * day_payment_per_hour +
        EXTRACT(epoch FROM range_len(worktime * nightshift_template))
            * night_payment_per_hour
        ) / 3600;
END; $$
LANGUAGE plpgsql;
