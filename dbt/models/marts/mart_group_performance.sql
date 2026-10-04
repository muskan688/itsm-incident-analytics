-- One row per assignment group.

select
    assignment_group,
    count(*)                                                                  as incidents,
    round(100.0 * count(*) / sum(count(*)) over (), 2)                        as share_of_incidents_pct,
    round(100.0 * avg(made_sla::int), 1)                                      as sla_met_pct,
    round((percentile_cont(0.5) within group (order by resolution_hours))::numeric, 1)
                                                                              as median_resolution_hours,
    round(avg(reassignment_count)::numeric, 2)                                as avg_reassignments,
    round(100.0 * avg(was_reopened::int), 1)                                  as reopened_pct
from {{ ref('fact_incident') }}
group by assignment_group
