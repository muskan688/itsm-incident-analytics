select
    d::date                                   as date_day,
    extract(year from d)::int                 as year,
    extract(month from d)::int                as month,
    date_trunc('month', d)::date              as month_start,
    to_char(d, 'YYYY-MM')                     as year_month,
    extract(isodow from d)::int               as iso_weekday,
    to_char(d, 'Dy')                          as weekday_name,
    (extract(isodow from d) >= 6)             as is_weekend
from generate_series(
    (select min(opened_date) from {{ ref('fact_incident') }}),
    (select max(closed_at)::date from {{ ref('fact_incident') }}),
    interval '1 day'
) as d
