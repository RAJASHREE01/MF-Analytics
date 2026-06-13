with int as (
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
    from {{ ref('int_scheme_nav_enriched') }}
),
dates as (
    select 
        scheme_code,
        scheme_name,
        max(nav_date) as latest_nav_date,
        min(nav_date) as first_nav_date
    from int
    group by scheme_code, scheme_name
),
nav_values as (
    select
        int.scheme_code,
        int.scheme_name,
        dates.latest_nav_date,
        dates.first_nav_date,
        int.nav as latest_nav,
        int.fund_house, 
        int.scheme_category,
        int.plan_type
    from int join dates 
    on int.nav_date=dates.latest_nav_date and int.scheme_code=dates.scheme_code
),
diff_in_days as (
    select
        int.scheme_code,
        int.scheme_name,
        int.nav_date,
        abs(datediff(day,int.nav_date, dateadd('year',-1,dates.latest_nav_date))) as "1y_diff",
        abs(datediff(day,int.nav_date, dateadd('year',-3,dates.latest_nav_date))) as "3y_diff",
        abs(datediff(day,int.nav_date, dateadd('year',-5,dates.latest_nav_date))) as "5y_diff"
    from dates join int
    on dates.scheme_code=int.scheme_code
    --order by abs(datediff(day,int.nav_date, dateadd('year',-1,dates.latest_nav_date))) 
),
ranked as (
    select
        scheme_code,
        scheme_name,
        nav_date,
        row_number() over (partition by scheme_code order by "1y_diff", nav_date) as rk1,
        row_number() over (partition by scheme_code order by "3y_diff", nav_date) as rk3,
        row_number() over (partition by scheme_code order by "5y_diff", nav_date) as rk5
    from diff_in_days
),
days_required as (
    select 
        ranked.scheme_code,
        ranked.scheme_name,
        max(case when dates.first_nav_date <= dateadd(year, -1, dates.latest_nav_date) and rk1 = 1 then ranked.nav_date else null end) as nearest_1y_date,
        max(case when dates.first_nav_date <= dateadd(year, -3, dates.latest_nav_date) and rk3 = 1 then ranked.nav_date else null end) as nearest_3y_date,
        max(case when dates.first_nav_date <= dateadd(year, -5, dates.latest_nav_date) and rk5 = 1 then ranked.nav_date else null end) as nearest_5y_date
    from 
        ranked join dates on ranked.scheme_code=dates.scheme_code and ranked.scheme_name=dates.scheme_name
    group by ranked.scheme_code, ranked.scheme_name
),
nav_at_dates as (
    select 
        d.scheme_code,
        d.scheme_name,
        max(case when int.nav_date=d.nearest_1y_date then int.nav end) as nav_1y,
        max(case when int.nav_date=d.nearest_3y_date then int.nav end) as nav_3y,
        max(case when int.nav_date=d.nearest_5y_date then int.nav end) as nav_5y
    from 
        days_required d left join int 
    on int.scheme_code=d.scheme_code and int.scheme_name=d.scheme_name
    group by d.scheme_code, d.scheme_name
),
all_time as (
    select
        scheme_code,
        scheme_name,
        max(nav) as all_time_high,
        min(nav) as all_time_low
    from int
    group by scheme_code, scheme_name
),
final as (
    select 
        nv.scheme_code,
        nv.scheme_name,
        nv.fund_house,
        nv.scheme_category,
        nv.plan_type,
        nv.latest_nav,
        nv.latest_nav_date,
        nv.first_nav_date,
        nd.nav_1y,
        nd.nav_3y,
        nd.nav_5y,
        round(({{ dbt_utils.safe_divide('(nv.latest_nav - nd.nav_1y)','nd.nav_1y') }}) * 100, 2) as return_1y,
        round(({{ dbt_utils.safe_divide('(nv.latest_nav - nd.nav_3y)','nd.nav_3y') }}) * 100, 2) as return_3y,
        round(({{ dbt_utils.safe_divide('(nv.latest_nav - nd.nav_5y)','nd.nav_5y') }}) * 100, 2) as return_5y,
        at.all_time_high,
        at.all_time_low
    from nav_at_dates nd
    join nav_values nv
        on nd.scheme_code = nv.scheme_code
    join all_time at
        on nd.scheme_code = at.scheme_code
)
select * from final