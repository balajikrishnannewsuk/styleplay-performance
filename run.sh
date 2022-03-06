SCRIPTROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
printf "Running script in $SCRIPTROOT \n"

# Ensure the following
# 1. Mongo is running "docker run -d -p 30000:27017 mongo"
# 2. /etc/hosts have been updated with
#      127.0.0.1 talksport.staging.apps-wireless.radio
#      127.0.0.1 join.uat.wireless.radio
#      127.0.0.1 api.staging-news.co.uk
#      127.0.0.1 dev-public-graph.wireless-dev.newsuk.tech
# 3. Start the audio platform services locally

BASEDIR=$SCRIPTROOT
SCENARIODIR=tests/executions
cd $BASEDIR

# Just to show you haven't accidentaly left any entries.
# cat /etc/hosts

# API_TOKEN is avaiable in blazemeter
export API_TOKEN=
export AUTH0_TOKEN=

# This is needed when running the audio platform services locally
# export GRAPH_URL=http://host.docker.internal:4000/audio/v1/graph

# Change the project in which the tests appear. Default value is "talkSPORT Backend"
#export PROJECT_NAME="Middleware virgin-radio"

export TARGET_ENV=staging-eks
SCENARIOS=("TNL")
for scenario in "${SCENARIOS[@]}"; do
  printf "\n\nScenarios for :: $SCENARIODIR/$scenario \n"
  printf "=%.0s" {1..50}; printf "\n"
  find $SCENARIODIR/$scenario -type f -maxdepth 1
done

while [ ! -f "$fileToExeute" ]; do
  printf "\n\nINPUT: Pickup a scenario from the above list (ending with .yaml)\n"
  read fileToExeute
done

export FILE_TO_EXECUTE=$fileToExeute
printf "\nRunning performance test for $FILE_TO_EXECUTE \n"

# Blazemeter testing - use 'run-cloud'.
# Local Docker testing - use 'run-local'
# Local Docker & Local services - use 'run-local' with host file entries
make run-local
#make run-cloud


# Things to check once the test starts
# 1. Blazemeter console - https://a.blazemeter.com/app/#/accounts/109940/workspaces/342659/dashboard
# 2. K8s Dashboard - https://one.newrelic.com/launcher/infra.infra?platform[accountId]=1082390&platform[timeRange][duration]=3600000&pane=eyJuZXJkbGV0SWQiOiJpbmZyYS5zZXJ2aWNlcyIsInByb3ZpZGVyTmFtZSI6Im9uSG9zdEludGVncmF0aW9ucyIsInByb3ZpZGVyQWNjb3VudElkIjo1LCJkYXRhU291cmNlIjoia3ViZXJuZXRlcyIsImZlYXR1cmUiOiJkYXNoYm9hcmQiLCJob3N0c0ZpbHRlcnMiOnsiYW5kIjpbeyJpcyI6eyJjbHVzdGVyTmFtZSI6ImNlbmctZWtzLXN0YWdpbmcifX0seyJpcyI6eyJuYW1lc3BhY2VOYW1lIjoid2QtYXVkaW8tcGxhdGZvcm0tc3RhZ2luZyJ9fSx7ImlzIjp7ImRlcGxveW1lbnROYW1lIjoicHJvZmlsZS1hcGktZGVwbG95bWVudCJ9fV19fQ
# 3. Newrelic APM - https://nidigitalsolutions.jira.com/wiki/spaces/WD/pages/1320583305/Audio+Platform+Runbook#NewRelic-Alert-Policies
# 4. K8s pod logs - GET/PUT requests for CPNs should be appearing (v1)

