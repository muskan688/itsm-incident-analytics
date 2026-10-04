-- Grain: one row per event. hours_in_state is the time until the next event,
-- so it is empty for the last event of an incident.

select
    incident_number,
    event_seq,
    incident_state,
    sys_updated_at                                                    as updated_at,
    next_state,
    next_updated_at,
    extract(epoch from (next_updated_at - sys_updated_at)) / 3600.0   as hours_in_state
from {{ ref('int_incident_events_ordered') }}
