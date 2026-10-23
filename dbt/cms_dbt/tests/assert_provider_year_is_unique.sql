select
    provider_ccn,
    year,
    count(*) as row_count
from {{ ref('stg_cms__inpatient_provider') }}
group by provider_ccn, year
having count(*) > 1