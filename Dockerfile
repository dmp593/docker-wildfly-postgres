FROM jboss/wildfly

ENV WILDFLY_HOME=/opt/jboss/wildfly

COPY scripts ${WILDFLY_HOME}/bin

USER root

RUN chown jboss:jboss ${WILDFLY_HOME}/bin/*.sh
RUN chmod 755 ${WILDFLY_HOME}/bin/*.sh

USER jboss

ENTRYPOINT ${WILDFLY_HOME}/bin/start_wildfly.sh
