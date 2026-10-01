-- Adoption is a proportion over a subset: it cannot exceed 1, and the number of accounts using
-- a feature cannot exceed the number entitled to it.
select *
from {{ ref('mart_product_adoption') }}
where accounts_using_feature > entitled_accounts
   or adoption_rate > 1
   or entitled_adoption_rate > 1
   or entitled_not_adopting < 0
