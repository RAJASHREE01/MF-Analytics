select 
    scheme.scheme_code,
    scheme.scheme_name,
    scheme.scheme_type,
    scheme.plan_type,
    scheme.fund_house,
    scheme.scheme_category,
    nav.nav_date,
    nav.nav,
    nav.nav_era,
    scheme.isin_growth
from 
    {{ ref('stg_nav_history') }} nav
left join 
    {{ ref('stg_schemes_master') }} scheme
on 
    nav.scheme_code=scheme.scheme_code