-- depends_on: {{ var('pharmacy_claim') }}

{% set condition_filter = 'Opioid Use Disorder (OUD)' -%}

{%- set naltrexone_ndcs = (
    '00056001122', '00056001130', '00056001170', '00056007950', '00056008050',
    '00185003901', '00185003930', '00406009201', '00406009203', '00406117001',
    '00406117003', '00555090201', '00555090202', '00904703604', '16729008101',
    '16729008110', '42291063230', '43063059115', '47335032683', '47335032688',
    '50090286600', '50436010501', '51224020630', '51224020650', '51285027501',
    '51285027502', '52152010502', '52152010504', '52152010530', '54868557400',
    '63459030042', '63629104601', '63629104701', '65694010003', '65694010010',
    '65757030001', '65757030202', '68084029111', '68084029121', '68094085362',
    '68115068030'
    )
-%}

with chronic_conditions as (

    select * from {{ ref('cms_chronic_conditions__cms_chronic_conditions_hierarchy') }}
    where condition = '{{ condition_filter }}'

),

encounters as (

    select
          person_id
        , encounter_id
        , encounter_start_date
        , data_source
    from {{ var('encounter') }}

),

patient_conditions as (

    select
          encounter.person_id
        , encounter.encounter_id
        , encounter.encounter_start_date
        , encounter.data_source
        , replace(condition.normalized_code, '.', '') as condition_code
        , condition.code_system as condition_code_type
    from encounters as encounter
    inner join {{ var('condition') }} as condition
        on encounter.encounter_id = condition.encounter_id
        and encounter.data_source = condition.data_source

),

patient_procedures as (

    select
          encounter.person_id
        , encounter.encounter_id
        , encounter.encounter_start_date
        , encounter.data_source
        , replace(procedure_records.normalized_code, '.', '') as procedure_code
        , procedure_records.code_system as procedure_code_type
    from encounters as encounter
    inner join {{ var('procedure') }} as procedure_records
        on encounter.encounter_id = procedure_records.encounter_id
        and encounter.data_source = procedure_records.data_source

),

patient_medications as (

    select
          cast(null as {{ dbt.type_string() }}) as encounter_id
        , person_id
        , cast(paid_date as date) as encounter_start_date
        , replace(ndc_code, '.', '') as ndc_code
        , data_source
    from {{ var('pharmacy_claim') }}

),

inclusions_diagnosis as (

    select
          patient_conditions.person_id
        , patient_conditions.encounter_id
        , patient_conditions.encounter_start_date
        , patient_conditions.data_source
        , chronic_conditions.chronic_condition_type
        , chronic_conditions.condition_category
        , chronic_conditions.condition
    from patient_conditions
    inner join chronic_conditions
        on patient_conditions.condition_code = chronic_conditions.code
        and lower(patient_conditions.condition_code_type) =
            lower(chronic_conditions.code_system)
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) = 'icd-10-cm'

),

inclusions_procedure as (

    select
          patient_procedures.person_id
        , patient_procedures.encounter_id
        , patient_procedures.encounter_start_date
        , patient_procedures.data_source
        , chronic_conditions.chronic_condition_type
        , chronic_conditions.condition_category
        , chronic_conditions.condition
    from patient_procedures
    inner join chronic_conditions
        on patient_procedures.procedure_code = chronic_conditions.code
        and lower(patient_procedures.procedure_code_type) =
            lower(chronic_conditions.code_system)
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) in ('icd-10-pcs', 'hcpcs')

),

exclusions_other_chronic_conditions as (

    select distinct
          person_id
        , data_source
    from {{ ref('cms_chronic_conditions__stg_cms_chronic_condition_all') }}
    where condition in (
          'Alcohol Use Disorders'
        , 'Drug Use Disorders'
    )

),

excluded_naltrexone_patients as (

    select distinct
          patient_medications.person_id
        , patient_medications.data_source
    from patient_medications
    inner join chronic_conditions
        on patient_medications.ndc_code = chronic_conditions.code
    inner join exclusions_other_chronic_conditions
        on patient_medications.person_id = exclusions_other_chronic_conditions.person_id
        and patient_medications.data_source = exclusions_other_chronic_conditions.data_source
    left join inclusions_diagnosis
        on patient_medications.person_id = inclusions_diagnosis.person_id
        and patient_medications.data_source = inclusions_diagnosis.data_source
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) = 'ndc'
      and chronic_conditions.code in {{ naltrexone_ndcs }}
      and inclusions_diagnosis.person_id is null

),

/*
    Naltrexone qualifies unless alcohol or other drug-use evidence in the same
    source makes it ambiguous and there is no opioid-use diagnosis. Apply the
    exclusion only to the Naltrexone row; other qualifying OUD evidence remains.
*/
inclusions_medication as (

    select
          patient_medications.person_id
        , patient_medications.encounter_id
        , patient_medications.encounter_start_date
        , patient_medications.data_source
        , chronic_conditions.chronic_condition_type
        , chronic_conditions.condition_category
        , chronic_conditions.condition
    from patient_medications
    inner join chronic_conditions
        on patient_medications.ndc_code = chronic_conditions.code
    left join excluded_naltrexone_patients
        on patient_medications.person_id = excluded_naltrexone_patients.person_id
        and patient_medications.data_source = excluded_naltrexone_patients.data_source
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) = 'ndc'
      and (
        chronic_conditions.code not in {{ naltrexone_ndcs }}
        or excluded_naltrexone_patients.person_id is null
      )

),

inclusions_unioned as (

    select * from inclusions_diagnosis
    {% if target.type == 'fabric' %}
    union
    {% else %}
    union distinct
    {% endif %}
    select * from inclusions_procedure
    {% if target.type == 'fabric' %}
    union
    {% else %}
    union distinct
    {% endif %}
    select * from inclusions_medication

)

select distinct
      cast(inclusions_unioned.person_id as {{ dbt.type_string() }}) as person_id
    , cast(inclusions_unioned.encounter_id as {{ dbt.type_string() }}) as encounter_id
    , cast(inclusions_unioned.encounter_start_date as date)
      as encounter_start_date
    , cast(inclusions_unioned.chronic_condition_type as {{ dbt.type_string() }})
      as chronic_condition_type
    , cast(inclusions_unioned.condition_category as {{ dbt.type_string() }})
      as condition_category
    , cast(inclusions_unioned.condition as {{ dbt.type_string() }}) as condition
    , cast(inclusions_unioned.data_source as {{ dbt.type_string() }}) as data_source
from inclusions_unioned
