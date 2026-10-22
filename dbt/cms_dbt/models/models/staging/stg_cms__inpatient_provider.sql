with source as (

    select * from {{ source('cms_raw', 'raw_inpatient_provider') }}

),

renamed as (

    select
        rndrng_prvdr_ccn                          as provider_ccn,
        year::int                                 as year,
        rndrng_prvdr_org_name                     as hospital_name,
        rndrng_prvdr_city                         as provider_city,
        rndrng_prvdr_state_abrvtn                 as provider_state,
        rndrng_prvdr_zip5                         as provider_zip,
        nullif(rndrng_prvdr_ruca, '')::numeric    as ruca_code,
        nullif(tot_benes, '')::int                as total_benes,
        nullif(tot_dschrgs, '')::int              as total_discharges,
        nullif(tot_submtd_cvrd_chrg, '')::numeric as total_submitted_covered_charges,
        nullif(tot_pymt_amt, '')::numeric         as total_payment_amount,
        nullif(tot_mdcr_pymt_amt, '')::numeric    as total_medicare_payment_amount,
        nullif(tot_cvrd_days, '')::int            as total_covered_days,
        nullif(tot_days, '')::int                 as total_days,
        nullif(bene_avg_age, '')::numeric         as bene_avg_age,
        nullif(bene_dual_cnt, '')::int            as dual_bene_count,
        nullif(bene_ndual_cnt, '')::int           as non_dual_bene_count,
        nullif(bene_avg_risk_scre, '')::numeric   as bene_avg_risk_score

    from source

)

select * from renamed