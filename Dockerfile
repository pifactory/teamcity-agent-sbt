FROM 1science/sbt
MAINTAINER Alexander Dvorkovyy

ARG TEAMCITY_VERSION=9.1.5
ARG TEAMCITY_AGENT_DIR=/teamcity-agent
ARG TEAMCITY_AGENT_WORK_DIR=/teamcity-work

ENV TEAMCITY_AGENT_NAME "SBT Agent"
ENV TEAMCITY_AGENT_PORT 9090
ENV TEAMCITY_SERVER "http://teamcity:8111"

RUN apk add --update curl git \
 && curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war

RUN mkdir -p $TEAMCITY_AGENT_DIR \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war update/buildAgent.zip -d /tmp \
 && unzip -qq /tmp/update/buildAgent.zip -d $TEAMCITY_AGENT_DIR \
 && mv $TEAMCITY_AGENT_DIR/conf/buildAgent.dist.properties $TEAMCITY_AGENT_DIR/conf/buildAgent.properties \

 && chmod +x $TEAMCITY_AGENT_DIR/bin/*.sh \

 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -fR /tmp/* \
 && adduser -S -h $TEAMCITY_AGENT_WORK_DIR -s /bin/false teamcity

ADD teamcity-agent.sh /teamcity-agent.sh

RUN sed -i 's#%TEAMCITY_AGENT_DIR%#'$TEAMCITY_AGENT_DIR'#' /teamcity-agent.sh \
 && sed -i 's#%TEAMCITY_AGENT_WORK_DIR%#'$TEAMCITY_AGENT_WORK_DIR'#' /teamcity-agent.sh

VOLUME $TEAMCITY_AGENT_WORK_DIR
WORKDIR $TEAMCITY_AGENT_WORK_DIR

USER teamcity

EXPOSE 9090
CMD "/teamcity-agent.sh"