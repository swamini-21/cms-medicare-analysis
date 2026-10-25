{{ config(materialized='table') }}

select
    s.provider_ccn,
    s.year,
    v.gender,
    v.bene_count
from {{ ref('stg_cms__inpatient_provider') }} s
cross join lateral (
    values
        ('Female', coalesce(s.bene_female_count, 0)),
        ('Male', coalesce(s.bene_male_count, 0))
) as v(gender, bene_count)