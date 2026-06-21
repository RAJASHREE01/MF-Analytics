select 
    scheme_code,
    scheme_name,
    isin_growth, 
    isin_div_reinvestment,
    fund_house,
    scheme_type,
    scheme_category,
    case 
        when scheme_name ilike '%direct%' then 'DIRECT' 
        when scheme_name ilike '%regular%' then 'REGULAR'
        else 'UNCLASSIFIED'
    end as plan_type
 from
{{ source('raw', 'schemes_master') }}