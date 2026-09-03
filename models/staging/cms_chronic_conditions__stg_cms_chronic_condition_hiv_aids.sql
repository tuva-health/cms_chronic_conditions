{%- set condition_filter = 'Human Immunodeficiency Virus and/or Acquired Immunodeficiency Syndrome (HIV/AIDS)' -%}

with chronic_conditions as (

    select * from {{ ref('cms_chronic_conditions__cms_chronic_conditions_hierarchy') }}
    where condition = '{{ condition_filter }}'

),

encounters as (

    select
          person_id
        , encounter_id
        , encounter_start_date
        , drg_code
        , drg_code_type
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

/*
    Exception logic: a claim with the diagnosis code R75 requires a second
    qualifying claim that is not R75 (a screening code).
*/
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
      and chronic_conditions.code <> 'R75'

),

inclusions_ms_drg as (

    select
          encounters.person_id
        , encounters.encounter_id
        , encounters.encounter_start_date
        , encounters.data_source
        , chronic_conditions.chronic_condition_type
        , chronic_conditions.condition_category
        , chronic_conditions.condition
    from encounters
    inner join chronic_conditions
        on encounters.drg_code = chronic_conditions.code
        and lower(encounters.drg_code_type) = lower(chronic_conditions.code_system)
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) = 'ms-drg'

),

/*
    Include R75 only when another encounter in the same data source has a
    qualifying non-R75 HIV diagnosis.
*/
exception_diagnosis as (

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
    inner join inclusions_diagnosis
        on patient_conditions.person_id = inclusions_diagnosis.person_id
        and patient_conditions.data_source = inclusions_diagnosis.data_source
        and patient_conditions.encounter_id <> inclusions_diagnosis.encounter_id
    where chronic_conditions.inclusion_type = 'Include'
      and lower(chronic_conditions.code_system) = 'icd-10-cm'
      and chronic_conditions.code = 'R75'

),

inclusions_unioned as (

    select * from inclusions_diagnosis
    {% if target.type in ['fabric', 'sqlserver'] %}
    union
    {% else %}
    union distinct
    {% endif %}
    select * from inclusions_ms_drg
    {% if target.type in ['fabric', 'sqlserver'] %}
    union
    {% else %}
    union distinct
    {% endif %}
    select * from exception_diagnosis

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
