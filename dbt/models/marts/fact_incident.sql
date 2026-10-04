-- Grain: one row per incident. Values come from the LAST event of the incident
-- (the final state of the ticket). Hours are calculated from timestamps.

select
    incident_number,
    opened_at,
    opened_at::date                                                   as opened_date,
    resolved_at,
    closed_at,
    (resolved_at is not null)                                         as is_resolved,
    extract(epoch from (resolved_at - opened_at)) / 3600.0            as resolution_hours,
    extract(epoch from (closed_at - opened_at)) / 3600.0              as closure_hours,

    priority,
    priority_code,
    impact,
    urgency,
    coalesce(category, 'Unknown')                                     as category,
    coalesce(subcategory, 'Unknown')                                  as subcategory,
    coalesce(assignment_group, 'Unassigned')                          as assignment_group,
    coalesce(location, 'Unknown')                                     as location,
    coalesce(contact_type, 'Unknown')                                 as contact_type,

    reassignment_count,
    reopen_count,
    (reopen_count > 0)                                                as was_reopened,
    made_sla,
    event_count
from {{ ref('int_incident_events_ordered') }}
where event_seq = event_count
