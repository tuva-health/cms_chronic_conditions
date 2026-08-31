with chronic_conditions as (

    select distinct
          condition
        , condition_column_name
    from {{ ref('cms_chronic_conditions__cms_chronic_conditions_hierarchy') }}

),

conditions as (

    select
          chronic_conditions_unioned.person_id
        , chronic_conditions_unioned.data_source
        , chronic_conditions.condition_column_name
        , 1 as condition_count
    from {{ ref('cms_chronic_conditions__cms_chronic_conditions_long') }} as chronic_conditions_unioned
         inner join chronic_conditions as chronic_conditions
             on chronic_conditions_unioned.condition =
                chronic_conditions.condition

)


select
      p.person_id
    , p.data_source
    , {{ dbt_utils.pivot(
          column='condition_column_name'
        , values=dbt_utils.get_column_values(ref ('cms_chronic_conditions__cms_chronic_conditions_hierarchy'), 'condition_column_name', order_by= 'condition_column_name')
        , agg='max'
        , then_value= 1
        , else_value= 0
        , quote_identifiers = False
      ) }}
from {{ var('patient') }} as p
left join conditions
    on p.person_id = conditions.person_id
    and p.data_source = conditions.data_source
group by
      p.person_id
    , p.data_source
