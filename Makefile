
DC_ARGS= -p dataw \
	-f docker-compose-common.yml \
	-f docker-compose-airflow.yml \
	-f docker-compose-spark.yml \
	-f docker-compose-superset.yml

all:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

# go
.PHONY: clean
.PHONY: init
.PHONY: up

clean:
	docker compose \
		$(DC_ARGS) \
		down \
			--remove-orphans \
			--volumes \

		rm -rf logs/* tmp/*

# --rmi local \

init:
# postgres handles init using /docker-entrypoint-initdb.d
	docker compose \
		$(DC_ARGS) \
		up \
			airflow-init \
			superset-init

ps:
	docker compose \
		$(DC_ARGS) \
		ps -a

up:
	docker compose \
		$(DC_ARGS) \
		up

notebook:
	docker compose \
		$(DC_ARGS) \
		up postgres redis minio jupyter

# meta
.PHONY: list
.PHONY: restart
restart: clean init up
