

with months as (

    select distinct month_start_date
    from "saas_dw"."core"."dim_date"

),

periods as (

    select * from "saas_dw"."core"."fct_subscription_periods"

),

monthly as (

    select
        month_start_date,

        -- Closing balance. An account that churned during the month is excluded from it; it
        -- has no rows in any later month, so its revenue leaves once and stays gone.
        sum(case when not is_churned_month then mrr_usd else 0 end)      as ending_mrr_usd,

        sum(case when is_new_account  then mrr_usd        else 0 end)      as new_mrr_usd,
        sum(case when is_expansion    then mrr_change_usd else 0 end)      as expansion_mrr_usd,
        sum(case when is_contraction  then -mrr_change_usd else 0 end)     as contraction_mrr_usd,
        -- Churned MRR is measured against the account's *opening* balance, not the month-end one.
        -- When an account changes plan and churns in the same month, mrr_usd is the new plan's
        -- price, but what actually left the business was what was in the opening balance.
        -- Using mrr_usd here silently misstates churn by the size of the plan change.
        sum(case when is_churned_month then prior_mrr_usd else 0 end)  as churned_mrr_usd,

        count(*) filter (where not is_churned_month)                      as active_accounts,
        count(*) filter (where is_new_account)                            as new_accounts,
        count(*) filter (where is_expansion)                              as expanded_accounts,
        count(*) filter (where is_contraction)                            as contracted_accounts,
        count(*) filter (where is_churned_month)                          as churned_accounts

    from periods
    group by month_start_date

),

calculated as (

    select
        *,

        (new_mrr_usd + expansion_mrr_usd - contraction_mrr_usd - churned_mrr_usd)
                                                            as net_new_mrr_usd

    from monthly

),

-- Every spine month gets a row. A month with no activity reports zero, not nothing.
filled as (

    select
        months.month_start_date,
        coalesce(calculated.ending_mrr_usd, 0)         as ending_mrr_usd,
        coalesce(calculated.new_mrr_usd, 0)            as new_mrr_usd,
        coalesce(calculated.expansion_mrr_usd, 0)      as expansion_mrr_usd,
        coalesce(calculated.contraction_mrr_usd, 0)    as contraction_mrr_usd,
        coalesce(calculated.churned_mrr_usd, 0)        as churned_mrr_usd,
        coalesce(calculated.net_new_mrr_usd, 0)        as net_new_mrr_usd,
        coalesce(calculated.active_accounts, 0)        as active_accounts,
        coalesce(calculated.new_accounts, 0)           as new_accounts,
        coalesce(calculated.expanded_accounts, 0)      as expanded_accounts,
        coalesce(calculated.contracted_accounts, 0)    as contracted_accounts,
        coalesce(calculated.churned_accounts, 0)       as churned_accounts

    from months
    left join calculated using (month_start_date)

),

with_prior as (

    select
        *,

        -- The prior month's closing balance is this month's opening balance.
        coalesce(
            lag(ending_mrr_usd) over (order by month_start_date),
            0
        )                                                  as beginning_mrr_usd

    from filled

),

final as (

    select
        with_prior.month_start_date,
        dim_date.month_year,
        dim_date.year_number,
        dim_date.quarter_number,
        dim_date.month_number,

        beginning_mrr_usd,
        new_mrr_usd,
        expansion_mrr_usd,
        contraction_mrr_usd,
        churned_mrr_usd,
        net_new_mrr_usd,
        ending_mrr_usd,

        active_accounts,
        new_accounts,
        expanded_accounts,
        contracted_accounts,
        churned_accounts,

        -- ARPA: what the average paying account is worth this month.
        cast(ending_mrr_usd as numeric)
        / nullif(cast(active_accounts as numeric), 0)        as arpa_usd,
        cast(beginning_mrr_usd as numeric)
        / nullif(cast(active_accounts as numeric), 0)    as beginning_arpa_usd,

        -- Month-over-month growth. NULL when there is no opening balance to grow from.
        cast(net_new_mrr_usd as numeric)
        / nullif(cast(beginning_mrr_usd as numeric), 0)    as mrr_growth_rate,

        -- Logo churn: share of the opening base of accounts lost.
        cast(churned_accounts as numeric)
        / nullif(cast(active_accounts + churned_accounts as numeric), 0)
                                                            as logo_churn_rate,

        -- Revenue churn: share of opening MRR lost, from churn and contraction together.
        cast(churned_mrr_usd + contraction_mrr_usd as numeric)
        / nullif(cast(beginning_mrr_usd as numeric), 0)
                                                            as gross_revenue_churn_rate,

        cast(expansion_mrr_usd as numeric)
        / nullif(cast(beginning_mrr_usd as numeric), 0) as expansion_rate,

        -- Gross revenue retention: how much of the opening base survives churn and contraction.
        1 - (cast(churned_mrr_usd + contraction_mrr_usd as numeric)
        / nullif(cast(beginning_mrr_usd as numeric), 0))
                                                            as gross_revenue_retention

    from with_prior
    inner join "saas_dw"."core"."dim_date"
        on dim_date.date_day = with_prior.month_start_date

)

select * from final