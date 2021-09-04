#!/bin/bash

echo "=> Downloading EclipseLink v$ECLIPSELINK_VERSION"
curl https://ftp.acc.umu.se/mirror/eclipse.org/rt/eclipselink/releases/$ECLIPSELINK_VERSION/eclipselink.jar --output /tmp/eclipselink.jar

echo "=> Installing EclipseLink v$ECLIPSELINK_VERSION"
ECLIPSELINK_PATH=$WILDFLY_HOME/modules/system/layers/base/org/eclipse/persistence/main
sed -i "s/<\/resources>/\n\
        <resource-root path=\"eclipselink-${ECLIPSELINK_VERSION}.jar\">\n \
            <filter>\n \
                <exclude path=\"javax\/**\" \/>\n \
            <\/filter>\n \
        <\/resource-root>\n \
    <\/resources>/" $ECLIPSELINK_PATH/module.xml