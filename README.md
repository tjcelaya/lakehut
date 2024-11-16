# Airflow single-node setup using Docker compose

Note: version used is 2.10.3 (stable as of writing).

## Setup

```bash
mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=$(id -u)" > .env
docker compose up airflow-init
```

should exit 0

## Start

```bash
docker compose up
```

## Access

 - web: `open http://localhost:8080`
    - default login: `airflow`:`airflow`
 - cli: `./airflow.sh info`
    - see: [wrapper](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#running-the-cli-commands)
    - also try: `./airflow.sh` with `bash` or `python`

## Destroy

```bash
docker compose down --volumes --remove-orphans --rmi all
```

## pending:

[Using custom images](https://airflow.apache.org/docs/apache-airflow/2.10.3/howto/docker-compose/index.html#using-custom-images)
`requirements.txt`

