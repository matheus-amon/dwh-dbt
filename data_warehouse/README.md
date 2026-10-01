# saas-metrics-dwh

The dbt warehouse. It turns the `raw_*` tables produced by
[`dwh-config-local`](https://github.com/matheus-amon/dwh-config-local) into a star schema
and four SaaS revenue marts.

Under construction — see [`saas-dwh-pipelines`](https://github.com/matheus-amon/saas-dwh-pipelines)
for the Airflow layer that runs it.

## Lineage

Independent implementation, inspired by Airflow/dbt workshop material the author worked
through. No code is reused from it. The domain, model names, structure and metrics here are
original to this project.

## Licence

MIT
