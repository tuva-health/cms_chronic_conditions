with conditions_unioned as (

    select *
    from {{ ref('cms_chronic_conditions__stg_cms_chronic_condition_all') }}

    {% if target.type in ['fabric', 'sqlserver'] %}
    union
    {% else %}
    union distinct
    {% endif %}

    select *
    from {{ ref('cms_chronic_conditions__stg_cms_chronic_condition_hiv_aids') }}

    {% if target.type in ['fabric', 'sqlserver'] %}
    union
    {% else %}
    union distinct
    {% endif %}

    select *
    from {{ ref('cms_chronic_conditions__stg_cms_chronic_condition_oud') }}

)

select
      person_id
    , encounter_id
    , encounter_start_date
    , chronic_condition_type
    , condition_category
    , condition
    , data_source
from conditions_unioned
