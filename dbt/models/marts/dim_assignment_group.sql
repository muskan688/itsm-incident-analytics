select distinct assignment_group
from {{ ref('fact_incident') }}
