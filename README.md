# Airflow single-node setup using Docker compose

Note: versions used as of writing

- airflow: 2.10.3
- minio:

## pending:

- [ ] [Using custom images](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#using-custom-images)
- [ ] `requirements.txt` (for the above)
- [x] `Makefile`

## Setup

```bash
echo -e "AIRFLOW_UID=$(id -u)" > .env
make init
```

should exit 0

## Run

```bash
make up
```

## Access

- airflow
  - web: [http://localhost:8080]
    - default login: `airflow`:`airflow`
  - cli: `./airflow.sh info`
    - see: [wrapper](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#running-the-cli-commands)
    - also try: `./airflow.sh` with `bash` or `python`
- minio
  - web: [http://localhost:9001]
    - default login: `minioadmin`:`minioadmin`
- spark
  - web: master: [http://localhost:8888]
  - cli:
- superset
  - web: [http://localhost:8088]
  - sample data setup:
    - add connection to `postgres:5432`
      - creds `superset:superset`
      - database `superset`
      - advanced >
        - SQL Lab: enable settings
        - Security: Allow uploads: `public,superset`
    - upload `vendor/apache-superset/examples-data/tutorial_flights.csv`
      - File: obvious
      - File settings: Columns to be parsed as date: `Travel Date`
      - Columns: all

## Destroy

```bash
make clean
```
