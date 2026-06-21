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
        int.nav as latest_nav
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
        row_number() over (partition by scheme_code order by "1y_diff") as rk1,
        row_number() over (partition by scheme_code order by "3y_diff") as rk3,
        row_number() over (partition by scheme_code order by "5y_diff") as rk5
    from diff_in_days
)
select *
from dates
where scheme_code = 101480;