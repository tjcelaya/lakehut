# lakehut

Suite of "big data" tools featuring:
  - Spark: transforms, query, general data tool
  - Airflow: orchestration, triggering jobs, managing spark and other services
  - Jupyter Notebook: interactive environment
  - Superset: visualization

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
    - `systemctl --user start docker-desktop`

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

```bash
make clean
```

## Pending

- [ ] [Using custom images](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#using-custom-images)
- [ ] `requirements.txt` (for the above)
