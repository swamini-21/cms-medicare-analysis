DROP TABLE IF EXISTS cms_raw;

CREATE TABLE cms_raw ( "Provider CCN" int,
"Organization Name" text, "Provider City" text,
"Zipcode" int, "State" text, "Total Beneficiaries" int, 
"Total Submitted Covered Charge" numeric,
"Total Payment Amount" numeric, 
"Total Medicare Payment Amount" numeric, "Total Discharges" int,
"Total Covered Days" int, "Total Days" int,
"Beneficiary Average Age" numeric, "Beneficiary Age LT 65" int,
"Beneficiary Age 65-74" int, "Beneficiary Age 75-84" int,
"Beneficiary Age GT 84" int, "Female Beneficiaries" int,
"Male Beneficiaries" int, "Whites" int, "Blacks" int, 
"Asian Pacific Islanders" int, "Hispanics" int, 
"Americans" int, "Other race" int, 
"Dual Beneficiary" int, "Medicare Beneficiary" int,
"ADHD Beneficary%" numeric, "Alchoho/Drug Beneficiary%" numeric,
"Tobacco Beneficiary%" numeric, "Alzheimer/Dementia Beneficiary%" numeric,
"Anxiety Beneficiary%" numeric, "Bipolar Beneficiary%" numeric,
"Depressive Mood Beneficiary%" numeric, 
"Depressive Affective Disorder Beneficiary%" numeric,
"Personality Disorder Beneficairy%" numeric, 
"Post-Traumatic Disorder Beneficiary%" numeric, 
"Psychotic Disorder Beneficiary%" numeric, 
"Asthma Beneficiary%" numeric, "Atrial Flutter Beneficiary%" numeric,
"Cancer Indicators Beneficiary%" numeric, 
"Chronic Kidney Disease Beneficiary%" numeric, 
"Chronic Obstructive Pulmonary Disease Beneficiary%" numeric,
"Diabetes Beneficiary%" numeric, 
"Non-Ischemic Heart Disease Beneficiary%" numeric,
"Hyperlipidemia Beneficiary%" numeric, "Hypertension Beneficiary%" numeric,
"Ischemic Heart Disease Beneficiary%" numeric, 
"Osteoporosis Beneficiary%" numeric, "Parkinson Beneficiary%" numeric,
"Osteoarthritis Beneficiary%" numeric, "Stroke Beneficiary%" numeric,
"Avg HCC Risk Score%" numeric
);

select count(*)
from cms_raw;

