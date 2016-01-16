#!/usr/bin/env ash

cd %TEAMCITY_AGENT_DIR%/conf
sed -i 's#^\(serverUrl=\).*$#\1'$TEAMCITY_SERVER'#' buildAgent.properties
sed -i 's#^\(name=\).*$#\1'$TEAMCITY_AGENT_NAME'#' buildAgent.properties
sed -i 's#^\(ownPort=\).*$#\1'$TEAMCITY_AGENT_PORT'#' buildAgent.properties
sed -i 's#^\(workDir=\).*$#\1%TEAMCITY_AGENT_WORK_DIR%#' buildAgent.properties

cd %TEAMCITY_AGENT_WORK_DIR%
%TEAMCITY_AGENT_DIR%/bin/agent.sh run