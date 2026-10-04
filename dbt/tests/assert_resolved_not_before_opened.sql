-- An incident cannot be resolved or closed before it was opened.
select incident_number, opened_at, resolved_at, closed_at
from {{ ref('fact_incident') }}
where resolved_at < opened_at
   or closed_at < opened_at
   or closed_at < resolved_at
