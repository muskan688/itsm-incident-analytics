-- Open incidents at the end of each day: opened on or before the day, not yet closed.
-- "Open" here means not closed. The resolved-but-not-closed time is counted as open.

select
    d.date_day,
    count(i.incident_number)                                                  as open_incidents,
    count(i.incident_number) filter (where i.priority_code <= 2)              as open_high_priority
from {{ ref('dim_date') }} d
left join {{ ref('fact_incident') }} i
       on i.opened_date <= d.date_day
      and i.closed_at::date > d.date_day
group by d.date_day
