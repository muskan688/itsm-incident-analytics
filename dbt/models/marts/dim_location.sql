select distinct location
from {{ ref('fact_incident') }}
