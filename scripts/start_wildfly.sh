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

echo "=> Starting WildFly server"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -c standalone.xml > /dev/null &

echo "=> Waiting for the server to boot"
wait_for_server

echo "=> Setup Datasource"
source $WILDFLY_HOME/bin/setup_datasource.sh

echo "=> Setup E-Mail"
source $WILDFLY_HOME/bin/setup_mail.sh

echo "=> Shutdown Wildfly"
$JBOSS_CLI -c ":shutdown"

mv /tmp/deployments/* $DEPLOYMENTS_DIR
rm -rf /tmp/deployments

touch wildfly.started
fi

echo "=> Start Wildfly"
$WILDFLY_HOME/bin/standalone.sh -b=0.0.0.0 -bmanagement=0.0.0.0 -c standalone.xml
