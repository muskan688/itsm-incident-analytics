select distinct category, subcategory
from {{ ref('fact_incident') }}
