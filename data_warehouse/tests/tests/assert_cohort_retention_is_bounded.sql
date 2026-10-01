-- Account retention is a proportion and cannot exceed 100%; the retained count cannot exceed
-- the cohort size. Both are violated by a join that silently duplicates rows, which is the most
-- likely way this mart goes wrong.
--
-- mrr_retention_index is deliberately absent from this check: a cohort that expands after
-- signing up holds more revenue than it arrived with, so that index legitimately exceeds 1.
select *
from {{ ref('mart_cohort_retention') }}
where retained_accounts > cohort_accounts
   or account_retention_rate > 1
   or account_retention_rate < 0
