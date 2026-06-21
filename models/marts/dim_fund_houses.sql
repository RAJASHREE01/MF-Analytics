select
    fund_house,
    count(distinct scheme_code) as total_schemes, 
    count(distinct scheme_type) as scheme_types,
    count(distinct scheme_category) as scheme_categories

from 
    {{ ref('stg_schemes_master') }}
where 
    fund_house is not null
group by 
    fund_house