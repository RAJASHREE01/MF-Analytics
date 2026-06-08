select  
    count(*),
    plan_type
 from {{ ref('stg_schemes_master') }}
 group by plan_type