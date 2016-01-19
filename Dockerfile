FROM 1science/sbt
MAINTAINER Alexander Dvorkovyy

# Build arguments, do not use in container.
# Will be converted to ARG once Docker Hub migrates to 1.9
ENV TEAMCITY_VERSION 9.1.5
ENV TEAMCITY_AGENT_DIR /teamcity-agent
ENV TEAMCITY_AGENT_HOME /home/teamcity
ENV TEAMCITY_AGENT_WORK_DIR /home/teamcity/builds
ENV DOCKER_VERSION 1.9.1

# Environment variables, safe to change in container
ENV TEAMCITY_AGENT_NAME "SBT_Agent"
ENV TEAMCITY_AGENT_PORT 9090
ENV TEAMCITY_SERVER "http://teamcity:8111"

RUN apk add --update curl git \
 && curl --retry 3 -fsSLO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war

RUN mkdir -p $TEAMCITY_AGENT_DIR \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war update/buildAgent.zip -d /tmp \
 && unzip -qq /tmp/update/buildAgent.zip -d $TEAMCITY_AGENT_DIR \
 && mv $TEAMCITY_AGENT_DIR/conf/buildAgent.dist.properties $TEAMCITY_AGENT_DIR/conf/buildAgent.properties \

 && chmod +x $TEAMCITY_AGENT_DIR/bin/*.sh \

 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -fR /tmp/* \
 && addgroup -S -g 990 teamcity \
 && adduser -S -u 990 -G teamcity -h $TEAMCITY_AGENT_HOME -s /bin/false teamcity \
 && chown teamcity:teamcity $TEAMCITY_AGENT_DIR

#
# Docker
#

RUN curl -fsSL "https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "52286a92999f003e1129422e78be3e1049f963be1888afc3c9a99d5a9af04666  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

ADD teamcity-agent.sh /teamcity-agent.sh

RUN sed -i 's#%TEAMCITY_AGENT_DIR%#'$TEAMCITY_AGENT_DIR'#' /teamcity-agent.sh \
 && sed -i 's#%TEAMCITY_AGENT_WORK_DIR%#'$TEAMCITY_AGENT_WORK_DIR'#' /teamcity-agent.sh \
 && chmod +x /teamcity-agent.sh

VOLUME $TEAMCITY_AGENT_HOME
WORKDIR $TEAMCITY_AGENT_HOME

USER teamcity

EXPOSE 9090
CMD "/teamcity-agent.sh"