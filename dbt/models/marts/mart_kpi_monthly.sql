-- Monthly view by the month an incident was opened.
-- Resolution time only counts incidents that were resolved (1,556 were closed without resolution).

select
    date_trunc('month', opened_at)::date                                           as month_start,
    to_char(opened_at, 'YYYY-MM')                                                  as year_month,
    count(*)                                                                       as incidents,
    count(*) filter (where is_resolved)                                            as resolved_incidents,
    round(avg(resolution_hours)::numeric, 1)                                       as avg_resolution_hours,
    round((percentile_cont(0.5) within group (order by resolution_hours))::numeric, 1)
                                                                                   as median_resolution_hours,
    round(100.0 * avg(made_sla::int), 1)                                           as sla_met_pct,
    round(100.0 * avg(was_reopened::int), 1)                                       as reopened_pct,
    round(avg(reassignment_count)::numeric, 2)                                     as avg_reassignments
from {{ ref('fact_incident') }}
group by 1, 2
