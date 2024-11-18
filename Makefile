all: clean build

# go
.PHONY: clean
.PHONY: init
.PHONY: up

clean:
	docker compose \
		-f docker-compose-airflow.yml \
		-f docker-compose-minio.yml \
		-f docker-compose-spark.yml \
		down \
			--remove-orphans \
			--volumes \
			--rmi local

init:
	docker compose \
		-f docker-compose-airflow.yml \
		up \
			airflow-init

ps:
	docker compose \
		-f docker-compose-airflow.yml \
		-f docker-compose-minio.yml \
		-f docker-compose-spark.yml \
		ps -a

up:
	docker compose \
		-f docker-compose-airflow.yml \
		-f docker-compose-minio.yml \
		-f docker-compose-spark.yml \
		up
