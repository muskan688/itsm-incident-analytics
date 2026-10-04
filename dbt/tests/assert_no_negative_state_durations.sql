{{ config(severity='warn') }}
-- Time in a state cannot be negative. This is a warning, not an error: a few events
-- in the real data are out of order. The test lists them so they stay visible.
select incident_number, event_seq, incident_state, updated_at, next_updated_at, hours_in_state
from {{ ref('fact_incident_event') }}
where hours_in_state < 0
