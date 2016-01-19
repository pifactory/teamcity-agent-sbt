#!/usr/bin/env ash

cd %TEAMCITY_AGENT_DIR%/conf
sed -i 's#^\(serverUrl=\).*$#\1'$TEAMCITY_SERVER'#' buildAgent.properties
sed -i 's#^\(name=\).*$#\1'$TEAMCITY_AGENT_NAME'#' buildAgent.properties
sed -i 's#^\(ownPort=\).*$#\1'$TEAMCITY_AGENT_PORT'#' buildAgent.properties
sed -i 's#^\(workDir=\).*$#\1%TEAMCITY_AGENT_WORK_DIR%#' buildAgent.properties

# if we have "--link some-docker:docker" and not DOCKER_HOST, let's set DOCKER_HOST automatically
if [ -z "$DOCKER_HOST" -a "$DOCKER_PORT_2375_TCP" ]; then
	export DOCKER_HOST='tcp://docker:2375'
fi

cd %TEAMCITY_AGENT_WORK_DIR%
%TEAMCITY_AGENT_DIR%/bin/agent.sh run