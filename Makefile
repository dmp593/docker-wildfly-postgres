.DEFAULT_GOAL := deploy

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

ifeq ($(OS),Windows_NT)
    clean_goal := (IF EXIST target RD /S /Q target) & DEL /Q deployments
else
    clean_goal := rm -rf target deployments/*
endif

up:
	docker compose up -d

clean:
	$(clean_goal)

down: clean
	docker compose down --rmi local --volumes

down-all: clean
	docker compose down --rmi all --volumes

build: clean
	mvn package

deploy: clean build up

bash:
	docker compose exec webserver bash

logs:
	docker compose logs -f webserver

monitor: deploy logs

sql:
	docker compose exec db psql --username ${DB_USER} --password ${DB_NAME}

ps:
	docker compose ps
