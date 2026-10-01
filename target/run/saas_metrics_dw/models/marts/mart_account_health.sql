
  
    

  create  table "saas_dw"."marts"."mart_account_health__dbt_tmp"
  
  
    as
  
  (
    

with as_of as (

    select max(week_start_date) as as_of_week
    from "saas_dw"."core"."fct_account_weekly_usage"

),

weekly as (

    select
        fct_account_weekly_usage.account_id,
        fct_account_weekly_usage.week_start_date,
        fct_account_weekly_usage.event_count,
        fct_account_weekly_usage.session_count,
        fct_account_weekly_usage.active_user_count,
        fct_account_weekly_usage.gated_feature_count

    from "saas_dw"."core"."fct_account_weekly_usage"
    cross join as_of

),

-- Usage windows relative to the latest week. Four weeks is long enough to smooth a quiet
-- holiday week and short enough to still be actionable.
usage_windows as (

    select
        weekly.account_id,

        sum(case when weekly.week_start_date > as_of.as_of_week - 28
                 then weekly.event_count else 0 end)                       as events_last_4_weeks,
        sum(case when weekly.week_start_date > as_of.as_of_week - 56
                  and weekly.week_start_date <= as_of.as_of_week - 28
                 then weekly.event_count else 0 end)                       as events_prev_4_weeks,

        count(distinct case when weekly.week_start_date > as_of.as_of_week - 28
                          then weekly.session_count end)                  as sessions_last_4_weeks,

        max(case when weekly.week_start_date > as_of.as_of_week - 28
                 then weekly.active_user_count else 0 end)                 as active_users_last_4_weeks,

        max(case when weekly.week_start_date > as_of.as_of_week - 28
                 then weekly.gated_feature_count else 0 end)               as gated_features_last_4_weeks,

        -- Each account's own best week in the last six months, as an intensity reference.
        -- Comparing an account to itself rather than to a global average keeps a small
        -- account from scoring as heavy usage just because bigger accounts generate more
        -- raw events.
        max(case when weekly.week_start_date > as_of.as_of_week - 182
                 then weekly.event_count else 0 end)                       as peak_weekly_events,

        max(case when weekly.week_start_date > as_of.as_of_week - 28
                 then weekly.week_start_date end)                          as last_active_week

    from weekly
    inner join as_of on true
    group by weekly.account_id

),

current_state as (

    select
        periods.account_id,
        periods.plan_code,
        periods.mrr_usd,
        periods.seats,
        periods.tenure_month_number
        from "saas_dw"."core"."fct_subscription_periods" as periods
    cross join as_of
    -- as_of_week is a week start; the fact is at month grain. Truncate to the month the latest
    -- usage week falls in.
    where periods.month_start_date = date_trunc('month', as_of.as_of_week)::date
      and not periods.is_churned_month

),

account_health as (

    select
        dim_accounts.account_id,
        md5(cast(coalesce(cast(dim_accounts.account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_account,
        dim_accounts.account_name,
        dim_accounts.industry,
        dim_accounts.employee_band,
        dim_accounts.country_code,
        dim_accounts.region,
        dim_accounts.signed_up_date,
        dim_accounts.signup_month,

        current_state.plan_code,
        current_state.mrr_usd,
        current_state.seats,
        current_state.tenure_month_number                     as tenure_months,

        as_of.as_of_week,
        (as_of.as_of_week + 6)                              as as_of_date,

        coalesce(usage_windows.events_last_4_weeks, 0)      as events_last_4_weeks,
        coalesce(usage_windows.events_prev_4_weeks, 0)      as events_prev_4_weeks,
        coalesce(usage_windows.sessions_last_4_weeks, 0)    as sessions_last_4_weeks,
        coalesce(usage_windows.active_users_last_4_weeks, 0) as active_users_last_4_weeks,
        coalesce(usage_windows.gated_features_last_4_weeks, 0) as gated_features_last_4_weeks,
        coalesce(usage_windows.peak_weekly_events, 0)       as peak_weekly_events,

        usage_windows.last_active_week,
        case
            when usage_windows.last_active_week is null then null
            else (as_of.as_of_week - usage_windows.last_active_week) / 7
        end                                                  as weeks_since_last_active

    from current_state
    inner join "saas_dw"."core"."dim_accounts" as dim_accounts
        on dim_accounts.account_id = current_state.account_id
    cross join as_of
    left join usage_windows
        on usage_windows.account_id = current_state.account_id

),

scored as (

    select
        account_health.*,

        -- Recency: full marks this week, zero once the account has been silent for eight
        -- weeks. Linear, because the shape of the decay is a judgement call and pretending
        -- otherwise would be the dishonest part.
        case
            when weeks_since_last_active is null then 0.0
            else greatest(0.0, 100.0 * (1.0 - weeks_since_last_active / 8.0))
        end                                                     as recency_score,

        -- Frequency: recent activity against this account's own peak week, so the score is
        -- about 'as active as it gets' rather than 'busy in absolute terms'.
        case
            when peak_weekly_events <= 0 then 0.0
            else least(100.0, 100.0 * events_last_4_weeks / (peak_weekly_events * 4.0))
        end                                                     as frequency_score,

        -- Trend: this window against the one before. An account that was silent and is now
        -- active scores full marks; one that went quiet scores zero.
        case
            when events_prev_4_weeks = 0 and events_last_4_weeks > 0 then 100.0
            when events_prev_4_weeks = 0                            then 0.0
            else least(100.0, 100.0 * events_last_4_weeks / events_prev_4_weeks)
        end                                                     as trend_score,

        -- Magnitude: where the account's MRR sits among its own plan's peers.
        percent_rank() over (
            partition by plan_code order by mrr_usd
        ) * 100                                                 as magnitude_score,

        -- The raw ratio behind trend_score, kept because a score alone hides its own inputs.
        case
            when events_prev_4_weeks = 0 and events_last_4_weeks > 0 then null
            when events_prev_4_weeks = 0                            then null
            else events_last_4_weeks::numeric / events_prev_4_weeks
        end                                                     as usage_trend_ratio

    from account_health

),

weighted as (

    select
        

        scored.*,

        -- A plain weighted average of the four component scores, each already on 0-100. The
        -- weights sum to one, so there is no need to rescale: dividing by their sum and then
        -- multiplying by 100 would put the result on a 0-10000 scale.
        (
              0.35   * recency_score
            + 0.3 * frequency_score
            + 0.2     * trend_score
            + 0.15 * magnitude_score
        ) / (
              0.35
            + 0.3
            + 0.2
            + 0.15
        )                                                       as health_score

    from scored

)

select
    *,

    case
        -- Silence is its own band rather than a low score: an account with no events in four
        -- weeks is a different conversation from one whose engagement halved.
        when events_last_4_weeks = 0
          or weeks_since_last_active >= 4
            then 'dormant'
        when health_score >= 70                            then 'healthy'
        when usage_trend_ratio is not null
         and usage_trend_ratio < 0.6
                                                        then 'declining'
        when health_score >= 45                            then 'at_risk'
        else 'critical'
    end                                                         as health_band,

    (
        events_last_4_weeks = 0
        or weeks_since_last_active >= 4
        or (usage_trend_ratio is not null
            and usage_trend_ratio < 0.6)
        or health_score < 45
    )                                                          as needs_attention

from weighted
  );
  