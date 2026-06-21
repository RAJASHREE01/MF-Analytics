select 
    scheme_code,
    nav_date,
    nav,
    case
        when nav_date < '2013-01-01' then 'PRE_2013'
        else 'POST_2013'
    end as nav_era
 from
{{ source('raw', 'nav_history') }}
where nav>0
--removing negative nav fund values - since nav can't be negative, 
--must be mfapi data issue, since direct api fetch gives negative nav values