#!/bin/bash

export JBOSS_CLI=$WILDFLY_HOME/bin/jboss-cli.sh

if [ ! -f wildfly.started ]; then
function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    echo "Waiting"
    sleep 1
  done
}

mkdir -p /tmp/deployments
mv $DEPLOYMENTS_DIR/* /tmp/deployments

echo "************************* >>> Starting WildFly <<< *************************"
$WILDFLY_HOME/bin/standalone.sh -c standalone.xml > /dev/null &
wait_for_server

echo "************************* >>> Setup Datasource <<< *************************"
$JBOSS_CLI -c << EOF
batch

# Adds PostgreSQL driver module
module add --name=org.postgresql --resources=$WILDFLY_HOME/bin/postgresql-$POSTGRES_DRIVER_VERSION.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=postgres:add(driver-name="postgres",driver-module-name="org.postgresql",driver-class-name=org.postgresql.Driver)

# Adds the datasource
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

# Executes the batch
run-batch
EOF

echo "************************* >>> Setup Mail Session (fakeSMTP) <<< *************************"
$JBOSS_CLI -c << EOF
batch

# Creates the custom fakeSMTP mail session
/subsystem=mail/mail-session=fakeSMTP:add(jndi-name=java:/jboss/mail/fakeSMTP)

# Configures the custom SMTP socket binding groups
/socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=my-mail-smtp:add(host=host.docker.internal,port=2525)

# Adds the custom socket binding groups to the custom fakeSMTP mail session
/subsystem=mail/mail-session=fakeSMTP/server=smtp:add(outbound-socket-binding-ref=my-mail-smtp)

# Runs the batch commands
run-batch

# Reloads the server configuration
reload
EOF

echo "************************* >>> Shutting down Wildfly <<< *************************"
$JBOSS_CLI -c ":shutdown"

mv /tmp/deployments/* $DEPLOYMENTS_DIR
rm -rf /tmp/deployments

touch wildfly.started
fi

echo "************************* >>> Starting Wildfly Web Server <<< *************************"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -bmanagement=0.0.0.0 -c standalone.xml
