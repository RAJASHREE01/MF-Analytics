select * from {{ ref('stg_schemes_master') }}
where 
scheme_code in (
    select distinct scheme_code from {{ ref('stg_nav_history') }} 
    where nav<=0
)