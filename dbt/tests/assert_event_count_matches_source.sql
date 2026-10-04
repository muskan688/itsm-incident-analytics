-- No event may be lost or duplicated on the way to fact_incident_event.
select *
from (
    select
        (select count(*) from {{ ref('stg_incident_events') }})  as source_events,
        (select count(*) from {{ ref('fact_incident_event') }})  as fact_events
) t
where source_events <> fact_events
