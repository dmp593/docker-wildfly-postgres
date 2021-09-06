.DEFAULT_GOAL := deploy

APPLICATION_NAME ?= "app"

up:
	docker compose up -d

clean:
	rm -rf target out

down: clean
	docker compose down --rmi local

down-all: clean
	docker compose down --rmi all --volumes

build: clean
	mvn package

deploy: up build
	docker compose cp target/*.war webserver:/opt/jboss/wildfly/standalone/deployments/${APPLICATION_NAME}.war
