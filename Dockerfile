FROM 1science/sbt
MAINTAINER Alexander Dvorkovyy

# Build arguments, do not use in container.
# Will be converted to ARG once Docker Hub migrates to 1.9
ENV TEAMCITY_VERSION 9.1.5
ENV AGENT_DIR /opt/buildAgent
ENV AGENT_HOME /home/teamcity
ENV DOCKER_VERSION 1.9.1

# Environment variables, safe to change in container
ENV TEAMCITY_AGENT_NAME "SBT_Agent"
ENV TEAMCITY_AGENT_PORT 9090
ENV TEAMCITY_SERVER "http://teamcity:8111"

ADD teamcity-agent.sh /teamcity-agent.sh

RUN apk add --update curl git \
 && mkdir -p $AGENT_DIR \
 && addgroup -S -g 990 teamcity \
 && adduser -S -u 990 -G teamcity -h $AGENT_HOME -s /bin/false teamcity \
 && chown teamcity:teamcity $AGENT_DIR \
 && sed -i 's#%AGENT_DIR%#'$AGENT_DIR'#' /teamcity-agent.sh \
 && chmod +x /teamcity-agent.sh

#
# Docker
#

RUN curl -fsSL "https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "52286a92999f003e1129422e78be3e1049f963be1888afc3c9a99d5a9af04666  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

WORKDIR $AGENT_DIR
VOLUME $AGENT_HOME
VOLUME $AGENT_DIR

USER teamcity

EXPOSE $TEAMCITY_AGENT_PORT
CMD "/teamcity-agent.sh"