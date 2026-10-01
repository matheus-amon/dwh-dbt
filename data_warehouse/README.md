# SaaS Metrics Warehouse

A dbt warehouse for **B2B SaaS product analytics**: it turns raw accounts, subscriptions and
product telemetry into a star schema and four revenue marts.

| | |
|---|---|
| **Scale** | 2,000 accounts · 20,000 users · 3,485 subscription terms · 1,000,000 product events · 24 months |
| **Warehouse** | 22 models · 16 tables/views · **308 passing tests** |
| **Stack** | dbt-core 1.12 · Postgres 16 · `dbt_utils` (the only package) |
| **CI** | Full warehouse rebuilt from the generator on every push |

Part of a three-repo stack:

| Repo | Role |
|---|---|
| [`dwh-config-local`](https://github.com/matheus-amon/dwh-config-local) | Generates the synthetic raw data and owns the Postgres it lands in |
| **`dwh-dbt`** (this one) | Models that data: staging → core → marts, plus the tests that keep them honest |
| [`dwh-airflow`](https://github.com/matheus-amon/dwh-airflow) | Airflow 3 + Cosmos: runs this warehouse daily, consumes the mart as an Asset |

---

## What it answers

B2B SaaS has a small number of questions it asks forever. These are them:

- **How is MRR moving?** — new, expansion, contraction, churn, and whether it reconciles.
- **Do cohorts retain?** — and does the revenue that leaks out come from the small accounts or the large ones?
- **Which features get adopted?** — and by which tier?
- **Which paying accounts are worth calling this week?** — before the revenue is gone, not after.

---

## The output

These are real rows from `mart_mrr_movement`, not illustrations.

```
month      beginning     new  expansion  contraction   churned     net_new     ending  accounts  ARPA
2026-05    3,439,299  192,095     48,158       14,019    51,200    175,034  3,614,333     1,415  2,554
2026-06    3,614,333  130,868     66,094       25,883   110,519     60,560  3,674,892     1,463  2,512
2026-07    3,674,892  203,365     59,256       34,406    54,344    173,871  3,848,763     1,496  2,573
2026-08    3,848,763  162,388     65,921       21,555   106,274    100,479  3,949,242     1,537  2,569
2026-09    3,949,242  219,565     64,314       21,229    95,991    166,659  4,115,901     1,562  2,635
```

**`beginning + net new = ending` holds exactly, across all 46 months.** Max drift: `0.00`.

That is the cheapest possible proof that the movement buckets are complete and disjoint, and it
is a test rather than a comment:

```sql
-- tests/assert_mrr_movement_reconciles.sql
where abs((beginning_mrr_usd + net_new_mrr_usd) - ending_mrr_usd) > 0.005
```

### Account health, as of the latest week

```
band        accounts  avg score  avg events (4w)  avg MRR
healthy          417       78.2              105    6,694
at_risk          499       60.4                7    1,280
declining        248       49.9               10    1,885
critical           2       40.7                2    1,455
dormant          396        2.5                0      545
```

The separation is the point: healthy accounts average 105 events in the last four weeks,
`dormant` ones average zero. This is the mart the generator's behaviour model exists to feed.

### Retention by signup tier

Cohort 2024-11, account retention:

```
tier         size   month 0   month 6   month 12
growth         28       100        93         89
starter        19       100        89         84
scale          13       100       100         92
enterprise     12       100       100         83
```

Enterprise retains *accounts* best and loses *revenue* fastest — 83% of accounts at month 12, but
the MRR index at 84 against 112 for starter. Small accounts churn as logos and stay cheap; large
ones stay as logos and walk away with the budget. Segmenting by signup tier is the only way to see
that, and it is the reason the grain includes `plan_code_at_signup`.

### Feature adoption, over the entitled set

```
feature              tier          entitled   adoption
core_dashboard       starter         5,372        43.4%
core_dashboard       enterprise      6,982        77.4%
data_export          enterprise      6,982        64.2%
sso                  scale           7,042        41.0%
advanced_analytics   enterprise      6,982        49.7%
```

Every feature is gated by plan tier: `sso` does not exist below `scale`, `advanced_analytics` only
on `enterprise`. Reporting adoption across a whole tier would show `sso` at 0% on starter and read
as a product failure. This mart reports over **entitled accounts only**, so the number means
something.

---

## Model

```
data_warehouse/
  dbt_project.yml          # one schema per layer, materialisation by folder
  packages.yml             # dbt_utils only
  macros/
    generate_date_spine.sql        # instead of dbt_date
    generate_schema_name.sql       # 'marts' means the marts schema
    safe_divide.sql
    months_between.sql
    generic_tests/
      expect_non_negative.sql
      expect_grain_unique.sql
  models/
    sources/_sources.yml   # 71 tests: the contract with the generator
    staging/               # 5 views
    core/
      dimensions/          # dim_date, dim_accounts, dim_users, dim_plans
      facts/               # fct_subscription_periods, fct_product_events, fct_account_weekly_usage
    marts/                 # 4 marts
  tests/                   # 8 singular tests for the invariants that matter
```

| Layer | Schema | Materialisation |
|---|---|---|
| `staging` | `staging` | view — rename, type, light derivation |
| `core` | `core` | table (facts) / view (dims) |
| `marts` | `marts` | table — the only relations a BI tool should touch |

### Facts

| Model | Grain | Notes |
|---|---|---|
| `fct_subscription_periods` | account × month | MRR at month end + new / expansion / contraction / churn flags |
| `fct_product_events` | event | Incremental, `merge` on `event_id`, one-day lookback |
| `fct_account_weekly_usage` | account × week | Engagement, normalised per active user |

### Marts

| Mart | Grain |
|---|---|
| `mart_mrr_movement` | month |
| `mart_cohort_retention` | signup month × signup tier × month since signup |
| `mart_product_adoption` | month × feature × plan tier |
| `mart_account_health` | paying account, as of the latest week |

---

## Decisions worth arguing about

Each of these is a choice I made and could have made differently.

**MRR movement reconciles as an identity, not an approximation.** Contraction and churn are
reported as positive magnitudes that `net_new` subtracts. That makes the reconciliation assertable
to the cent, so a missing or double-counted movement shows up as a number instead of quietly
skewing a dashboard.

**Churned MRR is measured against the opening balance, not the month-end one.** An account that
upgrades *and* churns in the same month has the new plan's price at month end, while what actually
left the business was what was in the opening balance. Reading `mrr_usd` misstated churn by the
size of the plan change — 768.75 unexplained, caught by the reconciliation test.

**`fct_subscription_periods` collapses a mid-month plan change into one row.** MRR is a month-end
snapshot, so an account that changes plan mid-month would otherwise produce two rows for the same
grain. `terms_in_month` records that more than one term touched the month, so the movement mart can
still see the change happened.

**The cohort revenue measure is an index, not a rate.** A cohort that expands after signing up
holds more revenue than it arrived with, so that number legitimately exceeds 1. Naming it
`mrr_retention_rate` invites reading it as a bounded proportion. The boundedness test covers
account retention, which *is* bounded.

**Feature gating lives in `dbt_project.yml`, not in the warehouse logic.** Without it, a gated
feature reads as 0% adoption on tiers that cannot reach it, when the truth is that it is
unreachable there. It is product catalogue data, so it is declared rather than reverse-engineered
from telemetry — inferring it from the events would assume away the thing the adoption mart exists
to check.

**`safe_divide` returns NULL, not 0.** "No revenue over no customers" is unknown, not zero. A mart
that reports it as 0 reads as "this segment produced nothing" when it never existed. Where zero is
right, the models coalesce explicitly.

**Usage is attributed per event to the tier in force at that moment, not to the tier at month
end.** Crediting the whole month to the month-end tier puts gated-feature usage *below* the gate
that entitles it — which a test here rejects.

**There is no SCD2 snapshot, deliberately.** The subscription term table already *is* the temporal
structure: an upgrade closes one term and opens the next. And the raw layer is rebuilt from
scratch on every load, so a snapshot would see every attribute change each run and produce a single
meaningless version.

**`fct_product_events` filters on a one-day lookback, not `> max(event_ts)`.** A merge only
inserts and updates, never deletes, so a strict filter silently drops any event whose timestamp
trails the last one written. The trade-off is documented on the model: if the source is ever
reseeded rather than appended to, re-run with `--full-refresh`, because orphans survive a merge.

---

## Tests

308 of them. The interesting ones are singular tests in `tests/`, because they assert properties
column-level tests cannot:

| Test | Asserts |
|---|---|
| `assert_mrr_movement_reconciles` | opening + net new = ending, exactly |
| `assert_movement_flags_are_mutually_exclusive` | the mart's buckets cannot double-count |
| `assert_cohort_periods_are_contiguous` | periods run 1..n with no gaps |
| `assert_marts_are_not_empty` | a mart that builds and contains nothing |
| `assert_feature_gating_holds_in_adoption` | no tier uses a feature it cannot reach |
| `assert_every_event_has_a_subscription_period` | otherwise adoption is understated silently |
| `assert_health_scores_are_bounded` | every component and the total on 0–100 |
| `assert_churn_months_have_an_opening_balance` | churn cannot happen with nothing to remove |

Grain is asserted on the **natural columns** via `expect_grain_unique`, not on the surrogate key:
the key is derived from the grain, so a grain that silently changes carries the hash with it and
keeps passing.

### Bugs these found

Worth reading, because it is the difference between "308 tests pass" and "308 tests that had
something to do":

- `is_churn` is a property of a subscription *term*, so using it as a month-level event marked
  every month a churned term spanned as a churn month — 216 false positives.
- Churned MRR read from month-end MRR misstated churn by 768.75 (found above).
- The health score was scaled **100×** because the weights already sum to one, which made every
  non-dormant account read as healthy.
- The as-of week was compared against a month-grained fact, so `mart_account_health` silently
  built **empty** and passed every column-level test.
- `accepted_range` with `inclusive: false` excludes the legitimate boundary values 1 and 4.
- Adoption credited gated-feature usage below the gate that entitles it.

---

## Running it

```bash
# 1. the raw layer — about a minute
cd ../dwh-config-local
docker compose -f docker-compose.telemetry.yml up -d
set -a && . ./.env.telemetry && set +a
python -m src.telemetry_lab.cli generate --output-dir data/raw
python -m src.telemetry_lab.cli load

# 2. the warehouse
cd ../dwh-dbt/data_warehouse
pip install -r requirements.txt
cp <your profile> ~/.dbt/profiles.yml     # profile name: saas_metrics_dw
dbt deps && dbt build
```

`dbt build` runs 22 models and 308 tests in about two minutes.

---

## Lineage

Independent implementation. Inspired by Airflow/dbt workshop material the author worked through — a
local-setup repo, a dbt warehouse, and an Airflow orchestration repo — and reusing no code from it.
The domain, the model names, the structure and the metrics here are original to this project.

## Licence

MIT