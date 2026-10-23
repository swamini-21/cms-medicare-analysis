{{ config(materialized='table') }}

with staging as (

    select * from {{ ref('stg_cms__inpatient_provider') }}

),

with_counts as (

    select
        *,
        coalesce(bene_race_black_count, 0)
          + coalesce(bene_race_api_count, 0)
          + coalesce(bene_race_hispanic_count, 0)
          + coalesce(bene_race_native_american_count, 0) as minority_count
    from staging

),

final as (

    select
        provider_ccn,
        year,
        hospital_name,
        provider_state,
        ruca_code,
        total_benes,
        total_discharges,
        total_medicare_payment_amount,
        bene_avg_risk_score,
        minority_count,
        round(minority_count::numeric / nullif(total_benes, 0), 2) as minority_share,
        round(coalesce(dual_bene_count, 0)::numeric / nullif(total_benes, 0), 2) as dual_share,
        round(total_medicare_payment_amount / nullif(total_benes, 0), 0) as payment_per_bene
    from with_counts

)

select * from final