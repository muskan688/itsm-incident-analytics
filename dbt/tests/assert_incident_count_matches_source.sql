-- Every incident in the source must appear exactly once in fact_incident.
select *
from (
    select
        (select count(distinct incident_number) from {{ ref('stg_incident_events') }}) as source_incidents,
        (select count(*) from {{ ref('fact_incident') }})                              as fact_incidents
) t
where source_incidents <> fact_incidents
