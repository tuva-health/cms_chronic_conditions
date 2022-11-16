{{ config(enabled = var('chronic_conditions_enabled',var('tuva_packages_enabled',True)) ) }}

with chronic_conditions as (

    select distinct
          condition
        , condition_column_name
    from {{ ref('terminology__chronic_conditions') }}

),

conditions as (

    select
          chronic_conditions_unioned.patient_id
        , chronic_conditions.condition_column_name
        , 1 as condition_count
    from {{ ref('chronic_conditions__chronic_conditions_unioned') }} as chronic_conditions_unioned
         inner join chronic_conditions as chronic_conditions
             on chronic_conditions_unioned.condition =
                chronic_conditions.condition

)

select
      patient_id
    , case
        when acute_myocardial_infarction >= 1 then 1
        else 0
      end as acute_myocardial_infarction
    , case
        when adhd_conduct_disorders_and_hyperkinetic_syndrome >= 1 then 1
        else 0
      end as adhd_conduct_disorders_and_hyperkinetic_syndrome
    , case
        when alcohol_use_disorders >= 1 then 1
        else 0
      end as alcohol_use_disorders
    , case
        when alzheimers_disease >= 1 then 1
        else 0
      end as alzheimers_disease
    , case
        when anemia >= 1 then 1
        else 0
      end as anemia
    , case
        when anxiety_disorders >= 1 then 1
        else 0
      end as anxiety_disorders
    , case
        when asthma >= 1 then 1
        else 0
      end as asthma
    , case
        when atrial_fibrillation_and_flutter >= 1 then 1
        else 0
      end as atrial_fibrillation_and_flutter
    , case
        when autism_spectrum_disorders >= 1 then 1
        else 0
      end as autism_spectrum_disorders
    , case
        when benign_prostatic_hyperplasia >= 1 then 1
        else 0
      end as benign_prostatic_hyperplasia
    , case
        when bipolar_disorder >= 1 then 1
        else 0
      end as bipolar_disorder
    , case
        when cancer_breast >= 1 then 1
        else 0
      end as cancer_breast
    , case
        when cancer_colorectal >= 1 then 1
        else 0
      end as cancer_colorectal
    , case
        when cancer_endometrial >= 1 then 1
        else 0
      end as cancer_endometrial
    , case
        when cancer_lung >= 1 then 1
        else 0
      end as cancer_lung
    , case
        when cancer_prostate >= 1 then 1
        else 0
      end as cancer_prostate
    , case
        when cancer_urologic_kidney_renal_pelvis_and_ureter >= 1 then 1
        else 0
      end as cancer_urologic_kidney_renal_pelvis_and_ureter
    , case
        when cataract >= 1 then 1
        else 0
      end as cataract
    , case
        when cerebral_palsy >= 1 then 1
        else 0
      end as cerebral_palsy
    , case
        when chronic_kidney_disease >= 1 then 1
        else 0
      end as chronic_kidney_disease
    , case
        when chronic_obstructive_pulmonary_disease >= 1 then 1
        else 0
      end as chronic_obstructive_pulmonary_disease
    , case
        when cystic_fibrosis_and_other_metabolic_developmental_disorders >= 1
        then 1
        else 0
      end as cystic_fibrosis_and_other_metabolic_developmental_disorders
    , case
        when depression_bipolar_or_other_depressive_mood_disorders >= 1 then 1
        else 0
      end as depression_bipolar_or_other_depressive_mood_disorders
    , case
        when depressive_disorders >= 1 then 1
        else 0
      end as depressive_disorders
    , case
        when diabetes >= 1 then 1
        else 0
      end as diabetes
    , case
        when drug_use_disorders >= 1 then 1
        else 0
      end as drug_use_disorders
    , case
        when epilepsy >= 1 then 1
        else 0
      end as epilepsy
    , case
        when fibromyalgia_and_chronic_pain_and_fatigue >= 1 then 1
        else 0
      end as fibromyalgia_and_chronic_pain_and_fatigue
    , case
        when glaucoma >= 1 then 1
        else 0
      end as glaucoma
    , case
        when heart_failure_and_non_ischemic_heart_disease >= 1 then 1
        else 0
      end as heart_failure_and_non_ischemic_heart_disease
    , case
        when hepatitis_a >= 1 then 1
        else 0
      end as hepatitis_a
    , case
        when hepatitis_b_acute_or_unspecified >= 1 then 1
        else 0
      end as hepatitis_b_acute_or_unspecified
    , case
        when hepatitis_b_chronic >= 1 then 1
        else 0
      end as hepatitis_b_chronic
    , case
        when hepatitis_c_acute >= 1 then 1
        else 0
      end as hepatitis_c_acute
    , case
        when hepatitis_c_chronic >= 1 then 1
        else 0
      end as hepatitis_c_chronic
    , case
        when hepatitis_c_unspecified >= 1 then 1
        else 0
      end as hepatitis_c_unspecified
    , case
        when hepatitis_d >= 1 then 1
        else 0
      end as hepatitis_d
    , case
        when hepatitis_e >= 1 then 1
        else 0
      end as hepatitis_e
    , case
        when hip_pelvic_fracture >= 1 then 1
        else 0
      end as hip_pelvic_fracture
    , case
        when human_immunodeficiency_virus_and_or_acquired_immunodeficiency_syndrome_hiv_aids >= 1
        then 1
        else 0
      end as human_immunodeficiency_virus_and_or_acquired_immunodeficiency_syndrome_hiv_aids
    , case
        when hyperlipidemia >= 1 then 1
        else 0
      end as hyperlipidemia
    , case
        when hypertension >= 1 then 1
        else 0
      end as hypertension
    , case
        when hypothyroidism >= 1 then 1
        else 0
      end as hypothyroidism
    , case
        when intellectual_disabilities_and_related_conditions >= 1 then 1
        else 0
      end as intellectual_disabilities_and_related_conditions
    , case
        when ischemic_heart_disease >= 1 then 1
        else 0
      end as ischemic_heart_disease
    , case
        when learning_disabilities >= 1 then 1
        else 0
      end as learning_disabilities
    , case
        when leukemias_and_lymphomas >= 1 then 1
        else 0
      end as leukemias_and_lymphomas
    , case
        when liver_disease_cirrhosis_and_other_liver_conditions_except_viral_hepatitis >= 1
        then 1
        else 0
      end as liver_disease_cirrhosis_and_other_liver_conditions_except_viral_hepatitis
    , case
        when migraine_and_chronic_headache >= 1 then 1
        else 0
      end as migraine_and_chronic_headache
    , case
        when mobility_impairments >= 1 then 1
        else 0
      end as mobility_impairments
    , case
        when multiple_sclerosis_and_transverse_myelitis >= 1 then 1
        else 0
      end as multiple_sclerosis_and_transverse_myelitis
    , case
        when muscular_dystrophy >= 1 then 1
        else 0
      end as muscular_dystrophy
    , case
        when non_alzheimers_dementia >= 1 then 1
        else 0
      end as non_alzheimers_dementia
    , case
        when obesity >= 1 then 1
        else 0
      end as obesity
    , case
        when opioid_use_disorder_oud >= 1 then 1
        else 0
      end as opioid_use_disorder_oud
    , case
        when osteoporosis_with_or_without_pathological_fracture >= 1 then 1
        else 0
      end as osteoporosis_with_or_without_pathological_fracture
    , case
        when other_developmental_delays >= 1 then 1
        else 0
      end as other_developmental_delays
    , case
        when parkinsons_disease_and_secondary_parkinsonism >= 1 then 1
        else 0
      end as parkinsons_disease_and_secondary_parkinsonism
    , case
        when peripheral_vascular_disease_pvd >= 1 then 1
        else 0
      end as peripheral_vascular_disease_pvd
    , case
        when personality_disorders >= 1 then 1
        else 0
      end as personality_disorders
    , case
        when pneumonia_all_cause >= 1 then 1
        else 0
      end as pneumonia_all_cause
    , case
        when post_traumatic_stress_disorder_ptsd >= 1 then 1
        else 0
      end as post_traumatic_stress_disorder_ptsd
    , case
        when pressure_and_chronic_ulcers >= 1 then 1
        else 0
      end as pressure_and_chronic_ulcers
    , case
        when rheumatoid_arthritis_osteoarthritis >= 1 then 1
        else 0
      end as rheumatoid_arthritis_osteoarthritis
    , case
        when schizophrenia >= 1 then 1
        else 0
      end as schizophrenia
    , case
        when schizophrenia_and_other_psychotic_disorders >= 1 then 1
        else 0
      end as schizophrenia_and_other_psychotic_disorders
    , case
        when sensory_blindness_and_visual_impairment >= 1 then 1
        else 0
      end as sensory_blindness_and_visual_impairment
    , case
        when sensory_deafness_and_hearing_impairment >= 1 then 1
        else 0
      end as sensory_deafness_and_hearing_impairment
    , case
        when sickle_cell_disease >= 1 then 1
        else 0
      end as sickle_cell_disease
    , case
        when spina_bifida_and_other_congenital_anomalies_of_the_nervous_system >= 1
        then 1
        else 0
      end as spina_bifida_and_other_congenital_anomalies_of_the_nervous_system
    , case
        when spinal_cord_injury >= 1 then 1
        else 0
      end as spinal_cord_injury
    , case
        when stroke_transient_ischemic_attack >= 1 then 1
        else 0
      end as stroke_transient_ischemic_attack
    , case
        when tobacco_use >= 1 then 1
        else 0
      end as tobacco_use
    , case
        when traumatic_brain_injury_and_nonpsychotic_mental_disorders_due_to_brain_damage >= 1
        then 1
        else 0
      end as traumatic_brain_injury_and_nonpsychotic_mental_disorders_due_to_brain_damage
    , case
        when viral_hepatitis_general >= 1 then 1
        else 0
      end as viral_hepatitis_general
from conditions
pivot (
    sum(condition_count)
    for condition_column_name in (
          'acute_myocardial_infarction'
        , 'adhd_conduct_disorders_and_hyperkinetic_syndrome'
        , 'alcohol_use_disorders'
        , 'alzheimers_disease'
        , 'anemia'
        , 'anxiety_disorders'
        , 'asthma'
        , 'atrial_fibrillation_and_flutter'
        , 'autism_spectrum_disorders'
        , 'benign_prostatic_hyperplasia'
        , 'bipolar_disorder'
        , 'cancer_breast'
        , 'cancer_colorectal'
        , 'cancer_endometrial'
        , 'cancer_lung'
        , 'cancer_prostate'
        , 'cancer_urologic_kidney_renal_pelvis_and_ureter'
        , 'cataract'
        , 'cerebral_palsy'
        , 'chronic_kidney_disease'
        , 'chronic_obstructive_pulmonary_disease'
        , 'cystic_fibrosis_and_other_metabolic_developmental_disorders'
        , 'depression_bipolar_or_other_depressive_mood_disorders'
        , 'depressive_disorders'
        , 'diabetes'
        , 'drug_use_disorders'
        , 'epilepsy'
        , 'fibromyalgia_and_chronic_pain_and_fatigue'
        , 'glaucoma'
        , 'heart_failure_and_non_ischemic_heart_disease'
        , 'hepatitis_a'
        , 'hepatitis_b_acute_or_unspecified'
        , 'hepatitis_b_chronic'
        , 'hepatitis_c_acute'
        , 'hepatitis_c_chronic'
        , 'hepatitis_c_unspecified'
        , 'hepatitis_d'
        , 'hepatitis_e'
        , 'hip_pelvic_fracture'
        , 'human_immunodeficiency_virus_and_or_acquired_immunodeficiency_syndrome_hiv_aids'
        , 'hyperlipidemia'
        , 'hypertension'
        , 'hypothyroidism'
        , 'intellectual_disabilities_and_related_conditions'
        , 'ischemic_heart_disease'
        , 'learning_disabilities'
        , 'leukemias_and_lymphomas'
        , 'liver_disease_cirrhosis_and_other_liver_conditions_except_viral_hepatitis'
        , 'migraine_and_chronic_headache'
        , 'mobility_impairments'
        , 'multiple_sclerosis_and_transverse_myelitis'
        , 'muscular_dystrophy'
        , 'non_alzheimers_dementia'
        , 'obesity'
        , 'opioid_use_disorder_oud'
        , 'osteoporosis_with_or_without_pathological_fracture'
        , 'other_developmental_delays'
        , 'parkinsons_disease_and_secondary_parkinsonism'
        , 'peripheral_vascular_disease_pvd'
        , 'personality_disorders'
        , 'pneumonia_all_cause'
        , 'post_traumatic_stress_disorder_ptsd'
        , 'pressure_and_chronic_ulcers'
        , 'rheumatoid_arthritis_osteoarthritis'
        , 'schizophrenia'
        , 'schizophrenia_and_other_psychotic_disorders'
        , 'sensory_blindness_and_visual_impairment'
        , 'sensory_deafness_and_hearing_impairment'
        , 'sickle_cell_disease'
        , 'spina_bifida_and_other_congenital_anomalies_of_the_nervous_system'
        , 'spinal_cord_injury'
        , 'stroke_transient_ischemic_attack'
        , 'tobacco_use'
        , 'traumatic_brain_injury_and_nonpsychotic_mental_disorders_due_to_brain_damage'
        , 'viral_hepatitis_general'
        )
)
as pvt (
      patient_id
    , acute_myocardial_infarction
    , adhd_conduct_disorders_and_hyperkinetic_syndrome
    , alcohol_use_disorders
    , alzheimers_disease
    , anemia
    , anxiety_disorders
    , asthma
    , atrial_fibrillation_and_flutter
    , autism_spectrum_disorders
    , benign_prostatic_hyperplasia
    , bipolar_disorder
    , cancer_breast
    , cancer_colorectal
    , cancer_endometrial
    , cancer_lung
    , cancer_prostate
    , cancer_urologic_kidney_renal_pelvis_and_ureter
    , cataract
    , cerebral_palsy
    , chronic_kidney_disease
    , chronic_obstructive_pulmonary_disease
    , cystic_fibrosis_and_other_metabolic_developmental_disorders
    , depression_bipolar_or_other_depressive_mood_disorders
    , depressive_disorders
    , diabetes
    , drug_use_disorders
    , epilepsy
    , fibromyalgia_and_chronic_pain_and_fatigue
    , glaucoma
    , heart_failure_and_non_ischemic_heart_disease
    , hepatitis_a
    , hepatitis_b_acute_or_unspecified
    , hepatitis_b_chronic
    , hepatitis_c_acute
    , hepatitis_c_chronic
    , hepatitis_c_unspecified
    , hepatitis_d
    , hepatitis_e
    , hip_pelvic_fracture
    , human_immunodeficiency_virus_and_or_acquired_immunodeficiency_syndrome_hiv_aids
    , hyperlipidemia
    , hypertension
    , hypothyroidism
    , intellectual_disabilities_and_related_conditions
    , ischemic_heart_disease
    , learning_disabilities
    , leukemias_and_lymphomas
    , liver_disease_cirrhosis_and_other_liver_conditions_except_viral_hepatitis
    , migraine_and_chronic_headache
    , mobility_impairments
    , multiple_sclerosis_and_transverse_myelitis
    , muscular_dystrophy
    , non_alzheimers_dementia
    , obesity
    , opioid_use_disorder_oud
    , osteoporosis_with_or_without_pathological_fracture
    , other_developmental_delays
    , parkinsons_disease_and_secondary_parkinsonism
    , peripheral_vascular_disease_pvd
    , personality_disorders
    , pneumonia_all_cause
    , post_traumatic_stress_disorder_ptsd
    , pressure_and_chronic_ulcers
    , rheumatoid_arthritis_osteoarthritis
    , schizophrenia
    , schizophrenia_and_other_psychotic_disorders
    , sensory_blindness_and_visual_impairment
    , sensory_deafness_and_hearing_impairment
    , sickle_cell_disease
    , spina_bifida_and_other_congenital_anomalies_of_the_nervous_system
    , spinal_cord_injury
    , stroke_transient_ischemic_attack
    , tobacco_use
    , traumatic_brain_injury_and_nonpsychotic_mental_disorders_due_to_brain_damage
    , viral_hepatitis_general
)