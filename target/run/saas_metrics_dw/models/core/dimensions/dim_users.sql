
  
    

  create  table "saas_dw"."core"."dim_users__dbt_tmp"
  
  
    as
  
  (
    with users as (

    select * from "saas_dw"."staging"."stg_users"

),

joined as (

    select
        md5(cast(coalesce(cast(user_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as sk_user,
        user_id,
        -- Foreign key onto the account dimension, so user-level facts never join the raw
        -- natural key on the way to a report.
        md5(cast(coalesce(cast(account_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fk_account,
        account_id,
        email,
        full_name,
        role,
        is_admin,
        created_at,
        last_seen_at,
        last_seen_date,
        joined_month

    from users

)

select * from joined
  );
  