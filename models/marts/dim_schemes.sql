select 
    scheme_code, 
    scheme_name, 
    fund_house, 
    scheme_type, 
    scheme_category, 
    plan_type, 
    isin_growth, 
    isin_div_reinvestment

from 
    {{ ref('stg_schemes_master') }}
where scheme_code is not null