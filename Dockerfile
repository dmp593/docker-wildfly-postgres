FROM quay.io/wildfly/wildfly:27.0.0.Final-jdk17

ARG WILDFLY_ADMIN_PASSWORD=wildsecret
ARG POSTGRES_DRIVER_VERSION=42.5.4

ENV WILDFLY_HOME=/opt/jboss/wildfly
ENV DEPLOYMENTS_DIR=${WILDFLY_HOME}/standalone/deployments
ENV SCRIPTS_URL=https://raw.githubusercontent.com/dmp593/docker-wildfly-postgres/main/scripts/

WORKDIR $WILDFLY_HOME

# Sets Administrator Password
RUN bin/add-user.sh admin $WILDFLY_ADMIN_PASSWORD --silent

# Downloads scripts that configure datasource and mail, and starts the wildfly server
ADD --chown=jboss:root --chmod=771 ${SCRIPTS_URL}/setup_datasource.sh bin
ADD --chown=jboss:root --chmod=771 ${SCRIPTS_URL}/setup_mail.sh bin
ADD --chown=jboss:root --chmod=771 ${SCRIPTS_URL}/start_wildfly.sh bin

# Downloads PostgreSQL Driver
ADD --chown=jboss:root --chmod=664 https://jdbc.postgresql.org/download/postgresql-${POSTGRES_DRIVER_VERSION}.jar bin

# Starts the Wildfly Web Server
ENTRYPOINT ${WILDFLY_HOME}/bin/start_wildfly.sh
