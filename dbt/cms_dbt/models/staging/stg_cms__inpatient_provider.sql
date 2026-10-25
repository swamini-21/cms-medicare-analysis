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
        nullif(bene_avg_risk_scre, '')::numeric   as bene_avg_risk_score, 
        nullif(bene_race_wht_cnt, '')::int        as bene_race_white_count,
        nullif(bene_race_black_cnt, '')::int      as bene_race_black_count,
        nullif(bene_race_api_cnt, '')::int        as bene_race_api_count,
        nullif(bene_race_hspnc_cnt, '')::int      as bene_race_hispanic_count,
        nullif(bene_race_natind_cnt, '')::int     as bene_race_native_american_count,
        nullif(bene_race_othr_cnt, '')::int       as bene_race_other_count,
        nullif(bene_age_lt_65_cnt, '')::int       as bene_age_lt_65_count,
        nullif(bene_age_65_74_cnt, '')::int       as bene_age_65_74_count,
        nullif(bene_age_75_84_cnt, '')::int       as bene_age_75_84_count,
        nullif(bene_age_gt_84_cnt, '')::int       as bene_age_gt_84_count,
        nullif(bene_feml_cnt, '')::int            as bene_female_count,
        nullif(bene_male_cnt, '')::int            as bene_male_count,
        nullif(bene_cc_ph_asthma_v2_pct, '')::numeric        as ph_asthma_pct,
        nullif(bene_cc_ph_afib_v2_pct, '')::numeric          as ph_afib_pct,
        nullif(bene_cc_ph_cancer6_v2_pct, '')::numeric       as ph_cancer_pct,
        nullif(bene_cc_ph_ckd_v2_pct, '')::numeric           as ph_ckd_pct,
        nullif(bene_cc_ph_copd_v2_pct, '')::numeric          as ph_copd_pct,
        nullif(bene_cc_ph_diabetes_v2_pct, '')::numeric      as ph_diabetes_pct,
        nullif(bene_cc_ph_hf_nonihd_v2_pct, '')::numeric     as ph_heart_failure_pct,
        nullif(bene_cc_ph_hyperlipidemia_v2_pct, '')::numeric as ph_hyperlipidemia_pct,
        nullif(bene_cc_ph_hypertension_v2_pct, '')::numeric  as ph_hypertension_pct,
        nullif(bene_cc_ph_ischemicheart_v2_pct, '')::numeric as ph_ischemic_heart_pct,
        nullif(bene_cc_ph_osteoporosis_v2_pct, '')::numeric  as ph_osteoporosis_pct,
        nullif(bene_cc_ph_parkinson_v2_pct, '')::numeric     as ph_parkinson_pct,
        nullif(bene_cc_ph_arthritis_v2_pct, '')::numeric     as ph_arthritis_pct,
        nullif(bene_cc_ph_stroke_tia_v2_pct, '')::numeric    as ph_stroke_tia_pct,
        nullif(bene_cc_bh_adhd_othcd_v1_pct, '')::numeric    as bh_adhd_pct,
        nullif(bene_cc_bh_alcohol_drug_v1_pct, '')::numeric  as bh_alcohol_drug_pct,
        nullif(bene_cc_bh_tobacco_v1_pct, '')::numeric       as bh_tobacco_pct,
        nullif(bene_cc_bh_alz_nonalzdem_v2_pct, '')::numeric as bh_alzheimers_dementia_pct,
        nullif(bene_cc_bh_anxiety_v1_pct, '')::numeric       as bh_anxiety_pct,
        nullif(bene_cc_bh_bipolar_v1_pct, '')::numeric       as bh_bipolar_pct,
        nullif(bene_cc_bh_mood_v2_pct, '')::numeric          as bh_mood_pct,
        nullif(bene_cc_bh_depress_v1_pct, '')::numeric       as bh_depression_pct,
        nullif(bene_cc_bh_pd_v1_pct, '')::numeric            as bh_personality_pct,
        nullif(bene_cc_bh_ptsd_v1_pct, '')::numeric          as bh_ptsd_pct,
        nullif(bene_cc_bh_schizo_othpsy_v1_pct, '')::numeric as bh_schizophrenia_pct

    from source

)

select * from renamed