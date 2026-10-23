{{ config(materialized='table') }}

with staging as (

    select * from {{ ref('stg_cms__inpatient_provider') }}

),

ranked as (

    select
        *,
        row_number() over (partition by provider_ccn order by year desc) as rn
    from staging

)

select
    provider_ccn,
    hospital_name,
    provider_city,
    provider_state,
    provider_zip,
    ruca_code,
    year as latest_year
from ranked
where rn = 1