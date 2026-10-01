
      -- back compat for old kwarg name
  
  
        
            
            
            
            
        
    

    

    merge into "saas_dw"."core"."fct_product_events" as DBT_INTERNAL_DEST
        using "fct_product_events__dbt_tmp072858309880" as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.event_id = DBT_INTERNAL_DEST.event_id))

    
    when matched then update set
        "event_id" = DBT_INTERNAL_SOURCE."event_id","account_id" = DBT_INTERNAL_SOURCE."account_id","user_id" = DBT_INTERNAL_SOURCE."user_id","fk_account" = DBT_INTERNAL_SOURCE."fk_account","fk_user" = DBT_INTERNAL_SOURCE."fk_user","fk_date" = DBT_INTERNAL_SOURCE."fk_date","event_ts" = DBT_INTERNAL_SOURCE."event_ts","event_date" = DBT_INTERNAL_SOURCE."event_date","day_of_week" = DBT_INTERNAL_SOURCE."day_of_week","day_name" = DBT_INTERNAL_SOURCE."day_name","is_weekend" = DBT_INTERNAL_SOURCE."is_weekend","week_start_date" = DBT_INTERNAL_SOURCE."week_start_date","month_year" = DBT_INTERNAL_SOURCE."month_year","year_number" = DBT_INTERNAL_SOURCE."year_number","quarter_number" = DBT_INTERNAL_SOURCE."quarter_number","event_week_start" = DBT_INTERNAL_SOURCE."event_week_start","days_since_spine_start" = DBT_INTERNAL_SOURCE."days_since_spine_start","event_name" = DBT_INTERNAL_SOURCE."event_name","feature" = DBT_INTERNAL_SOURCE."feature","is_gated_feature" = DBT_INTERNAL_SOURCE."is_gated_feature","platform" = DBT_INTERNAL_SOURCE."platform","is_api_event" = DBT_INTERNAL_SOURCE."is_api_event","session_id" = DBT_INTERNAL_SOURCE."session_id","country_code" = DBT_INTERNAL_SOURCE."country_code"
    

    when not matched then insert
        ("event_id", "account_id", "user_id", "fk_account", "fk_user", "fk_date", "event_ts", "event_date", "day_of_week", "day_name", "is_weekend", "week_start_date", "month_year", "year_number", "quarter_number", "event_week_start", "days_since_spine_start", "event_name", "feature", "is_gated_feature", "platform", "is_api_event", "session_id", "country_code")
    values
        ("event_id", "account_id", "user_id", "fk_account", "fk_user", "fk_date", "event_ts", "event_date", "day_of_week", "day_name", "is_weekend", "week_start_date", "month_year", "year_number", "quarter_number", "event_week_start", "days_since_spine_start", "event_name", "feature", "is_gated_feature", "platform", "is_api_event", "session_id", "country_code")


  