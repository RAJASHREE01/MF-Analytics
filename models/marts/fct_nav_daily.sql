{{
    config(
        materialized='incremental',
        unique_keys=['scheme_code','nav_date']
    )
}}

select 
    scheme_code,
    scheme_name,
    scheme_type,
    plan_type,
    fund_house,
    scheme_category,
    nav_date,
    nav,
    nav_era,
    isin_growth
from 
    {{ ref('int_scheme_nav_enriched') }}

{% if is_incremental() %}
    where nav_date > (select max(nav_date) from {{ this }})
{% endif %}