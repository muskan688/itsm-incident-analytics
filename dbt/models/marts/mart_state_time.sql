-- Where does the time go? Time spent in each ticket state, from the event log.

with durations as (
    select incident_state, hours_in_state
    from {{ ref('fact_incident_event') }}
    where hours_in_state is not null
)
select
    incident_state,
    count(*)                                                                  as events,
    round(sum(hours_in_state)::numeric, 0)                                    as total_hours,
    round(avg(hours_in_state)::numeric, 1)                                    as avg_hours,
    round((percentile_cont(0.5) within group (order by hours_in_state))::numeric, 1)
                                                                              as median_hours,
    round((100.0 * sum(hours_in_state) / sum(sum(hours_in_state)) over ())::numeric, 1)
                                                                              as share_of_total_time_pct
from durations
group by incident_state
