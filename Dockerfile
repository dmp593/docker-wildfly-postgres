FROM jboss/wildfly

ENV WILDFLY_HOME=/opt/jboss/wildfly

COPY scripts/start_wildfly.sh ${WILDFLY_HOME}/bin

USER root

RUN chown jboss:jboss ${WILDFLY_HOME}/bin/start_wildfly.sh
RUN chmod 755 ${WILDFLY_HOME}/bin/start_wildfly.sh

USER jboss

ENTRYPOINT ${WILDFLY_HOME}/bin/start_wildfly.sh
