{{ config(materialized='table') }}

select
    s.provider_ccn,
    s.year,
    v.age_group,
    v.bene_count
from {{ ref('stg_cms__inpatient_provider') }} s
cross join lateral (
    values
        ('LT_65', coalesce(s.bene_age_lt_65_count, 0)),
        ('65_74', coalesce(s.bene_age_65_74_count, 0)),
        ('75_84', coalesce(s.bene_age_75_84_count, 0)),
        ('GT_84', coalesce(s.bene_age_gt_84_count, 0))
) as v(age_group, bene_count)