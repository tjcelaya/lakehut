# lakehut

Suite of "big data" tools featuring:
  - Dagster: declarative data/job orchestration for loading, transferring, and cleaning up data either directly or by triggering Spark, Trino, etc.
  - **DEPRECATED**: Airflow: similar to Dagster. More widely used but also more cumbersome.
  - Jupyter Notebook: interactive code environment using Python and optionally other languages and toolkits
  - Trino: SQL query engine that can work across multiple storage types simultaneously
  - Spark: general purpose data analytics tool using Python/Scala/Java that also supports streaming
  - Superset: visualization as well as dynamic querying, filtering, and aggregation

With support from:
  - PostgreSQL: SQL database for Airflow metadata and general structured data storage
  - Redis: KV database for locking/coordination, streaming, and general unstructured storage
  - MinIO: object store for lakehouse, object, and unstructured storage

## Pre-requisites

Note: versions - if given - are generally just stable or latest used as of writing.

  - make:
    - Windows users: WSL
  - git: only required for Superset and Jupyter Notebook examples
  - docker
    - [Docker Desktop](https://www.docker.com/products/docker-desktop/) is recommended but not required
    - For non-Windows if you don't care about the UI: `systemctl --user start docker-desktop`

## [Architecture](./architecture.md)

## Setup

```bash
echo -e "AIRFLOW_UID=$(id -u)" > .env
make init
```

should exit 0

If you plan to use Superset you must also run:

```bash
git submodule update --init --recursive
```

## Run

```bash
make up
```

## Notebook

Note: currently only starts Jupyter Notebook and common data services (i.e. PostgreSQL, Redis, MinIO).

```bash
make notebook
```

## Access

- MinIO
  - web: <http://localhost:9001>
    - default login: `minioadmin`:`minioadmin`
- pgAdmin
  - web: <http://localhost:8032>
    - default login: `postgres@postgres.postgres`:`postgres`

- Redis Insight
  - web: <http://localhost:8032>
    - default login: `postgres@postgres.postgres`:`postgres`

- Jupyter Notebook (with PySpark + boto3)
  - web: <http://localhost:8888>
  - see `build/jupyter/requirements.txt` for custom dependencies

- Superset
  - web: <http://localhost:8088>
    - default login: `admin`:``admin`
  - sample data setup:
    - add connection:
      - host: `postgres:5432`
      - creds: `superset:superset`
      - database: `superset`
      - Advanced >
        - SQL Lab: enable settings
        - Security: Allow uploads: `public,superset`
    - upload `vendor/apache-superset/examples-data/tutorial_flights.csv`
      - File: obvious
      - File settings: Columns to be parsed as date: `Travel Date`
      - Columns: all

- Airflow
  - web: <http://localhost:8080>
    - default login: `airflow`:`airflow`
  - cli: `./airflow.sh info`
    - see: [wrapper](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#running-the-cli-commands)
    - also try: `./airflow.sh` with `bash` or `python`

- Spark
  - web: master: <http://localhost:8888>

## Clean up

**WARNING**: Deletes everything that isn't a volume mounted from the host!

```bash
make clean
```

## Pending

- Airflow
  - [ ] [Using custom images](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#using-custom-images)
  - [ ] `requirements.txt` (for the above)
- Dagster instead of Airflow? [Dagster on Docker](https://github.com/dagster-io/dagster/tree/1.9.3/examples/deploy_docker)
