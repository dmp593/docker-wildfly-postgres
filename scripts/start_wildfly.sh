#!/bin/bash

if [ ! -f wildfly.started ]; then
JBOSS_CLI=$WILDFLY_HOME/bin/jboss-cli.sh

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    echo "Waiting"
    sleep 1
  done
}

echo "=> Setup Wildfly Admin Password"
$WILDFLY_HOME/bin/add-user.sh admin $WILDFLY_ADMIN_PASSWORD --silent
unset $WILDFLY_ADMIN_PASSWORD

echo "=> Starting WildFly server"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -c standalone.xml > /dev/null &

echo "=> Downloading PostgreSQL Driver"
POSTGRES_DRIVER_FILENAME=postgresql-$POSTGRES_DRIVER_VERSION.jar
curl https://jdbc.postgresql.org/download/$POSTGRES_DRIVER_FILENAME --output /tmp/$POSTGRES_DRIVER_FILENAME

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Setup Datasource"
$JBOSS_CLI -c << EOF
batch

# Add PostgreSQL driver
module add --name=org.postgres --resources=/tmp/$POSTGRES_DRIVER_FILENAME --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=postgres:add(driver-name="postgres",driver-module-name="org.postgres",driver-class-name=org.postgresql.Driver)

# Add the datasource
data-source add \
  --jndi-name=$DATASOURCE_JNDI \
  --name=$DATASOURCE_NAME \
  --connection-url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME \
  --driver-name=postgres \
  --user-name=$DB_USER \
  --password=$DB_PASS \
  --check-valid-connection-sql="SELECT 1" \
  --background-validation=true \
  --background-validation-millis=60000 \
  --flush-strategy=IdleConnections \
  --min-pool-size=10 --max-pool-size=100  --pool-prefill=false
# Execute the batch
run-batch
EOF

echo "=> Shutdown Wildfly"
$JBOSS_CLI -c ":shutdown"

touch wildfly.started
fi

echo "=> Start Wildfly"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -bmanagement=0.0.0.0 -c standalone.xml