-- Puts the events of each incident in order and looks at the next event.
-- Order: sys_mod_count (ServiceNow's change counter), then update time, then file order.

select
    *,
    row_number() over w                               as event_seq,
    count(*) over (partition by incident_number)      as event_count,
    lead(incident_state) over w                       as next_state,
    lead(sys_updated_at) over w                       as next_updated_at
from {{ ref('stg_incident_events') }}
window w as (partition by incident_number order by sys_mod_count, sys_updated_at, event_id)
