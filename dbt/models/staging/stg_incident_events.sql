-- One row per incident event, with real types and clean missing values.
--   - '?' becomes NULL, dates become timestamps, 'true'/'false' become booleans
--   - the state '-100' (5 rows) is not a valid ServiceNow state: renamed to 'Unknown' and flagged
--   - columns that are almost always empty are left out (caused_by 100%, vendor 99.8%,
--     cmdb_ci 99.7%, rfc 99.3%, problem_id 98.4% missing)

select
    row_id                                            as event_id,
    trim(number)                                      as incident_number,

    case when trim(incident_state) = '-100' then 'Unknown'
         else trim(incident_state) end                as incident_state,
    (trim(incident_state) = '-100')                   as is_unknown_state,
    (active = 'true')                                 as is_active,

    reassignment_count::int                           as reassignment_count,
    reopen_count::int                                 as reopen_count,
    sys_mod_count::int                                as sys_mod_count,
    (made_sla = 'true')                               as made_sla,

    {{ clean_text('caller_id') }}                     as caller_id,
    {{ clean_text('opened_by') }}                     as opened_by,
    {{ parse_ts('opened_at') }}                       as opened_at,
    {{ parse_ts('sys_created_at') }}                  as sys_created_at,
    {{ parse_ts('sys_updated_at') }}                  as sys_updated_at,
    {{ clean_text('sys_updated_by') }}                as sys_updated_by,

    {{ clean_text('contact_type') }}                  as contact_type,
    {{ clean_text('location') }}                      as location,
    {{ clean_text('category') }}                      as category,
    {{ clean_text('subcategory') }}                   as subcategory,
    {{ clean_text('u_symptom') }}                     as symptom,

    {{ clean_text('impact') }}                        as impact,
    {{ clean_text('urgency') }}                       as urgency,
    {{ clean_text('priority') }}                      as priority,
    substring(trim(priority) from 1 for 1)::int       as priority_code,

    {{ clean_text('assignment_group') }}              as assignment_group,
    {{ clean_text('assigned_to') }}                   as assigned_to,
    {{ clean_text('closed_code') }}                   as close_code,
    {{ clean_text('resolved_by') }}                   as resolved_by,
    {{ parse_ts('resolved_at') }}                     as resolved_at,
    {{ parse_ts('closed_at') }}                       as closed_at

from {{ source('raw', 'incident_events') }}
