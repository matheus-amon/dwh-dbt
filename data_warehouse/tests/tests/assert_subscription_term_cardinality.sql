-- Term cardinality, asserted in both directions.
--
-- An active account must have exactly one open subscription term: more than one would
-- double-count MRR in the movement mart, none would drop the account out of the fact. A
-- churned account must have none, because a churn closes its final term for good. That
-- asymmetry is the data model's intent, so it is asserted rather than left to convention.
with open_terms as (

    select
        account_id,
        count(*) filter (where is_current_term) as current_term_count

    from {{ ref('stg_subscriptions') }}
    group by account_id

),

expected as (

    select
        account_id,
        is_churned,
        case when is_churned then 0 else 1 end as expected_current_terms

    from {{ ref('stg_accounts') }}

)

select
    expected.account_id,
    expected.is_churned,
    coalesce(open_terms.current_term_count, 0) as actual_current_terms,
    expected.expected_current_terms

from expected
left join open_terms using (account_id)

where coalesce(open_terms.current_term_count, 0) <> expected.expected_current_terms
