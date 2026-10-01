-- Every event must belong to an account that had a subscription period in the same month.
-- mart_product_adoption joins events to periods to attribute usage to the tier in force, so an
-- event with no matching period row would be dropped silently and adoption would be understated
-- with no error anywhere.
select
    events.event_id,
    events.account_id,
    events.event_date
from "saas_dw"."core"."fct_product_events" as events
left join "saas_dw"."core"."fct_subscription_periods" as periods
    on  periods.account_id = events.account_id
   and periods.month_start_date = date_trunc('month', events.event_date)::date
where periods.account_id is null