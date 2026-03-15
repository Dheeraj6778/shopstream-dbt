{% snapshot snap_customers %}

{{
   config(
       target_schema='snapshots',
       unique_key='customer_id',
       strategy='timestamp',
       updated_at='customer_updated_at',
       invalidate_hard_deletes = true
   )
}}

select *
from {{ ref('stg_customers') }}



{% endsnapshot %}