{{ config(materialized='table') }}

{% set physical_cols = [
    'ph_asthma_pct', 'ph_afib_pct', 'ph_cancer_pct', 'ph_ckd_pct', 'ph_copd_pct',
    'ph_diabetes_pct', 'ph_heart_failure_pct', 'ph_hyperlipidemia_pct',
    'ph_hypertension_pct', 'ph_ischemic_heart_pct', 'ph_osteoporosis_pct',
    'ph_parkinson_pct', 'ph_arthritis_pct', 'ph_stroke_tia_pct'
] %}
{% set behavioral_cols = [
    'bh_adhd_pct', 'bh_alcohol_drug_pct', 'bh_tobacco_pct', 'bh_alzheimers_dementia_pct',
    'bh_anxiety_pct', 'bh_bipolar_pct', 'bh_mood_pct', 'bh_depression_pct',
    'bh_personality_pct', 'bh_ptsd_pct', 'bh_schizophrenia_pct'
] %}

with staging as (

    select * from {{ ref('stg_cms__inpatient_provider') }}

),

with_counts as (

    select
        *,
        coalesce(bene_race_black_count, 0)
          + coalesce(bene_race_api_count, 0)
          + coalesce(bene_race_hispanic_count, 0)
          + coalesce(bene_race_native_american_count, 0) as minority_count,
        round(
            {% for c in physical_cols -%}
            coalesce({{ c }}, 0){% if not loop.last %} + {% endif %}
            {%- endfor %}, 2
        ) as comorbidity_index,
        round(
            {% for c in behavioral_cols -%}
            coalesce({{ c }}, 0){% if not loop.last %} + {% endif %}
            {%- endfor %}, 2
        ) as behavioral_burden_index
    from staging

),

base as (

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
        comorbidity_index,
        behavioral_burden_index,
        round(minority_count::numeric / nullif(total_benes, 0), 2) as minority_share,
        round(coalesce(dual_bene_count, 0)::numeric / nullif(total_benes, 0), 2) as dual_share,
        round(total_medicare_payment_amount / nullif(total_benes, 0), 0) as payment_per_bene
    from with_counts

),

dual_cutoff as (

    select percentile_cont(0.5) within group (order by dual_share) as dual_median
    from base

),

comorbidity_cutoffs as (

    select
        year,
        percentile_cont(0.33) within group (order by comorbidity_index) as p33,
        percentile_cont(0.66) within group (order by comorbidity_index) as p66
    from base
    group by year

),

regression as (

    select
        regr_slope(payment_per_bene, bene_avg_risk_score)     as slope,
        regr_intercept(payment_per_bene, bene_avg_risk_score) as intercept
    from base

),

scored as (

    select
        b.*,
        case when b.dual_share >= d.dual_median then 'High Dual' else 'Low Dual' end as dual_tier,
        case
            when b.comorbidity_index <= c.p33 then 'Low'
            when b.comorbidity_index <= c.p66 then 'Medium'
            else 'High'
        end as comorbidity_tier,
        round((r.intercept + r.slope * b.bene_avg_risk_score)::numeric, 2) as predicted_payment
    from base b
    cross join dual_cutoff d
    join comorbidity_cutoffs c on b.year = c.year
    cross join regression r

)

select
    *,
    round(payment_per_bene - predicted_payment, 2) as residual,
    case when payment_per_bene - predicted_payment > 0 then 'Overpaid' else 'Underpaid' end as residual_label
from scored