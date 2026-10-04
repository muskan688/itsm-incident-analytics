-- Every incident in the log is closed, so after the last day nothing may be open.
select *
from {{ ref('mart_backlog_daily') }}
where date_day = (select max(date_day) from {{ ref('mart_backlog_daily') }})
  and open_incidents <> 0
